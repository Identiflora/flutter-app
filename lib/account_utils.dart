import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:identiflora/database_utils.dart';
import 'package:identiflora/environment.dart';
import 'package:identiflora/theme/general_utils.dart';
import 'package:identiflora/view_account/view_account_utils.dart';
import 'auth_objects.dart';
import 'cache_utils.dart';
import 'dart:math';
import 'package:identiflora/widgets/neon_widgets.dart';
import 'package:identiflora/theme/neon_theme.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _Login();
}

//HASH ACCOUNT PASSWORDS FUNCT
String hashPassword(String password) {
  final bytes = utf8.encode(password); //TURN PASS INTO BYTES
  final digest = sha256.convert(bytes); //APPLY HASHING
  return digest.toString(); //RETURN HASHED STRING
}

String getLoginSuccessMsg() {
  return "Successfully logged in";
}

class _Login extends State<LoginWidget> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GestureDetector(
            onTap: () async {
              try {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoadingScreen<bool>.withNav(
                      loadingMsg: "Loading account information...",
                      foundMsg: "Account found! One moment...",
                      errorMsg:
                          "Unable to find account information. Returning...",
                      futureFunction: authenticateToken(),
                      postLoadingBuilder: (context, success) {
                        if (success == null || !success) {
                          return const LoginScreen();
                        }
                        return ViewAccountScreen();
                      },
                      navigateOnError: true,
                    ),
                  ),
                );
              } on RateLimitException catch (e) {
                if (context.mounted) {
                  errorPopupMessage(context, e.message, null);
                }
              } catch (error) {
                errorPopupMessage(context, "$error", null);
              }
            },
            child: Icon(
              Icons.account_circle_outlined,
              size: 80.0,
              color: Theme.of(context).colorScheme.surface,
              shadows: Theme.of(context).extension<NeonTheme>()?.homeIconShadow,
            ),
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoginView = true; // true for Login, false for Sign Up

  void toggleView() {
    setState(() {
      isLoginView = !isLoginView;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLoginView ? 'User Login' : 'Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            isLoginView ? const LoginForm() : const SignUpForm(),
            TextButton(
              onPressed: toggleView,
              child: Text(
                isLoginView
                    ? 'Need an account? Sign Up'
                    : 'Already have an account? Login',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            isLoginView ? TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PasswordResetForm()),
              ),
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ) : Container(),
          ],
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final emailControl = TextEditingController();
  final passwordControl = TextEditingController();
  bool passIsObscured = true;

  Future<bool> handleLogin(String email, String password) async {
    bool hasOTP = false, hasOTPError = false;

    try {
      final int otpResult = await submitUserOTPVerify(
        unhashedPassword: password,
        email: email,
      );

      // Result = 1 means OTP is valid and user needs new password, result = 0 means OTP is expired, but exists, result = -1 means there is not OTP
      if (otpResult == 1 && mounted) {
        // Get new password instead of OTP
        password = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NewPasswordForm()),
        );
        hasOTP = true;
      } else if (otpResult == 0 && mounted) {
        errorPopupMessage(
          context,
          "This one time password has expired! Please press 'Forgot password?' again for a new one time password.",
          Duration(seconds: 15),
        );
        return false;
      }
    } catch (error) {
      hasOTPError = true;
      if (mounted) {
        errorPopupMessage(context, "$error", null);
      }
    }

    final hashedPassword = hashPassword(password);
    try {
      final AuthToken token = await submitUserLogin(
        email: email,
        passwordHash: hashedPassword,
        hasOTP: hasOTP,
      );

      //SAVE AUTHTOKEN TO DEVICE
      await saveAuthToken(token.accessToken);
    } catch (err) {
      if (mounted && !hasOTPError && !err.toString().contains("401")) {
        errorPopupMessage(context, "Login failed: $err", null);
      }
      else if(mounted && !hasOTPError) {
        errorPopupMessage(
          context, 
          "Login failed due to invalid email or password. Please verify email or password are correct and try again.", 
          Duration(seconds: 7)
        );
      }
      return false;
    }

    return true;
  }

  void loginPressed() async {
    final email = emailControl.text.trim();
    String password = passwordControl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      errorPopupMessage(context, "Please complete all fields!", null);

      return;
    } else if (!validEmail(email)) {
      errorPopupMessage(
        context,
        "Emails cannot be less than 5 characters and must contain '@' and '.'\n\nAdditionally, emails cannot contain any of the following:\n${printBlacklistedChars()}",
        Duration(seconds: 8),
      );

      return;
    } else if (!validPassword(password)) {
      errorPopupMessage(
        context,
        "Passwords cannot be less than 4 characters or contain any of the following:\n${printBlacklistedChars()}",
        Duration(seconds: 8),
      );

      return;
    }

    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => LoadingScreen.withPop(
          loadingMsg: "Please wait while we log you in...",
          foundMsg: "Login complete! One moment...",
          errorMsg: "Sorry! We can't seem to log you in. Please check your internet connection then try again.",
          errorPopup: false,
          futureFunction: handleLogin(email, password),
          postLoadingPop: ModalRoute.withName("/"),
          popErrorScreenButton: null,
          popOnError: false,
          successMsg: getLoginSuccessMsg(),
          valueEqualCheck: true
        )
      )
    );
  } //END LOGINPRESSED FUNCT

  Future<bool> loginAndStore(String googleToken, BuildContext context) async {
    try {
      final AuthToken token = await submitUserGoogleLogin(
        token: googleToken,
        context: context,
      );

      await saveAuthToken(token.accessToken);

      return true;
    } catch (error) {
      if (context.mounted) {
        errorPopupMessage(context, "Login failed: $error", null);
      }
    }

    return false;
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    try {
      GoogleSignIn.instance.initialize(
        clientId: Environment.googleClientID,
        serverClientId: Environment.googleServerID,
      );
      final GoogleSignInAccount user = await GoogleSignIn.instance
          .authenticate();
      final GoogleSignInAuthentication auth = user.authentication;
      final String? googleToken = auth.idToken;
      if (googleToken != null && context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoadingScreen<bool>.withPop(
              loadingMsg: "Please wait while we log you in...",
              foundMsg: "Login complete! One moment...",
              errorMsg: "Sorry! We can't seem to log you in. Please check your internet connection then try again.",
              futureFunction: loginAndStore(googleToken, context),
              postLoadingPop: ModalRoute.withName("/"),
              popErrorScreenButton: null,
              popOnError: true,
              successMsg: getLoginSuccessMsg(),
              valueEqualCheck: true,
            ),
          ),
        );
      }
    } catch (err) {
      if (context.mounted) {
        errorPopupMessage(context, "Login failed: $err", null);
      }
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          [
                NeonInputField(controller: emailControl, labelText: "Email"),
                NeonInputField(
                  controller: passwordControl,
                  labelText: "Password",
                  obscureText: passIsObscured,
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => passIsObscured = !passIsObscured),
                    icon: Icon(
                      passIsObscured
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                NeonOutlinedButton(onPressed: loginPressed, labelText: "Login"),
                NeonOutlinedButton(
                  labelText: 'Sign in with Google',
                  borderRadius: BorderRadius.circular(38.0),
                  icon: Image.asset(
                    'assets/brand/Google_G_logo_500x500.png',
                    width: 25,
                    height: 25,
                  ),
                  onPressed: () => _handleGoogleSignIn(context),
                ),
              ]
              .map(
                (childWidget) => Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: childWidget,
                ),
              )
              .toList(),
    );
  }
} //END LOGINFORMSTATE CLASS

