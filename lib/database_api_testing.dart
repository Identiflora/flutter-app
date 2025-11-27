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
String username = "testUser-1";
String email = "testUser-1@unr.edu";
String passwordHash = "@!)!KAL@!()A:L<DWAEKL";

Future<void> main(List<String> arguments) async {
  submitIncorrectIdentification(
    identificationId: identificationId,
    correctSpeciesId: correctSpeciesId,
    incorrectSpeciesId: incorrectSpeciesId,
  );

  bool registrationResult = await submitUserRegistration(
    email: email, 
    username: username, 
    passwordHash: passwordHash
  );

  // Test that result is returned for other functionality
  debugPrint("Result: $registrationResult");
}
