import 'dart:async';

import 'package:flutter/material.dart';
import 'package:identiflora/database_utils.dart';
import 'package:identiflora/theme/general_utils.dart';
import 'package:identiflora/user_credentials/account_utils.dart';
import '../auth_objects.dart';
import '../cache_utils.dart';
import 'package:identiflora/widgets/neon_widgets.dart';

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

/// Sign up form for new external user
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