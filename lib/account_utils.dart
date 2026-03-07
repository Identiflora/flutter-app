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
import 'package:identiflora/theme/glowing_text_theme.dart';
import 'package:identiflora/widgets/neon_widgets.dart';

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
                      errorMsg: "Unable to find account information. Returning...", 
                      futureFunction: authenticateToken(),
                      postLoadingBuilder: (context, success) {
                        if(success == null || !success) {
                          return const LoginScreen();
                        }
                        return ViewAccountScreen();
                      },
                      navigateOnError: true,
                    )
                  )
                );
              } on RateLimitException catch (e) {
                if (context.mounted) {
                  errorPopupMessage(
                    context, 
                    e.message, 
                    null
                  );
                }
              } catch (error) {
                errorPopupMessage(
                  context, 
                  "$error", 
                  null
                );
              }
            },
            child: Icon(
              Icons.account_circle_outlined,
              size: 80.0,
              color: Theme.of(context).colorScheme.surface,
              shadows: [BoxShadow(color: Colors.white, blurRadius: 12)], // SHOULD CHANGE TO BE SET BY THEME
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
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PasswordResetForm()),
              ),
              child: Text(
                isLoginView ? 'Forgot Password?' : '',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
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

  void loginPressed() async {
    final email = emailControl.text.trim();
    String password = passwordControl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please complete all fields"),
          backgroundColor: Colors.red,
        ),
      );
      //CHECKS FOR EMPTY FIELDS
      return;
    } //END FUNCT

    bool hasOTP = false, hasOTPError = false;

    try {
      final int otpResult = await submitUserOTPVerify(
        unhashedPassword: password,
        email: email,
      );
      debugPrint("$otpResult");

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
          Duration(seconds: 15)
        );
        return;
      }
    } catch (error) {
      hasOTPError = true;
      if(mounted) {
        errorPopupMessage(
          context, 
          "$error", 
          null
        );
      }
    }

    //ADDED FOR PASS HASHING - USE CREATED FUNCT ABOVE
    final hashedPassword = hashPassword(password);
    try {
      final AuthToken token = await submitUserLogin(
        email: email,
        passwordHash: hashedPassword,
        hasOTP: hasOTP,
      );
      debugPrint("Received token for $email: ${token.accessToken}");
      //SAVE AUTHTOKEN TO DEVICE
      await saveAuthToken(token.accessToken);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Successfully logged in"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.popUntil(context, ModalRoute.withName("/"));
      }
    } catch (err) {
      if (mounted && !hasOTPError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Login failed: $err"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
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
        errorPopupMessage(
          context, 
          "Login failed: $error", 
          null
        );
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
              popErrorScreenButton: "Return to Homepage",
              successMsg: "Successfully logged in",
            )
          ),
        );
      }
    } catch (err) {
      if (context.mounted) {
        errorPopupMessage(
          context, 
          "Login failed: $err", 
          null
        );
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
  return [
    'Northeast US',
    'Midwest US',
    'Southern US',
    'Western US',
  ];
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

  void signUp() async {
    final email = emailControl.text.trim();
    final username = usernameControl.text.trim();
    final password = passwordControl.text.trim();
    final confirm = confirmControl.text.trim();
    final region = userRegion;

    //CHECK IF PASSWORDS MATCH
    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password do not match, please correct"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    } //END SIGNUP
    debugPrint("Region: $region");
    //ONLY AFTER CONFIRMING PASSWORDS - HASH
    final hashedPassword = hashPassword(password);
    try {
      final AuthToken token = await submitUserRegistration(
        email: email,
        username: username,
        passwordHash: hashedPassword,
        region: region as String,
      );
      debugPrint("Received token for $email: ${token.accessToken}");
      //SAVE AUTHTOKEN TO DEVICE
      await saveAuthToken(token.accessToken);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Successfully logged in"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.popUntil(context, ModalRoute.withName("/"));
      }
    } catch (err) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Login failed: $err"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
  } //end sign up

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
                ),
                NeonInputField(
                  controller: confirmControl,
                  labelText: "Confirm Password",
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
            mainAxisAlignment: MainAxisAlignment.center,
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
                padding: const EdgeInsets.only(top: 16.0),
                child: Column(
                  children: [
                    NeonInputField(
                      controller: usernameControl,
                      labelText: 'Username'
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
              ElevatedButton(
                onPressed: () {
                  if (validUsername(usernameControl.text.trim()) && userRegion != null) {
                    List<String> userInfo = [usernameControl.text.trim(), userRegion!];
                    Navigator.pop(context, userInfo);
                  } else if (!validUsername(usernameControl.text.trim())) {
                    errorPopupMessage(
                      context, 
                      "Username field must not be empty and have less than 20 characters.\n\nAdditionally, usernames cannot contain any of the following:\n${printBlacklistedChars()}",
                      null
                    );
                  }
                  else {
                    errorPopupMessage(
                      context, 
                      "Please make sure a region is selected then try again.",
                      null
                    );
                  }
                },
                child: const Text("Confirm"),
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
            mainAxisAlignment: MainAxisAlignment.center,
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
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextField(
                  controller: emailControl,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () async {
                  if (validEmail(emailControl.text.trim())) {
                    try {
                      bool success = await submitUserPasswordReset(
                        email: emailControl.text.trim(),
                        otpLength: Random().nextInt(8) + 8,
                      );

                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Password reset request sent. It might take a moment. Please check your email for more instructions.",
                            ),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 15),
                          ),
                        );
                        Navigator.pop(context);
                      } else if (context.mounted) {
                        errorPopupMessage(
                          context, 
                          "Password reset failed due to email being tied to external user (such as through Google). Please sign in with Google instead of resetting your password.", 
                          Duration(seconds: 15)
                        );
                        
                        Navigator.pop(context);
                      }
                    } catch (err) {
                      if (context.mounted) {
                        errorPopupMessage(
                          context, 
                          "Password reset failed: $err", 
                          null
                        );
                        
                        Navigator.pop(context);
                      }
                    }
                  } else {
                    errorPopupMessage(
                      context, 
                      "Emails cannot be less than 5 characters and must contain '@' and '.'\n\nAdditionally, emails cannot contain any of the following:\n${printBlacklistedChars()}", 
                      Duration(seconds: 8)
                    );
                  }
                },
                child: const Text("Confirm"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Form for password reset
class NewPasswordForm extends StatelessWidget {
  final passwordControl = TextEditingController();

  NewPasswordForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Please enter a new password to be associated with your account.",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextField(
                  controller: passwordControl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () {
                  if (!validPassword(passwordControl.text.trim())) {
                    errorPopupMessage(
                      context, 
                      "Passwords cannot be less than 4 characters or contain any of the following:\n${printBlacklistedChars()}", 
                      Duration(seconds: 8)
                    );
                  } else {
                    Navigator.pop(context, passwordControl.text.trim());

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Success! Your password has been reset."),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                child: const Text("Confirm"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// class DecoratedDropdownMenu extends StatelessWidget {
//   final void Function(String selection)? onSelected;
//   final String labelText;
//   final List<String> options;

//   /// Creates a [DecoratedDropdownMenu]
//   ///
//   /// Standard dropdown menu decorated to match Identiflora theme.
//   /// * [onSelected] is the function to be executed upon selection. The input to this function is the string associated with the selection.
//   /// * [labelText] is the text displayed indicating what the dropdown menu is for.
//   /// * [options] are the options for the dropdown menu.
//   const DecoratedDropdownMenu({
//     super.key,
//     required this.onSelected,
//     required this.labelText,
//     required this.options,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: LayoutBuilder(
//         builder: (context, constraints) {
//           // Sort the list alphabetically
//           options.sort();

//           return Container(
//             // 1. Add the glowing shadow behind the widget
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(
//                 4.0,
//               ), // Matches default OutlineInputBorder radius
//               boxShadow: [
//                 BoxShadow(
//                   color: Theme.of(context).colorScheme.primary,
//                   blurRadius: 12.0,
//                   spreadRadius: 1.0,
//                 ),
//               ],
//             ),

//             child: DropdownMenu<String>(
//               width: constraints.maxWidth,
//               label: Text(labelText),

//               // 2. Style the internal text field and mask the shadow
//               inputDecorationTheme: InputDecorationTheme(
//                 filled: true,
//                 fillColor: Theme.of(context).colorScheme.surface,

//                 // Set the border colors to match the glow
//                 enabledBorder: OutlineInputBorder(
//                   borderSide: BorderSide(
//                     color: Theme.of(context).colorScheme.secondary,
//                     width: 1.5,
//                   ),
//                 ),
//               ),

//               onSelected: (String? value) {
//                 onSelected?.call(value as String);
//               },
//               dropdownMenuEntries: options.map<DropdownMenuEntry<String>>((
//                 String option,
//               ) {
//                 return DropdownMenuEntry<String>(value: option, label: option);
//               }).toList(),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
