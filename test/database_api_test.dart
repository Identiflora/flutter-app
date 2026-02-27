// import 'package:flutter/material.dart';
import 'package:identiflora/database_utils.dart';
import 'package:test/test.dart';

//parameters for incorrect_identification
int identificationId = 1;
int correctSpeciesId = 2;
int incorrectSpeciesId = 3;
const testApiBaseUrl = 'http://localhost:8000';
const sampleScientificName = 'test_sci_name';

//testing params for user registration
String username = "testUser-1",
    email = "testUser-1@unr.edu",
    passwordHash = "@!)!KAL@!()A:L<DWAEKL",
    passwordHash2 = "@!)!KAL@!";

Future<void> main(List<String> arguments) async {
  // await _testSubmitIncorrectIdentification();
  // await _testGetPlantSpeciesUrl();
  await _testUserAuthentication();

  // int registrationUserID = await submitUserRegistration(
  //   email: email,
  //   username: username,
  //   passwordHash: passwordHash,
  //   apiBaseUrl: testApiBaseUrl,
  // );

  // int userID = await submitUserLogin(
  //   email: email,
  //   passwordHash: passwordHash,
  //   apiBaseUrl: testApiBaseUrl,
  // );

  // int userID2 = await submitUserLogin(
  //   email: email,
  //   passwordHash: passwordHash2,
  //   apiBaseUrl: testApiBaseUrl,
  // );

  // String recievedUsername = await fetchUsername(
  //   userID: userID,
  //   apiBaseUrl: testApiBaseUrl,
  // );

  // String recievedUsername2 = await fetchUsername(
  //   userID: 2,
  //   apiBaseUrl: testApiBaseUrl,
  // );

  // int userPts = await fetchUserGlobalPts(userID: 2, apiBaseUrl: testApiBaseUrl);

  // int userCount = await fetchUserCount(apiBaseUrl: testApiBaseUrl);

  // // Test the results that are returned for other functionality
  // debugPrint("Sign Up Result: $registrationUserID");
  // debugPrint("Login Result: $userID");
  // debugPrint("Wrong Credentials Login Result: $userID2");
  // debugPrint("Username Result: $recievedUsername");
  // debugPrint("SQL Test Username Result: $recievedUsername2");
  // debugPrint("SQL Test User Pts: $userPts");
  // debugPrint("SQL Test User Count: $userCount");
}

// Future<void> _testSubmitIncorrectIdentification() async {
//   try {
//     final ok = await submitIncorrectIdentification(
//       identificationId: identificationId,
//       correctSpeciesId: correctSpeciesId,
//       incorrectSpeciesId: incorrectSpeciesId,
//       apiBaseUrl: testApiBaseUrl,
//     );
//     debugPrint('submitIncorrectIdentification success: $ok');
//   } catch (err) {
//     debugPrint('submitIncorrectIdentification failed: $err');
//   }
// }

// Future<void> _testGetPlantSpeciesUrl() async {
//   try {
//     final url = await getPlantSpeciesUrl(
//       scientificName: sampleScientificName,
//       apiBaseUrl: testApiBaseUrl,
//     );
//     debugPrint('getPlantSpeciesUrl returned: $url');
//   } catch (err) {
//     debugPrint('getPlantSpeciesUrl failed: $err');
//   }
// }

Future<void> _testUserAuthentication() async {
  //register test user
  try {
    final ok = await submitUserRegistration(
      email: "test_email_1@ya.ya",
      username: "test_username_1",
      passwordHash: "test_password_hash_1",
      apiBaseUrl: testApiBaseUrl,
    );
    print('user registration success: $ok');
  } catch (err) {
    print('user registration failed: $err');
  }

  //login test user with correct credentials
  try {
    final ok = await submitUserLogin(
      email: "test_email_1@ya.ya",
      passwordHash: "test_password_hash_1",
      apiBaseUrl: testApiBaseUrl,
    );
    print('user login success: ${ok.toString()}');
  } catch (err) {
    print('user login failed: $err');
  }

  //login test user with incorrect email
  try {
    final ok = await submitUserLogin(
      email: "wrong_email@in.com",
      passwordHash: "test_password_hash_1",
      apiBaseUrl: testApiBaseUrl,
    );
    print('user login success: ${ok.toString()}');
  } catch (err) {
    print('user login failed: $err');
  }

  //login test user with incorrect password
  try {
    final ok = await submitUserLogin(
      email: "wrong_email@in.com",
      passwordHash: "incorrect_hash_1",
      apiBaseUrl: testApiBaseUrl,
    );
    print('user login success: ${ok.toString()}');
  } catch (err) {
    print('user login failed: $err');
  }
}
