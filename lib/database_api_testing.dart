import 'package:flutter/material.dart';

import 'database_utils.dart';

//testing params for user registration
String username = "testUser-1", email = "testUser-1@unr.edu", passwordHash = "@!)!KAL@!()A:L<DWAEKL", passwordHash2 = "@!)!KAL@!";

Future<void> main(List<String> arguments) async {
  int registrationUserID = await submitUserRegistration(
    email: email, 
    username: username, 
    passwordHash: passwordHash
  );

  int userID = await submitUserLogin(
    email: email, 
    passwordHash: passwordHash
  );

  int userID2 = await submitUserLogin(
    email: email, 
    passwordHash: passwordHash2
  );

  String recievedUsername = await fetchUsername(
    userID: userID
  );

  String recievedUsername2 = await fetchUsername(
    userID: 1
  );

  // Test the results that are returned for other functionality
  debugPrint("Sign Up Result: $registrationUserID");
  debugPrint("Login Result: $userID");
  debugPrint("Wrong Credentials Login Result: $userID2");
  debugPrint("Username Result: $recievedUsername");
  debugPrint("SQL Test Username Result: $recievedUsername2");
}
