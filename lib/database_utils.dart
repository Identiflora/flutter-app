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
  String apiBaseUrl = 'https://identiflora-api.onrender.com',
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

/// Fetch the image URL for a plant species using its scientific name.
/// Returns the resolved URL as a string or throws an [HttpException] on API errors.
Future<String> getPlantSpeciesUrl({
  required String scientificName,
  String apiBaseUrl = 'https://identiflora-api.onrender.com',
}) async {
  final trimmedName = scientificName.trim();
  if (trimmedName.isEmpty) {
    throw ArgumentError('scientificName must not be empty.');
  }

  final base = Uri.parse(apiBaseUrl);
  final uri = Uri(
    scheme: base.scheme, // preserve http/https from provided base
    host: base.host, // reuse host from base URL
    port: base.hasPort ? base.port : null, // carry port if present
    path: base.path.endsWith('/')
        ? '${base.path}plant-species-url'
        : '${base.path}/plant-species-url', // append endpoint safely
    queryParameters: {'sci_name': trimmedName}, // pass scientific name as query param
  );

  final client = HttpClient();
  try {
    final request = await client.getUrl(uri);
    final response = await request.close();
    final responseBody = await utf8.decodeStream(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // FastAPI may return a raw string or JSON-string; handle both.
      try {
        final decoded = jsonDecode(responseBody);
        if (decoded is String) {
          return decoded;
        }
      } catch (_) {
        // Fall through to returning the raw body.
      }
      return responseBody;
    } else {
      throw HttpException(
        'API error ${response.statusCode}: $responseBody',
        uri: uri,
      );
    }
  } finally {
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
Future<int> submitUserRegistration({
  required String email,
  required String username,
  required String passwordHash,
  String apiBaseUrl = 'https://identiflora-api.onrender.com',
}) async {
  // Build the request URL for the FastAPI endpoint.
  final uri = Uri.parse(apiBaseUrl).resolve('/user/register');

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
      final jsonResponse = jsonDecode(responseBody);
      final userID = jsonResponse['user_id'] as int;
      return userID;
    }
    // Return false if duplicate at any point is found
    else if (response.statusCode == 409){
      return -1;
    }
    else {
      // Surface other responses for debugging purposes.
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

/// Send a user login request to the API.
/// Can be used directly in a Flutter button:
///   onPressed: () => submitUserLogin(
///     email: emailVar, 
///     passwordHash: hashVar
///   );
Future<int> submitUserLogin({
  required String email,
  required String passwordHash,
  String apiBaseUrl = 'https://identiflora-api.onrender.com',
}) async {
  // Build the request URL for the FastAPI endpoint.
  final uri = Uri.parse(apiBaseUrl).resolve('/user/login');

  // Prepare JSON payload expected by the API.
  final payload = jsonEncode({
    'user_email': email,
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
      final jsonResponse = jsonDecode(responseBody);
      final userID = jsonResponse['user_id'] as int;
      return userID;
    }
    // Return -1 if invalid user
    else if (response.statusCode == 401){
      return -1;
    }
    else {
      // Surface other responses for debugging purposes.
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

/// Send a username fetch request to the API.
/// Can be used directly in a Flutter button:
///   onPressed: () => fetchUsername(
///     uderID: IDVar
///   );
Future<String> fetchUsername({
  required int userID,
  String apiBaseUrl = 'https://identiflora-api.onrender.com',
}) async {
  // Build the request URL for the FastAPI endpoint.
  final uri = Uri.parse(apiBaseUrl).resolve('/user/$userID');

  final client = HttpClient();
  try {
    // Create and send the POST request with JSON body.
    final request = await client.getUrl(uri);

    // Await the response and read the body for error context.
    final response = await request.close();
    final responseBody = await utf8.decodeStream(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonResponse = jsonDecode(responseBody);
      final username = jsonResponse['username'] as String;
      return username;
    }
    // Return -1 if invalid user
    else if (response.statusCode == 404){
      return "";
    }
    else {
      // Surface other responses for debugging purposes.
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