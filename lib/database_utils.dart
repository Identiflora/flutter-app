import 'dart:convert';
import 'dart:io';

/// Send an incorrect-identification report to the API.
/// Can be used directly in a Flutter button:
///   onPressed: () => submitIncorrectIdentification(
///     identificationId: 1,
///     correctSpeciesId: 2,
///     incorrectSpeciesId: 3,
///   );
Future<bool> submitIncorrectIdentification({
  required int identificationId,
  required int correctSpeciesId,
  required int incorrectSpeciesId,
  String apiBaseUrl = 'http://localhost:8000',
}) async {
  // Build the request URL for the FastAPI endpoint.
  final uri = Uri.parse(apiBaseUrl).resolve('/incorrect-identifications');

  // Prepare JSON payload expected by the API.
  final payload = jsonEncode({
    'identification_id': identificationId,
    'correct_species_id': correctSpeciesId,
    'incorrect_species_id': incorrectSpeciesId,
  });

  final client = HttpClient();
  try {
    // Create and send the POST request with JSON body.
    final request = await client.postUrl(uri);
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.add(utf8.encode(payload));

    // Await the response and read the body for error context.
    final response = await request.close();
    final responseBody = await utf8.decodeStream(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    } else {
      // Surface the response for debugging purposes.
      throw HttpException(
        'API error ${response.statusCode}: $responseBody',
        uri: uri,
      );
    }
  } finally {
    // Ensure the HTTP client is closed even if an error occurs.
    client.close(force: true);
  }
}

/// Send a user registration to the API.
/// Can be used directly in a Flutter button:
///   onPressed: () => submitUserRegistration(
///     email: emailVar, 
///     username: usernameVar, 
///     passwordHash: hashVar
///   );
Future<bool> submitUserRegistration({
  required String email,
  required String username,
  required String passwordHash,
  String apiBaseUrl = 'http://localhost:8000',
}) async {
  // Build the request URL for the FastAPI endpoint.
  final uri = Uri.parse(apiBaseUrl).resolve('/user');

  // Prepare JSON payload expected by the API.
  final payload = jsonEncode({
    'user_email': email,
    'username': username,
    'password_hash': passwordHash,
  });

  final client = HttpClient();
  try {
    // Create and send the POST request with JSON body.
    final request = await client.postUrl(uri);
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.add(utf8.encode(payload));

    // Await the response and read the body for error context.
    final response = await request.close();
    final responseBody = await utf8.decodeStream(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    }
    // Return false if duplicate at any point is found
    else if (response.statusCode == 409){
      return false;
    }
    else {
      // Surface the response for debugging purposes.
      throw HttpException(
        'API error ${response.statusCode}: $responseBody',
        uri: uri,
      );
    }
  } finally {
    // Ensure the HTTP client is closed even if an error occurs.
    client.close(force: true);
  }
}