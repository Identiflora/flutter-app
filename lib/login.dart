import 'package:flutter/material.dart';


class LoginWidget extends StatefulWidget {
 const LoginWidget({super.key});


 @override
 State<LoginWidget> createState() =>_Login();
}


//CREATE CLASS FOR USER ACCOUNTS
class UserAccount {
 final String email; //cant be changed, like const
 final String username;
 final String password;


 //CONSTRUCTOR
 UserAccount({
   required this.email, //must be entered
   required this.username,
   required this.password,
 });


} //end UserAccount


//CREATE LIST FOR ACCOUNT CREDENTIALS OF USERACOUNT OBJECTS
List<UserAccount> userAccounts = [];






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
 final confirmController = TextEditingController();


 void signUp(){
   final email = emailControl.text.trim();
   final username = usernameControl.text.trim();
   final password = passwordControl.text.trim();
   final confirm = confirmController.text.trim();
  //CHECK IF PASSWORDS MATCH
 if (password != confirm){
   print("Passwords do not match, please correct");
   return;
 }


//ADDS USER CREDENTIALS TO LIST
 final newUser = UserAccount(
   email: email,
   username: username,
   password: password,
 );
 userAccounts.add(newUser);


 //PRINT USER CREDINTIALS TO CONSOLE
 print("New user has been signed up");
 print("Email is $email");
 print("Username is $username");
 print("password is $password");


 Navigator.pop(context);


 }//end sign up






@override
Widget build(BuildContext contex){
 return Column(
   children: [
     TextField(controller: emailControl, decoration: const InputDecoration(labelText: 'email')),
     const SizedBox(height: 16),


     TextField(controller: usernameControl, decoration: const InputDecoration(labelText: 'username')),
     const SizedBox(height: 16),


     TextField(controller: passwordControl, decoration: const InputDecoration(labelText: 'password')),
     const SizedBox(height: 16),


     TextField(controller: emailControl, decoration: const InputDecoration(labelText: 'confirm password')),
     const SizedBox(height: 16),
   ], 
 
 );


}




}//END SIGNUPFORMSTATE CLASS






 
