import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:identiflora/leaderboard.dart';


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

//ALLOWS ON SCREEN BUTTON TO PRINT ACCOUNT LIST TO CONSOLE
@override
String toString(){
  return 'User(email: $email, username: $username, password: $password)';
}

} //end UserAccount



//CREATE LIST FOR ACCOUNT CREDENTIALS OF USERACOUNT OBJECTS
List<UserAccount> userAccounts = [];

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

/*  COMMENTING OUT BCS USER ACCOUNTS NOW VIEWABLE
    VIA THE LEADERBOARD
          ElevatedButton(
            onPressed: (){
              print("Curresnt Users:");
              for (var user in userAccounts){
                print(user);
              }
            },
            child: const Text("View all current users")
          )
*/

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

    Future<bool> passwordCheckViaApi(String email, String password) async{ //Future-value comes from api
      await Future.delayed(const Duration(seconds:1)); //awaits for api
      return password == "password"; //temp password
    } //end class

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
  final bool valid = await passwordCheckViaApi(email, hashedPassword);

  if (valid) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Successfully logged in"),
      backgroundColor: Colors.green,  
      ),
    ); 
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


 void signUp(){
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

  print(userAccounts);

//ONLY AFTER CONFIRMING PASSWORDS - HASH 
final hashedPassword = hashPassword(password);

//ADDS USER CREDENTIALS TO LIST
 final newUser = UserAccount(
   email: email,
   username: username,
   password: hashedPassword,
 );
 userAccounts.add(newUser);

//ADD NEW USER TO RANDOM SPOT ON LEADERBOARD
 LeaderBoardControl.addUser(
  LeaderboardUser(userName: username)
 );


 //PRINT USER CREDINTIALS TO CONSOLE
 print("New user has been signed up");
 print("Email is $email");
 print("Username is $username");
 print("password is $hashedPassword");


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


     TextField(controller: passwordControl, obscureText: true, decoration: const InputDecoration(labelText: 'password')),
     const SizedBox(height: 16),


     TextField(controller:  confirmControl, 
     obscureText: true,
     decoration: const InputDecoration(labelText: 'confirm password')),
     const SizedBox(height: 16),

    ElevatedButton(
      onPressed: signUp,
      child: const Text("Sign Up"),

    )

   ], 
 
 );


}




}//END SIGNUPFORMSTATE CLASS






 