List<String> getRegions() {
  return ['Northeast US', 'Midwest US', 'Southern US', 'Western US'];
}

//USER SIGNUP CLASS
class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
} //END USER SIGNUP CLASS

//CLASS _SignUpFormState - LOGIC FOR ADDING NEW USER TO LIST
class _SignUpFormState extends State<SignUpForm> {
  final emailControl = TextEditingController();
  final usernameControl = TextEditingController();
  final passwordControl = TextEditingController();
  final confirmControl = TextEditingController();
  String? userRegion;
  bool passIsObscured = true;

  bool validateFields(
    String email,
    String username,
    String password,
    String passwordConfirm,
    String? region,
  ) {
    if (email.isEmpty ||
        username.isEmpty ||
        password.isEmpty ||
        region == null) {
      errorPopupMessage(context, "Please complete all fields!", null);

      return false;
    } else if (password != passwordConfirm) {
      errorPopupMessage(context, "Password confirm does not match!", null);

      return false;
    } else if (!validEmail(email)) {
      errorPopupMessage(
        context,
        "Emails cannot be less than 5 characters and must contain '@' and '.'\n\nAdditionally, emails cannot contain any of the following:\n${printBlacklistedChars()}",
        Duration(seconds: 8),
      );

      return false;
    } else if (!validUsername(username)) {
      errorPopupMessage(
        context,
        "Username field must not be empty and have less than ${getMaxUsernameLength()} characters.\n\nAdditionally, usernames cannot contain any of the following:\n${printBlacklistedChars()}",
        null,
      );

      return false;
    } else if (!validPassword(password)) {
      errorPopupMessage(
        context,
        "Passwords cannot be less than 4 characters or contain any of the following:\n${printBlacklistedChars()}",
        Duration(seconds: 8),
      );

      return false;
    }

    return true;
  }

