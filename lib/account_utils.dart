import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:identiflora/database_utils.dart';
import 'package:identiflora/environment.dart';
import 'auth_objects.dart';
import 'cache_utils.dart';
import 'dart:math';
import 'package:identiflora/theme/glowing_text_theme.dart';

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
              bool tokenSuccess = false;
              try {
                tokenSuccess = await authenticateToken();
                if (!(tokenSuccess)) {
                  //if token is not valid, go to login screen
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  }
                } else {
                  //if token is valid, go to view account screen
                  if (context.mounted) {
                    Navigator.pushNamed(context, '/view_account_screen');
                  }
                }
              } on RateLimitException catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Image.asset(
              'assets/homepage/account_icon.png',
              width: 80,
              height: 80,
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
                style:
                    Theme.of(
                      context,
                    ).extension<GlowingTextTheme>()?.glowingText ??
                    const TextStyle(),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PasswordResetForm()),
              ),
              child: Text(
                isLoginView ? 'Forgot Password?' : '',
                style:
                    Theme.of(
                      context,
                    ).extension<GlowingTextTheme>()?.glowingText ??
                    const TextStyle(),
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

    final int otpResult = await submitUserOTPVerify(
      unhashedPassword: password,
      email: email,
    );
    debugPrint("$otpResult");
    bool hasOTP = false;

    // Result = 1 means OTP is valid and user needs new password, result = 0 means OTP is expired, but exists, result = -1 means there is not OTP
    if (otpResult == 1 && mounted) {
      // Get new password instead of OTP
      password = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NewPasswordForm()),
      );
      hasOTP = true;
    } else if (otpResult == 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "This one time password has expired! Please press 'Forgot password?' again for a new one time password.",
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 15),
        ),
      );
      return;
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
  } //END LOGINPRESSED FUNCT

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
            builder: (context) =>
                GoogleLoginLoadingScreen(googleToken: googleToken),
          ),
        );
      }
    } catch (err) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Login failed: $err"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DecoratedInputField(controller: emailControl, labelText: "Email"),
        DecoratedInputField(controller: passwordControl, labelText: "Password"),
        DecoratedOutlinedButton(onPressed: loginPressed, labelText: "Login"),

        Padding(
          padding: const EdgeInsets.all(4.0),
          child: ElevatedButton.icon(
            onPressed: () => _handleGoogleSignIn(context),
            icon: Image.asset(
              'assets/brand/Google_G_logo_500x500.png',
              width: 25,
              height: 25,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.secondary,
            ),
            label: Text("Sign in with Google"),
          ),
        ),
      ],
    );
  }
} //END LOGINFORMSTATE CLASS

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
      children: [
        DecoratedInputField(controller: emailControl, labelText: "Email"),

        DecoratedInputField(controller: usernameControl, labelText: "Username"),

        DecoratedDropdownMenu(
          onSelected: _setDropdown,
          labelText: "Region",
          options: ['Northeast US', 'Midwest US', 'Southern US', 'Western US'],
        ),

        DecoratedInputField(controller: passwordControl, labelText: "Password"),
        DecoratedInputField(
          controller: confirmControl,
          labelText: "Confirm Password",
        ),
        DecoratedOutlinedButton(onPressed: signUp, labelText: "Sign Up"),
      ],
    );
  }
} //END SIGNUPFORMSTATE CLASS

// Sign up form for new external user
class ExternalSignUpForm extends StatelessWidget {
  final usernameControl = TextEditingController();

  ExternalSignUpForm({super.key});

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
                "Please enter a username so others know how to identify you!",
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
                  controller: usernameControl,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (usernameControl.text.trim().isNotEmpty) {
                    Navigator.pop(context, usernameControl.text.trim());
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Please make sure username has at least 1 character then try again.",
                        ),
                        backgroundColor: Colors.red,
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

class GoogleLoginLoadingScreen extends StatelessWidget {
  final String googleToken;

