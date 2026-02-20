import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:identiflora/account_utils.dart';
import 'package:identiflora/cache_utils.dart';
import 'package:identiflora/leaderboard_utils.dart';
import 'auth_objects.dart';
import 'environment.dart';

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
}) async {
  String apiBaseUrl = Environment.apiUrl;
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
    request.headers.set(
      HttpHeaders.authorizationHeader,
      'Bearer ${await getAuthToken()}',
    );
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
Future<String> getPlantSpeciesUrl({required String scientificName}) async {
  String apiBaseUrl = Environment.apiUrl;

  final trimmedName = scientificName.trim();
  if (trimmedName.isEmpty) {
    throw ArgumentError('scientificName must not be empty.');
  }

  final uri = Uri.parse(apiBaseUrl).resolve('/plant-species-url/$trimmedName');

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

//get the species id from scientific name
Future<int> getPlantSpeciesID({required String scientificName}) async {
  String apiBaseUrl = Environment.apiUrl;

  final trimmedName = scientificName.trim();
  if (trimmedName.isEmpty) {
    throw ArgumentError('scientificName must not be empty.');
  }

  final uri = Uri.parse(apiBaseUrl).resolve('/species-id/$trimmedName');

  final client = HttpClient();
  try {
    final request = await client.getUrl(uri);
    final response = await request.close();
    final responseBody = await utf8.decodeStream(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // FastAPI may return a raw string or JSON-string; handle both.
      final jsonResponse = jsonDecode(responseBody);
      final speciesId = jsonResponse['species_id'] as int;
      return speciesId;
    } 
    else {
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
Future<AuthToken> submitUserRegistration({
  required String email,
  required String username,
  required String passwordHash,
}) async {
  String apiBaseUrl = Environment.apiUrl;
  // Build the request URL for the FastAPI endpoint.
  final uri = Uri.parse(apiBaseUrl).resolve('/user/register');

  // Prepare JSON payload expected by the API.
  final payload = jsonEncode({
    'user_email': email,
    'username': username,
    'password_hash': passwordHash,
  });

  final httpClient = http.Client();
  try {
    // Create and send the POST request with JSON body.
    final response = await httpClient.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: payload,
    );

    // 200-299 indicates success
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
      return AuthToken.fromJson(jsonMap);
    }

    // Explicitly handle 401 Unauthorized
    if (response.statusCode == 401) {
      throw AuthException(
        'Invalid credentials: ${response.body}',
        statusCode: 401,
      );
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

/// Send a user login request to the API.
/// Can be used directly in a Flutter button:
///   onPressed: () => submitUserLogin(
///     email: emailVar,
///     passwordHash: hashVar
///   );

Future<AuthToken> submitUserLogin({
  required String email,
  required String passwordHash,
  required bool hasOTP
}) async {
  String apiBaseUrl = Environment.apiUrl;

  final uri = Uri.parse(apiBaseUrl).resolve('/user/login');

  // Start http client
  final httpClient = http.Client();

  try {
    final response = await httpClient.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_email': email, 'password_hash': passwordHash, 'has_otp': hasOTP}),
    );

    // 200-299 indicates success
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
      return AuthToken.fromJson(jsonMap);
    }

    // Explicitly handle 401 Unauthorized
    if (response.statusCode == 401) {
      throw AuthException(
        'Invalid credentials: ${response.body}',
        statusCode: 401,
      );
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

/// Send a leaderboard request to the API.
/// Can be used directly in a Flutter button:
///   onPressed: () => submitGlobalLeaderboardRequest(
///     size: 50
///   );
Future<List<LeaderboardUser>> submitGlobalLeaderboardRequest({
  required leaderboardSize
}) async {
  String apiBaseUrl = Environment.apiUrl;
  // Build the request URL for the FastAPI endpoint.
  final uri = Uri.parse(apiBaseUrl).resolve('/global-leaderboard');

  // Start http client
  final httpClient = http.Client();

  try {
    final response = await httpClient.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"leaderboard_size": leaderboardSize}),
    );

    // 200-299 indicates success
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
      List<LeaderboardUser> users = [];
      int count = 0;
      int? id;

      // Create user list from json response
      jsonMap.forEach((key, value) {
        id = int.tryParse(key);
        if(id == null) return;
        users.insert(count, LeaderboardUser(userName: value[0], userScore: value[1], userId: id!));
        count++;
      });
      
      return users;
    }

    // Explicitly handle 401 Unauthorized
    if (response.statusCode == 401) {
      throw AuthException(
        'Invalid credentials: ${response.body}',
        statusCode: 401,
      );
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

/// Send a user count request to the API.
/// Can be used directly in a Flutter button:
///   onPressed: () => fetchUserCount();
Future<int> fetchUserCount() async {
  String apiBaseUrl = Environment.apiUrl;
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

/// Send an update of user global points to the API.
/// Can be used directly in a Flutter button:
///   onPressed: () => submitIncorrectIdentification(
///     addPoints: points
///   );
Future<bool> submitUserGlobalPoints({required int addPoints}) async {
  final authToken = await getAuthToken();

  if (addPoints <= 0 || authToken == null) {
    return false;
  }

  String apiBaseUrl = Environment.apiUrl;
  // Build the request URL for the FastAPI endpoint.
  final uri = Uri.parse(apiBaseUrl).resolve('/add-global-user-pts');

  // Prepare JSON payload expected by the API.
  final payload = jsonEncode({
    'user_token': authToken,
    'add_points': addPoints,
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
      final success = jsonResponse['success'] as bool;
      return success;
    }
    // Return blank string if invalid username
    else if (response.statusCode == 404) {
      return false;
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

Future<AuthToken> submitUserGoogleLogin({
  required String token,
  required BuildContext context,
  String? username,
}) async {
  String apiBaseUrl = Environment.apiUrl;

  final uri = Uri.parse(apiBaseUrl).resolve('/google/auth');

  // Start http client
  final httpClient = http.Client();

  try {
    final response = await httpClient.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    // 200-299 indicates success
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;

      if (jsonMap.containsKey('register') && jsonMap['register'] as bool) {
        late final String username;

        if (context.mounted) {
          username = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ExternalSignUpForm()),
          );
        } else {
          username = "";
        }

        return await submitUserGoogleRegistration(
          token: jsonMap['access_token'],
          username: username,
        );
      }

      return AuthToken.fromJson(jsonMap);
    }

    // Explicitly handle 401 Unauthorized
    if (response.statusCode == 401) {
      throw AuthException(
        'Invalid credentials: ${response.body}',
        statusCode: 401,
      );
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

Future<AuthToken> submitUserGoogleRegistration({
  required String token,
  required String username,
}) async {
  String apiBaseUrl = Environment.apiUrl;

  final uri = Uri.parse(apiBaseUrl).resolve('/google/register');

  // Start http client
  final httpClient = http.Client();

  try {
    final response = await httpClient.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
      body: jsonEncode({"username": username}),
    );

    // 200-299 indicates success
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
      return AuthToken.fromJson(jsonMap);
    }

    // Explicitly handle 401 Unauthorized
    if (response.statusCode == 401) {
      throw AuthException(
        'Invalid credentials: ${response.body}',
        statusCode: 401,
      );
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

Future<bool> submitUserPasswordReset({
  required String email,
  required int otpLength
}) async {
  String apiBaseUrl = Environment.apiUrl;
  
  final uri = Uri.parse(apiBaseUrl).resolve('/pwd-reset/otp-request');

  // Start http client
  final httpClient = http.Client();

  try {
    final response = await httpClient.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"user_email": email, "otp_length": otpLength}),
    );

    // 200-299 indicates success
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
      return jsonMap['success'] as bool;
    }

    // Explicitly handle 401 Unauthorized and 403 Action Denied
    if (response.statusCode == 401) {
      throw AuthException(
        'Invalid credentials (user does not exist): ${response.body}',
        statusCode: 401,
      );
    }
    else if (response.statusCode == 403) {
      return false;
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


Future<int> submitUserOTPVerify({
  required String unhashedPassword,
  required String email
}) async {
  String apiBaseUrl = Environment.apiUrl;
  
  final uri = Uri.parse(apiBaseUrl).resolve('/pwd-reset/otp-check');

  // Start http client
  final httpClient = http.Client();

  try {
    final response = await httpClient.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"otp": unhashedPassword, "user_email": email}),
    );

    // 200-299 indicates success
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
      debugPrint(response.body);
      return jsonMap['result'] as int;
    }

    // Explicitly handle 401 Unauthorized
    if (response.statusCode == 401) {
      throw AuthException(
        'Invalid credentials: ${response.body}',
        statusCode: 401,
      );
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