  Future<bool> handleSignUp(
    String email, 
    String username, 
    String password, 
    String passwordConfirm, 
    String region
  ) async {
    //ONLY AFTER CONFIRMING PASSWORDS - HASH
    final hashedPassword = hashPassword(password);

    try {
      final AuthToken token = await submitUserRegistration(
        email: email,
        username: username,
        passwordHash: hashedPassword,
        region: region,
      );
      
      //SAVE AUTHTOKEN TO DEVICE
      await saveAuthToken(token.accessToken);

      return true;
    } catch (err) {
      if (mounted) {
        errorPopupMessage(context, "Login failed: $err", null);
      }
      return false;
    }
  }

  void signUp() async {
    final email = emailControl.text.trim();
    final username = usernameControl.text.trim();
    final password = passwordControl.text.trim();
    final passwordConfirm = confirmControl.text.trim();
    final region = userRegion;

    if (!validateFields(email, username, password, passwordConfirm, region)) {
      return;
    }

    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => LoadingScreen.withPop(
          loadingMsg: "Please wait while we sign you up...",
          foundMsg: "Sign up complete! Logging in...",
          errorMsg: "Sorry! We can't seem to sign you up. Please check your internet connection then try again.",
          errorPopup: false,
          futureFunction: handleSignUp(email, username, password, passwordConfirm, region!), 
          postLoadingPop: ModalRoute.withName("/"), 
          popErrorScreenButton: null, 
          popOnError: false,
          successMsg: getLoginSuccessMsg(),
          valueEqualCheck: true
        )
      )
    );
  }

  void _setDropdown(String value) {
    setState(() {
      userRegion = value;
    });
  }

  @override
  Widget build(BuildContext contex) {
    return Column(
      children:
          [
                NeonInputField(controller: emailControl, labelText: "Email"),

                NeonInputField(
                  controller: usernameControl,
                  labelText: "Username",
                ),

                NeonDropdownMenu(
                  onSelected: _setDropdown,
                  labelText: "Region",
                  options: getRegions(),
                ),

                NeonInputField(
                  controller: passwordControl,
                  labelText: "Password",
                  obscureText: passIsObscured,
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => passIsObscured = !passIsObscured),
                    icon: Icon(
                      passIsObscured
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),

                NeonInputField(
                  controller: confirmControl,
                  labelText: "Confirm Password",
                  obscureText: passIsObscured,
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => passIsObscured = !passIsObscured),
                    icon: Icon(
                      passIsObscured
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),

                NeonOutlinedButton(onPressed: signUp, labelText: "Sign Up"),
              ]
              .map(
                (childWidget) => Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: childWidget,
                ),
              )
              .toList(),
    );
  }
} //END SIGNUPFORMSTATE CLASS

class ExternalSignUpForm extends StatefulWidget {
  const ExternalSignUpForm({super.key});

  @override
  State<StatefulWidget> createState() => _ExternalSignUpFormState();
}

// Sign up form for new external user
class _ExternalSignUpFormState extends State<ExternalSignUpForm> {
  final usernameControl = TextEditingController();
  String? userRegion;

  void _setDropdown(String value) {
    setState(() {
      userRegion = value;
    });
  }

