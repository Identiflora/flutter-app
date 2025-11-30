import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

import 'database_utils.dart';

//parameters for incorrect_identification
int identificationId = 1;
int correctSpeciesId = 2;
int incorrectSpeciesId = 3;
// String api_url =

//testing params for user registration
String username = "testUser-1", email = "testUser-1@unr.edu", passwordHash = "@!)!KAL@!()A:L<DWAEKL", passwordHash2 = "@!)!KAL@!";

Future<void> main(List<String> arguments) async {
  submitIncorrectIdentification(
    identificationId: identificationId,
    correctSpeciesId: correctSpeciesId,
    incorrectSpeciesId: incorrectSpeciesId,
  );

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

  // Test the results that are returned for other functionality
  debugPrint("Sign Up Result: $registrationUserID");
  debugPrint("Login Result: $userID");
  debugPrint("Wrong Credentials Login Result: $userID2");
}