  const GoogleLoginLoadingScreen({super.key, required this.googleToken});

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Login failed: $error"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loading...'), centerTitle: true),
      body: SafeArea(
        child: FutureBuilder<bool>(
          future: loginAndStore(googleToken, context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        "Please wait while we log you in...",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasData && snapshot.data == true) {
              // Run navigation after next frame
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Successfully logged in"),
                      backgroundColor: Colors.green,
                    ),
                  );

                  Navigator.popUntil(context, ModalRoute.withName("/"));
                }
              });

              // Return a found message for current frame
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        "Login complete! One moment...",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              if (snapshot.hasError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Login failed: ${snapshot.error}"),
                    backgroundColor: Colors.red,
                  ),
                );
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Sorry! We can't seem to log you in. Please check your internet connection then try again.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(context, ModalRoute.withName("/"));
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      textStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text("Return to Homepage"),
                  ),
                ],
              );
            }
          },
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
        title: const Text('Please provide us with additional information.'),
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
                  if (emailControl.text.trim().length >= 5) {
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Password reset failed due to email being tied to external user (such as through Google). Please sign in with Google instead of resetting your password.",
                            ),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 15),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    } catch (err) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Password reset failed: $err"),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 15),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Please make sure your email has at least 5 characters then try again.",
                        ),
                        backgroundColor: Colors.red,
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
                  if (passwordControl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please complete all fields."),
                        backgroundColor: Colors.red,
                      ),
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

class DecoratedInputField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;

  /// Creates a [DecoratedInputField]
  ///
  /// Standard input field decorated to match Identiflora theme.
  /// * [controller] is the text controller used to read and manipulate the input.
  /// * [labelText] is the text displayed indicating what the input field is for.
  const DecoratedInputField({
    super.key,
    required this.controller,
    required this.labelText,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary,
              blurRadius: 10.0,
              spreadRadius: 1.0,
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.secondary,
                width: 1.5,
              ),
            ),
            filled: true,
            labelText: labelText,
          ),
        ),
      ),
    );
  }
}

class DecoratedOutlinedButton extends StatelessWidget {
  final void Function()? onPressed;
  final String labelText;

  /// Creates a [DecoratedOutlinedButton]
  ///
  /// Standard outlined button decorated to match Identiflora theme.
  /// * [onPressed] is the function to be executed when the button is pressed.
  /// * [labelText] is the text displayed on the button.
  const DecoratedOutlinedButton({
    super.key,
    required this.onPressed,
    required this.labelText,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary,
              blurRadius: 12.0,
              spreadRadius: 1.0,
            ),
          ],
        ),
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surface,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            side: BorderSide(
              color: Theme.of(context).colorScheme.secondary,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          child: Text(labelText),
        ),
      ),
    );
  }
}

class DecoratedDropdownMenu extends StatelessWidget {
  final void Function(String selection)? onSelected;
  final String labelText;
  final List<String> options;

  /// Creates a [DecoratedDropdownMenu]
  ///
  /// Standard dropdown menu decorated to match Identiflora theme.
  /// * [onSelected] is the function to be executed upon selection. The input to this function is the string associated with the selection.
  /// * [labelText] is the text displayed indicating what the dropdown menu is for.
  /// * [options] are the options for the dropdown menu.
  const DecoratedDropdownMenu({
    super.key,
    required this.onSelected,
    required this.labelText,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Sort the list alphabetically
          options.sort();

          return Container(
            // 1. Add the glowing shadow behind the widget
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                4.0,
              ), // Matches default OutlineInputBorder radius
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary,
                  blurRadius: 12.0,
                  spreadRadius: 1.0,
                ),
              ],
            ),

            child: DropdownMenu<String>(
              width: constraints.maxWidth,
              label: Text(labelText),

              // 2. Style the internal text field and mask the shadow
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,

                // Set the border colors to match the glow
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.secondary,
                    width: 1.5,
                  ),
                ),
              ),

              onSelected: (String? value) {
                onSelected?.call(value as String);
              },
              dropdownMenuEntries: options.map<DropdownMenuEntry<String>>((
                String option,
              ) {
                return DropdownMenuEntry<String>(value: option, label: option);
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
