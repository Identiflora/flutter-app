import 'package:flutter/material.dart';
import 'database_utils.dart';

//parameters for incorrect_identification
int identificationId = 1;
int correctSpeciesId = 2;
int incorrectSpeciesId = 3;
const apiBaseUrl = 'https://identiflora-api.onrender.com';
const sampleScientificName = 'test_sci_name';

//testing params for user registration
String username = "testUser-1", email = "testUser-1@unr.edu", passwordHash = "@!)!KAL@!()A:L<DWAEKL", passwordHash2 = "@!)!KAL@!";

Future<void> main(List<String> arguments) async {
  await _testSubmitIncorrectIdentification();
  await _testGetPlantSpeciesUrl();

  int registrationUserID = await submitUserRegistration(
    email: email, 
    username: username, 
    passwordHash: passwordHash,
    apiBaseUrl: apiBaseUrl
  );

  int userID = await submitUserLogin(
    email: email, 
    passwordHash: passwordHash,
    apiBaseUrl: apiBaseUrl
  );

  int userID2 = await submitUserLogin(
    email: email, 
    passwordHash: passwordHash2,
    apiBaseUrl: apiBaseUrl
  );

  String recievedUsername = await fetchUsername(
    userID: userID,
    apiBaseUrl: apiBaseUrl
  );

  String recievedUsername2 = await fetchUsername(
    userID: 2,
    apiBaseUrl: apiBaseUrl
  );

  int userPts = await fetchUserGlobalPts(
    userID: 2,
    apiBaseUrl: apiBaseUrl
  );

  int userCount = await fetchUserCount(
    apiBaseUrl: apiBaseUrl
  );

  // Test the results that are returned for other functionality
  debugPrint("Sign Up Result: $registrationUserID");
  debugPrint("Login Result: $userID");
  debugPrint("Wrong Credentials Login Result: $userID2");
  debugPrint("Username Result: $recievedUsername");
  debugPrint("SQL Test Username Result: $recievedUsername2");
  debugPrint("SQL Test User Pts: $userPts");
  debugPrint("SQL Test User Count: $userCount");
}

Future<void> _testSubmitIncorrectIdentification() async {
  try {
    final ok = await submitIncorrectIdentification(
      identificationId: identificationId,
      correctSpeciesId: correctSpeciesId,
      incorrectSpeciesId: incorrectSpeciesId,
      apiBaseUrl: apiBaseUrl,
    );
    debugPrint('submitIncorrectIdentification success: $ok');
  } catch (err) {
    debugPrint('submitIncorrectIdentification failed: $err');
  }
}

Future<void> _testGetPlantSpeciesUrl() async {
  try {
    final url = await getPlantSpeciesUrl(
      scientificName: sampleScientificName,
      apiBaseUrl: apiBaseUrl,
    );
    debugPrint('getPlantSpeciesUrl returned: $url');
  } catch (err) {
    debugPrint('getPlantSpeciesUrl failed: $err');
  }
}