  void handleExternalUserInput() {
    if (validUsername(usernameControl.text.trim()) && userRegion != null) {
      List<String> userInfo = [usernameControl.text.trim(), userRegion!];
      Navigator.pop(context, userInfo);
    } else if (!validUsername(usernameControl.text.trim())) {
      errorPopupMessage(
        context,
        "Username field must not be empty and have less than ${getMaxUsernameLength()} characters.\n\nAdditionally, usernames cannot contain any of the following:\n${printBlacklistedChars()}",
        null,
      );
    } else {
      errorPopupMessage(
        context,
        "Please make sure a region is selected then try again.",
        null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How do we identify you?'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                "Please enter a username and region so others know how to identify you!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 32.0),
                child: Column(
                  children: [
                    NeonInputField(
                      controller: usernameControl,
                      labelText: 'Username',
                    ),
                    const SizedBox(height: 16.0),
                    NeonDropdownMenu(
                      onSelected: _setDropdown,
                      labelText: "Region",
                      options: getRegions(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              NeonOutlinedButton(
                onPressed: handleExternalUserInput,
                labelText: "Confirm",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Form for password reset
class PasswordResetForm extends StatelessWidget {
  final emailControl = TextEditingController();

  PasswordResetForm({super.key});

  void handlePasswordReset(BuildContext context) async {
    if (validEmail(emailControl.text.trim())) {
      try {
        int removedScreenCount = 0;
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) => LoadingScreen.withPop(
              loadingMsg: "Submitting password reset request... Please wait.", 
              foundMsg: "Submitted! One moment.", 
              errorMsg: "Password reset failed due to email being tied to external user (such as through Google). Please sign in with Google instead of resetting your password.", 
              successMsg: "Password reset request sent. It might take a moment. Please check your email for more instructions.",
              successMsgDuration: Duration(seconds: 15),
              futureFunction: submitUserPasswordReset(
                email: emailControl.text.trim(),
                otpLength: Random().nextInt(8) + 8, // OTP can be between 8 and 16
              ), 
              postLoadingPop: (route) {
                return removedScreenCount++ >= 2;
              }, 
              popErrorScreenButton: null,
              popOnError: true,
              errorPopup: true,
              valueEqualCheck: true,
            )
          )
        );
      } catch (err) {
        if (context.mounted) {
          errorPopupMessage(context, "Password reset failed: $err", null);

          Navigator.pop(context);
        }
      }
    } else {
      errorPopupMessage(
        context,
        "Emails cannot be less than 5 characters and must contain '@' and '.'\n\nAdditionally, emails cannot contain any of the following:\n${printBlacklistedChars()}",
        Duration(seconds: 8),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Additional Information Needed'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                "Please enter the email associated with your account.",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: NeonInputField(
                  controller: emailControl,
                  labelText: 'Email',
                ),
              ),
              const SizedBox(height: 16),

              NeonOutlinedButton(
                onPressed: () => handlePasswordReset(context),
                labelText: "Confirm",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NewPasswordForm extends StatefulWidget {
  const NewPasswordForm({super.key});

  @override
  State<NewPasswordForm> createState() => _NewPasswordFormState();
}

// Form for password reset
class _NewPasswordFormState extends State<NewPasswordForm> {
  final newPasswordControl = TextEditingController(),
      confirmPasswordControl = TextEditingController();
  bool passIsObscured = true;

  void handlePasswordChange() {
    if (newPasswordControl.text.trim() != confirmPasswordControl.text.trim()) {
      errorPopupMessage(context, "Password confirm does not match!", null);
    } else if (!validPassword(newPasswordControl.text.trim())) {
      errorPopupMessage(
        context,
        "Passwords cannot be less than 4 characters or contain any of the following:\n${printBlacklistedChars()}",
        Duration(seconds: 8),
      );
    } else {
      Navigator.pop(context, newPasswordControl.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Success! Your password has been reset."),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('Reset Password')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              NeonInputField(
                controller: newPasswordControl,
                labelText: "New Password",
                obscureText: passIsObscured,
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => passIsObscured = !passIsObscured),
                  icon: Icon(
                    passIsObscured
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              NeonInputField(
                controller: confirmPasswordControl,
                labelText: "Confirm New Password",
                obscureText: passIsObscured,
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => passIsObscured = !passIsObscured),
                  icon: Icon(
                    passIsObscured
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              NeonOutlinedButton(
                onPressed: handlePasswordChange,
                labelText: "Confirm",
              ),
            ],
          ),
        ),
      ),
    );
  }
}