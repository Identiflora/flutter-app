import 'package:flutter/material.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() =>_Login();
}

class _Login extends State<LoginWidget>{
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal:16),
          child: ElevatedButton(onPressed: () {
            Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(), 
                ),
            );
          }, 
          child: Text('Login'))
        )
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
      appBar: AppBar(
        title: Text(isLoginView 
        ? 'User Login' 
        : 'Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            isLoginView 
                ? const LoginForm()
                : const SignUpForm(),
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

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const TextField(
          decoration: InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        const TextField(
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: FractionallySizedBox(
            widthFactor: 0.5, 
            child: ElevatedButton(
              onPressed: () {
                // Implement actual login logic here
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('Login', style: TextStyle(fontSize: 18)),
            ),
          ),
        ),
      ],
    );
  }
}

class SignUpForm extends StatelessWidget {
  const SignUpForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const TextField(
          decoration: InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Username',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        const TextField(
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        const TextField(
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: FractionallySizedBox(
            widthFactor: 0.5, 
            child: ElevatedButton(
              onPressed: () {
                // Implement actual sign up logic here
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('Sign Up', style: TextStyle(fontSize: 18)),
            ),
          ),
        ),
      ],
    );
  }
}