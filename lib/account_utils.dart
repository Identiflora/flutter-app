import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:identiflora/database_utils.dart';

class LoginWidget extends StatefulWidget {
 const LoginWidget({super.key});

 @override
 State<LoginWidget> createState() =>_Login();
}

//HASH ACCOUNT PASSWORDS FUNCT
String hashPassword(String password){
  final bytes = utf8.encode(password); //TURN PASS INTO BYTES
  final digest = sha256.convert(bytes); //APPLY HASHING
  return digest.toString(); //RETURN HASHED STRING
}

class _Login extends State<LoginWidget>{
 @override
 Widget build(BuildContext context) {
   return SafeArea(
     child: Align(
       alignment: Alignment.topLeft,
       child: Padding(
         padding: const EdgeInsets.symmetric(horizontal:16),
         child: GestureDetector(
          onTap: () {
           Navigator.push(
               context,
               MaterialPageRoute(
                 builder: (context) => const LoginScreen(),
               ),
           );
         },
         child: Image.asset('assets/homepage/account_icon.png', width: 80, height: 80))
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
    
    if (email.isEmpty || password.isEmpty){   
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields"),
        backgroundColor: Colors.red,
      ),
      );
     //CHECKS FOR EMPTY FIELDS
     return;
  } //END FUNCT

//ADDED FOR PASS HASHING - USE CREATED FUNCT ABOVE
  final hashedPassword = hashPassword(password);
  final int userID = await submitUserLogin(email: email , passwordHash: hashedPassword);
  //LINE ABOVE ASSIGNED -1 IF USERID EXITS

  if (userID > 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Successfully logged in"),
      backgroundColor: Colors.green,  
      ),
    ); 
    Navigator.pop(context);
  } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Incorrect email or password"),
        backgroundColor: Colors.red,
        ),
      );
    }
  } //END IFELSE

@override
Widget build(BuildContext context){
  return Column(
    children: [
      TextField(controller: emailControl,
      decoration: const InputDecoration(
        labelText: "Email", border: OutlineInputBorder(),
      ),   
      ),
    const SizedBox(height: 16),   
    
    TextField(
      controller: passwordControl,
      obscureText: true,
      decoration: const InputDecoration( labelText: "Password",
      border: OutlineInputBorder(),
      ),
    ),
    ElevatedButton (
      onPressed: loginPressed,
      child: const Text("Login"),
      ), 
     ]
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
class _SignUpFormState extends State<SignUpForm>{
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
 if (password != confirm){
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: 
    Text("Password do not match, please correct"),
    backgroundColor: Colors.red,
    ),
  );
   return;
 } //END SIGNUP 


//ONLY AFTER CONFIRMING PASSWORDS - HASH 
final hashedPassword = hashPassword(password);

//ADDS USER CREDENTIALS TO LIST
 final int userID = await submitUserRegistration(email: email, username: username, passwordHash: hashedPassword);
//RETURNS -1 IF DUPLICATE ACCOUNT
if (userID <= 0){
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: 
    Text("Account already exists"),
    backgroundColor: Colors.red,
    ),
  );
   return;
 } else {
     Navigator.pop(context);
 }


 }//end sign up






@override
Widget build(BuildContext contex){
 return Column(
   children: [
     TextField(controller: emailControl, decoration: const InputDecoration(labelText: 'Email')),
     const SizedBox(height: 16),


     TextField(controller: usernameControl, decoration: const InputDecoration(labelText: 'Username')),
     const SizedBox(height: 16),


     TextField(controller: passwordControl, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
     const SizedBox(height: 16),


     TextField(controller:  confirmControl, 
     obscureText: true,
     decoration: const InputDecoration(labelText: 'Confirm Password')),
     const SizedBox(height: 16),

    ElevatedButton(
      onPressed: signUp,
      child: const Text("Sign Up"),

    )

   ], 
 
 );


}




}//END SIGNUPFORMSTATE CLASS






 
