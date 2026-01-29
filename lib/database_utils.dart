import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'auth_objects.dart';

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
    // API expects the query param to be named "scientific_name"
    queryParameters: {'scientific_name': trimmedName},
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
    else if (response.statusCode == 409) {
      return -1;
    } else {
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

Future<AuthToken> submitUserLogin({
  required String email,
  required String passwordHash,
  String apiBaseUrl = 'https://identiflora-api.onrender.com'
}) async {
  final uri = Uri.parse(apiBaseUrl).resolve('/user/login');

  // Start http client
  final httpClient = http.Client();

  try {
    final response = await httpClient.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_email': email, 'password_hash': passwordHash}),
    );

    // 200-299 indicates success
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
      return AuthToken.fromJson(jsonMap);
    }

    // Explicitly handle 401 Unauthorized
    if (response.statusCode == 401) {
      throw AuthException('Invalid credentials', statusCode: 401);
    }

    // Handle other non-200 errors
    throw AuthException(
      'Server error: ${response.body}',
      statusCode: response.statusCode,
    );
  } catch (e) {
    // Catch generic errors (like no internet) and rethrow as AuthException
    // or let them bubble up if they are already handled.
    if (e is AuthException) rethrow;
    throw AuthException('Network error occurred: $e');
  } finally {
    // close out http client
    httpClient.close();
  }
}
// Future<dynamic> submitUserLogin({
//   required String email,
//   required String passwordHash,
//   String apiBaseUrl = 'https://identiflora-api.onrender.com',
// }) async {
//   // Build the request URL for the FastAPI endpoint.
//   final uri = Uri.parse(apiBaseUrl).resolve('/user/login');

//   // Prepare JSON payload expected by the API.
//   final payload = jsonEncode({
//     'user_email': email,
//     'password_hash': passwordHash,
//   });

//   final client = HttpClient();
//   try {
//     // Create and send the POST request with JSON body.
//     final request = await client.postUrl(uri);
//     request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
//     request.add(utf8.encode(payload));

//     // Await the response and read the body for error context.
//     final response = await request.close();
//     final responseBody = await utf8.decodeStream(response);

//     if (response.statusCode >= 200 && response.statusCode < 300) {
//       final jsonResponse = jsonDecode(responseBody);
//       // final userID = jsonResponse['user_id'] as int;
//       return jsonResponse; // need to edit function to determine what we will be returning at user login. Ideally return json object if possible, or just token.
//     }
//     // Return -1 if invalid user
//     else if (response.statusCode == 401){
//       return -1;
//     }
//     else {
//       // Surface other responses for debugging purposes.
//       throw HttpException(
//         'API error ${response.statusCode}: $responseBody',
//         uri: uri,
//       );
//     }
//   } finally {
//     // Ensure the HTTP client is closed even if an error occurs.
//     client.close(force: true);
//   }
// }

/// Send a username fetch request to the API.
/// Can be used directly in a Flutter button:
///   onPressed: () => fetchUsername(
///     userID: IDVar
///   );
Future<String> fetchUsername({
  required int userID,
  String apiBaseUrl = 'https://identiflora-api.onrender.com',
}) async {
  // Build the request URL for the FastAPI endpoint.
  final uri = Uri.parse(apiBaseUrl).resolve('/username/$userID');

  final client = HttpClient();
  try {
    // Create and send the GET request with JSON body.
    final request = await client.getUrl(uri);

    // Await the response and read the body for error context.
    final response = await request.close();
    final responseBody = await utf8.decodeStream(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonResponse = jsonDecode(responseBody);
      final username = jsonResponse['username'] as String;
      return username;
    }
    // Return blank string if invalid username
    else if (response.statusCode == 404) {
      return "";
    } else {
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

/// Send a user point fetch request to the API.
/// Can be used directly in a Flutter button:
///   onPressed: () => fetchUserGlobalPts(
///     userID: IDVar
///   );
Future<int> fetchUserGlobalPts({
  required int userID,
  String apiBaseUrl = 'https://identiflora-api.onrender.com',
}) async {
  // Build the request URL for the FastAPI endpoint.
  final uri = Uri.parse(apiBaseUrl).resolve('/user-pts/$userID');

  final client = HttpClient();
  try {
    // Create and send the GET request with JSON body.
    final request = await client.getUrl(uri);

    // Await the response and read the body for error context.
    final response = await request.close();
    final responseBody = await utf8.decodeStream(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonResponse = jsonDecode(responseBody);
      final userPts = jsonResponse['pts'] as int;
      return userPts;
    }
    // Return blank string if invalid username
    else if (response.statusCode == 404) {
      return -1;
    } else {
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

/// Send a user count request to the API.
/// Can be used directly in a Flutter button:
///   onPressed: () => fetchUserCount();
Future<int> fetchUserCount({
  String apiBaseUrl = 'https://identiflora-api.onrender.com',
}) async {
  // Build the request URL for the FastAPI endpoint.
  final uri = Uri.parse(apiBaseUrl).resolve('/user-count');

  final client = HttpClient();
  try {
    // Create and send the POST request with JSON body.
    final request = await client.postUrl(uri);

    // Await the response and read the body for error context.
    final response = await request.close();
    final responseBody = await utf8.decodeStream(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonResponse = jsonDecode(responseBody);
      final userCount = jsonResponse['user_count'] as int;
      return userCount;
    }
    // Return blank string if invalid username
    else if (response.statusCode == 404) {
      return -1;
    } else {
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
