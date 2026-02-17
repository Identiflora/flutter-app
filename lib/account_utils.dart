import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:identiflora/database_utils.dart';
import 'package:identiflora/environment.dart';
import 'auth_objects.dart';
import 'cache_utils.dart';

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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
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
                style: const TextStyle(fontWeight: FontWeight.bold),
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
    final password = passwordControl.text.trim();

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

    //ADDED FOR PASS HASHING - USE CREATED FUNCT ABOVE
    final hashedPassword = hashPassword(password);
    try {
      final AuthToken token = await submitUserLogin(
        email: email,
        passwordHash: hashedPassword,
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
      GoogleSignIn.instance.initialize(clientId: Environment.googleClientID, serverClientId: Environment.googleServerID);
      final GoogleSignInAccount user = await GoogleSignIn.instance.authenticate();
      final GoogleSignInAuthentication auth = user.authentication;
      final String? googleToken = auth.idToken;
      if(googleToken != null && context.mounted) {
        final AuthToken token = await submitUserGoogleLogin(token: googleToken, context: context);
        await saveAuthToken(token.accessToken);
      }
    }
    catch (err) {
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

    if(context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Successfully logged in"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.popUntil(context, ModalRoute.withName("/"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: emailControl,
          decoration: const InputDecoration(
            labelText: "Email",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        TextField(
          controller: passwordControl,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: "Password",
            border: OutlineInputBorder(),
          ),
        ),
        ElevatedButton(onPressed: loginPressed, child: const Text("Login")),
        ElevatedButton.icon(onPressed: () => _handleGoogleSignIn(context), icon: Image.asset('assets/brand/Google_G_logo_500x500.png', width: 25, height: 25,), label: const Text("Sign in with Google"))
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

  void signUp() async {
    final email = emailControl.text.trim();
    final username = usernameControl.text.trim();
    final password = passwordControl.text.trim();
    final confirm = confirmControl.text.trim();

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

    //ONLY AFTER CONFIRMING PASSWORDS - HASH
    final hashedPassword = hashPassword(password);
    try {
      final AuthToken token = await submitUserRegistration(
        email: email,
        username: username,
        passwordHash: hashedPassword,
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

  @override
  Widget build(BuildContext contex) {
    return Column(
      children: [
        TextField(
          controller: emailControl,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        const SizedBox(height: 16),

        TextField(
          controller: usernameControl,
          decoration: const InputDecoration(labelText: 'Username'),
        ),
        const SizedBox(height: 16),

        TextField(
          controller: passwordControl,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Password'),
        ),
        const SizedBox(height: 16),

        TextField(
          controller: confirmControl,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Confirm Password'),
        ),
        const SizedBox(height: 16),

        ElevatedButton(onPressed: signUp, child: const Text("Sign Up")),
      ],
    );
  }
}//END SIGNUPFORMSTATE CLASS

// Sign up form for new external user
class ExternalSignUpForm extends StatelessWidget {
  final usernameControl = TextEditingController();

  ExternalSignUpForm({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How do we identify you?',),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 5.0,
        shadowColor: Theme.of(context).colorScheme.shadow, 
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Please enter a username so others know how to identify you!", 
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  color: Colors.black,
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
                  if(usernameControl.text.trim().isNotEmpty) {
                    Navigator.pop(context, usernameControl.text.trim());
                  }
                  else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Please make sure username has at least 1 character then try again."),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }, 
                child: const Text("Confirm")),
            ],
          ),
        ),
      ),
    );
  }
}






 
