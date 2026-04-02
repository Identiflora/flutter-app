import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:identiflora/user_data/cache_utils.dart';
import 'package:identiflora/leaderboard_utils.dart';
import 'package:identiflora/user_credentials/sign_up.dart';
import 'user_credentials/auth_objects.dart';
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

  final httpClient = http.Client();
  try {
    // Create and send the POST request with JSON body.
    final response = await httpClient.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getAuthToken()}',
      },
      body: payload,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    } else {
      // Surface the response for debugging purposes.
      throw HttpException(
        'API error ${response.statusCode}: ${response.body}',
        uri: uri,
      );
    }
  } finally {
    // Ensure the HTTP httpClient is closed.
    httpClient.close();
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

  final httpClient = http.Client();
  try {
    final response = await httpClient.get(uri);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // FastAPI may return a raw string or JSON-string; handle both.
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is String) {
          return decoded;
        }
      } catch (_) {
        // Fall through to returning the raw body.
      }
      return response.body;
    } else {
      throw HttpException(
        'API error ${response.statusCode}: ${response.body}',
        uri: uri,
      );
    }
  } finally {
    httpClient.close();
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

  final httpClient = http.Client();
  try {
    final response = await httpClient.get(uri);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // FastAPI may return a raw string or JSON-string; handle both.
      final jsonResponse = jsonDecode(response.body);
      final speciesId = jsonResponse['species_id'] as int;
      return speciesId;
    } else {
      throw HttpException(
        'API error ${response.statusCode}: ${response.body}',
        uri: uri,
      );
    }
  } finally {
    httpClient.close();
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
  required String region,
}) async {
  String apiBaseUrl = Environment.apiUrl;
  // Build the request URL for the FastAPI endpoint.
  final uri = Uri.parse(apiBaseUrl).resolve('/user/register');

  // Prepare JSON payload expected by the API.
  final payload = jsonEncode({
    'user_email': email,
    'username': username,
    'region': region,
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
    // close out http httpClient
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
  required bool hasOTP,
}) async {
  String apiBaseUrl = Environment.apiUrl;

  final uri = Uri.parse(apiBaseUrl).resolve('/user/login');

  // Start http httpClient
  final httpClient = http.Client();

  try {
    final response = await httpClient.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_email': email,
        'password_hash': passwordHash,
        'has_otp': hasOTP,
      }),
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
    // close out http httpClient
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

//   final httpClient = HttpClient();
//   try {
//     // Create and send the POST request with JSON body.
//     final request = await httpClient.postUrl(uri);
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
//     // Ensure the HTTP httpClient is closed even if an error occurs.
//     httpClient.close(force: true);
//   }
// }

/// Send a leaderboard request to the API.
/// Can be used directly in a Flutter button:
///   onPressed: () => submitGlobalLeaderboardRequest(
///     size: 50
///   );
Future<List<LeaderboardUser>> submitGlobalLeaderboardRequest({
  required int leaderboardSize,
}) async {
  String apiBaseUrl = Environment.apiUrl;
  // Build the request URL for the FastAPI endpoint.
  final uri = Uri.parse(apiBaseUrl).resolve('/global-leaderboard');

  // Start http httpClient
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
        if (id == null) return;
        users.insert(
          count,
          LeaderboardUser(userName: value[0], userScore: value[1], displayedBadgeFilePath: value[2], userId: id!),
        );
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
    // close out http httpClient
    httpClient.close();
  }
}

/// Send a leaderboard request to the API.
/// Can be used directly in a Flutter button:
///   onPressed: () => submitFriendsLeaderboardRequest(
///     size: 50
///   );
Future<List<LeaderboardUser>> submitFriendsLeaderboardRequest({
  required int leaderboardSize,
}) async {
  String apiBaseUrl = Environment.apiUrl;
  // Build the request URL for the FastAPI endpoint.
  final uri = Uri.parse(apiBaseUrl).resolve('/friends-leaderboard');

  // Start http httpClient
  final httpClient = http.Client();

  try {
    final response = await httpClient.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getAuthToken()}',
      },
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
        if (id == null) return;
        users.insert(
          count,
          LeaderboardUser(userName: value[0], userScore: value[1], displayedBadgeFilePath: value[2], userId: id!),
        );
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
    // close out http httpClient
    httpClient.close();
  }
}

// Send a regional leaderboard request to the API.
/// Can be used directly in a Flutter button:
///   onPressed: () => submitRegionalLeaderboardRequest(
///     size: 50
///   );
Future<List<LeaderboardUser>> submitRegionalLeaderboardRequest({
  required int leaderboardSize,
}) async {
  String apiBaseUrl = Environment.apiUrl;
  // Build the request URL for the FastAPI endpoint.
  final uri = Uri.parse(apiBaseUrl).resolve('/regional-leaderboard');

  // Start http httpClient
  final httpClient = http.Client();

  try {
    final response = await httpClient.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getAuthToken()}',
      },
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
        if (id == null) return;
        users.insert(
          count,
          LeaderboardUser(userName: value[0], userScore: value[1], displayedBadgeFilePath: value[2], userId: id!),
        );
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
    // close out http httpClient
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

  final httpClient = http.Client();
  try {
    final response = await httpClient.get(
      uri,
      headers: {'Authorization': 'Bearer ${await getAuthToken()}'},
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonResponse = jsonDecode(response.body);
      final userCount = jsonResponse['user_count'] as int;
      return userCount;
    }
    // Return blank string if invalid username
    else if (response.statusCode == 404) {
      return -1;
    } else {
      // Surface other responses for debugging purposes.
      throw HttpException(
        'API error ${response.statusCode}: ${response.body}',
        uri: uri,
      );
    }
  } finally {
    // Ensure the HTTP httpClient is closed even if an error occurs.
    httpClient.close();
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
    'add_points': addPoints,
  });

  final httpClient = http.Client();
  try {
    final response = await httpClient.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: payload,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonResponse = jsonDecode(response.body);
      final success = jsonResponse as bool;
      return success;
    }
    // Return blank string if invalid username
    else if (response.statusCode == 404) {
      return false;
    } else {
      // Surface other responses for debugging purposes.
      throw HttpException(
        'API error ${response.statusCode}: ${response.body}',
        uri: uri,
      );
    }
  } finally {
    // Ensure the HTTP httpClient is closed even if an error occurs.
    httpClient.close();
  }
}

/// Sends a new Google login request to the API.
/// Can be used directly in a Flutter button:
///   onPressed: () => submitUserGoogleLogin(
///     token: googleToken,
///     context: buttonBuildContext,
///     username: username
///   );
Future<AuthToken> submitUserGoogleLogin({
  required String token,
  required BuildContext context,
  String? username,
}) async {
  String apiBaseUrl = Environment.apiUrl;

  final uri = Uri.parse(apiBaseUrl).resolve('/google/auth');

  // Start http httpClient
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
        late final List<String> userInfo;

        if (context.mounted) {
          userInfo = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ExternalSignUpForm()),
          );
        } 
        else {
          userInfo = ["", ""];
        }

        return await submitUserGoogleRegistration(
          token: jsonMap['access_token'],
          username: userInfo[0],
          region: userInfo[1]
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
    // close out http httpClient
    httpClient.close();
  }
}

/// Registers new users found via Google login.<br>
/// This submission is automatically called from Google login and should not be used otherwise.
Future<AuthToken> submitUserGoogleRegistration({
  required String token,
  required String username,
  required String region
}) async {
  String apiBaseUrl = Environment.apiUrl;

  final uri = Uri.parse(apiBaseUrl).resolve('/google/register');

  // Start http httpClient
  final httpClient = http.Client();

  try {
    final response = await httpClient.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
      body: jsonEncode({"username": username, "region": region}),
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
    // close out http httpClient
    httpClient.close();
  }
}

/// Sends a user password request to the API.
/// Can be used directly in a Flutter button:
///   onPressed: () => submitUserPasswordReset(
///     email: user_email,
///     otpLength: randomInt
///   );
Future<bool> submitUserPasswordReset({
  required String email,
  required int otpLength,
}) async {
  String apiBaseUrl = Environment.apiUrl;

  final uri = Uri.parse(apiBaseUrl).resolve('/pwd-reset/otp-request');

  // Start http httpClient
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
    } else if (response.statusCode == 403) {
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
    // close out http httpClient
    httpClient.close();
  }
}

/// Sends a user one time password (OTP) verification to the API.<br>
/// This should be called automatically upon user login to verify if they are using an OTP
Future<int> submitUserOTPVerify({
  required String unhashedPassword,
  required String email,
}) async {
  String apiBaseUrl = Environment.apiUrl;

  final uri = Uri.parse(apiBaseUrl).resolve('/pwd-reset/otp-check');

  // Start http httpClient
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
    // close out http httpClient
    httpClient.close();
  }
}

// returns true if users token is valid, false otherwise
Future<bool> authenticateToken() async {
  String apiBaseUrl = Environment.apiUrl;
  // Build the request URL for the FastAPI endpoint.
  final uri = Uri.parse(apiBaseUrl).resolve('/authenticate-token');

  final httpClient = http.Client();
  try {
    String? token = await getAuthToken();
    debugPrint("AuthToken: $token");
    if (token == null) {
      return false;
    }
    final response = await httpClient.post(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    }
    // 401 means token is invalid or expired, return false so user can be brought to login screen
    else if (response.statusCode == 401) {
      return false;
    } else if (response.statusCode == 429) {
      throw RateLimitException();
    } else {
      // Surface the response for debugging purposes.
      throw HttpException(
        'API error ${response.statusCode}: ${response.body}',
        uri: uri,
      );
    }
  } finally {
    // Ensure the HTTP httpClient is closed even if an error occurs.
    httpClient.close();
  }
}

//get the current users points
Future<int> getUserPoints() async {
  String apiBaseUrl = Environment.apiUrl;
  // Build the request URL for the FastAPI endpoint.
  final uri = Uri.parse(apiBaseUrl).resolve('/user-points');

  final httpClient = http.Client();
  try {
    final response = await httpClient.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getAuthToken()}'
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonResponse = jsonDecode(response.body);
      final userPoints = jsonResponse as int;
      return userPoints;
    } else if (response.statusCode == 404) {
      return 0; //return 0 points if not found
    } else {
      // Surface the response for debugging purposes.
      throw HttpException(
        'API error ${response.statusCode}: ${response.body}',
        uri: uri,
      );
    }
  } finally {
    // Ensure the HTTP httpClient is closed even if an error occurs.
    httpClient.close();
  }
}

//get the current users username
Future<String> getUsername() async {
  String apiBaseUrl = Environment.apiUrl;
  // Build the request URL for the FastAPI endpoint.
  final uri = Uri.parse(apiBaseUrl).resolve('/username');

  final httpClient = http.Client();
  try {
    final response = await httpClient.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getAuthToken()}'
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonResponse = jsonDecode(response.body);
      final username = jsonResponse as String;
      return username;
    } else if (response.statusCode == 404) {
      return "Not found";
    } else {
      // Surface the response for debugging purposes.
      throw HttpException(
        'API error ${response.statusCode}: ${response.body}',
        uri: uri,
      );
    }
  } finally {
    // Ensure the HTTP httpClient is closed even if an error occurs.
    httpClient.close();
  }
}

Future<List<dynamic>> fetchFriendsRaw() async {
  final apiBaseUrl = Environment.apiUrl;
  final uri = Uri.parse(apiBaseUrl).resolve('/friends');

  final client = HttpClient();
  try {
    final request = await client.getUrl(uri);
    request.headers.set(
    HttpHeaders.authorizationHeader,
    'Bearer ${await getAuthToken()}',
); //end 

final response = await request.close();
final body = await utf8.decodeStream(response);

if (response.statusCode >= 200 && response.statusCode < 300) {
  final decoded = jsonDecode(body);

  // supports either: [ ... ] OR { "friends": [ ... ] }
  if (decoded is List) return decoded;
  if (decoded is Map && decoded['friends'] is List) return decoded['friends'] as List;

    throw FormatException('Unexpected /friends response: $decoded');
  } else {
    throw HttpException('API error ${response.statusCode}: $body', uri: uri);
  }
  } finally {
    client.close(force: true);
  }
}

// create new friend row in db
Future<void> addFriendRaw({required String friendUsername}) async {
final apiBaseUrl = Environment.apiUrl;
final uri = Uri.parse(apiBaseUrl).resolve('/friends/add');

final payload = jsonEncode({
// Most likely field name; if FastAPI complains, we’ll rename to whatever it expects.
'friend_username': friendUsername,
});

final client = HttpClient();
  try {
  final request = await client.postUrl(uri);
  request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
  request.headers.set(
  HttpHeaders.authorizationHeader,
  'Bearer ${await getAuthToken()}',
  );
  request.add(utf8.encode(payload));

  final response = await request.close();
  final body = await utf8.decodeStream(response);

  if (response.statusCode >= 200 && response.statusCode < 300) {

  } else {
    throw HttpException('API error ${response.statusCode}: $body', uri: uri);
  }
  } finally {
    client.close(force: true);
  }
}

Future<List<Map<String, dynamic>>> fetchFriends() async {
  final raw = await fetchFriendsRaw();
  return raw.map((e) => (e as Map).cast<String, dynamic>()).toList();
}

// Get the current user's region
Future<String> getUserRegion() async {
  String apiBaseUrl = Environment.apiUrl;
  // Build the request URL for the FastAPI endpoint.
  final uri = Uri.parse(apiBaseUrl).resolve('/get-user-region');

  final httpClient = http.Client();
  try {
    final response = await httpClient.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getAuthToken()}'
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonResponse = jsonDecode(response.body);
      final username = jsonResponse as String;
      return username;
    } else if (response.statusCode == 404) {
      return "Not found";
    } else {
      // Surface the response for debugging purposes.
      throw HttpException(
        'API error ${response.statusCode}: ${response.body}',
        uri: uri,
      );
    }
  } finally {
    // Ensure the HTTP httpClient is closed even if an error occurs.
    httpClient.close();
  }
}

/// Sends a user set badge request to the API for storage of badge file path.
/// Can be used directly in a Flutter button:
///   onPressed: () => submitUserBadge(
///     badgeFilePath: selectedBadgeFilePath
///   );
Future<bool> submitUserBadge({
  required String badgeFilePath
}) async {
  String apiBaseUrl = Environment.apiUrl;
  // Build the request URL for the FastAPI endpoint.
  final uri = Uri.parse(apiBaseUrl).resolve('/set-user-badge');

  debugPrint(badgeFilePath);

  final httpClient = http.Client();
  try {
    final response = await httpClient.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getAuthToken()}',
      },
      body: jsonEncode({"badge_file_path": badgeFilePath})
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonResponse = jsonDecode(response.body);
      final success = jsonResponse as bool;
      return success;
    } else  if (response.statusCode == 404) {
      throw AuthException(
        'User does not exist: ${response.body}',
        statusCode: 404,
      );
    } else {
      // Surface the response for debugging purposes.
      throw HttpException(
        'API error ${response.statusCode}: ${response.body}',
        uri: uri,
      );
    }
  } finally {
    // Ensure the HTTP httpClient is closed even if an error occurs.
    httpClient.close();
  }
}

/// Sends a user set badge request to the API for getting stored badge file path.
/// Can be used directly in a Flutter button:
///   onPressed: () => async {
///      badgeFilePath = await fetchUserBadge();
///   } 
Future<String> fetchUserBadge() async {
  String apiBaseUrl = Environment.apiUrl;
  // Build the request URL for the FastAPI endpoint.
  final uri = Uri.parse(apiBaseUrl).resolve('/get-user-badge');

  final httpClient = http.Client();
  try {
    final response = await httpClient.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await getAuthToken()}',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonResponse = jsonDecode(response.body);
      if(jsonResponse != null) {
        final badgeFilePath = jsonResponse as String;
        return badgeFilePath;
      }
      else {
        return 'assets/brand/Identiflora_logo.png';
      }
    } else  if (response.statusCode == 404) {
      throw AuthException(
        'User does not exist: ${response.body}',
        statusCode: 404,
      );
    } else {
      // Surface the response for debugging purposes.
      throw HttpException(
        'API error ${response.statusCode}: ${response.body}',
        uri: uri,
      );
    }
  } finally {
    // Ensure the HTTP httpClient is closed even if an error occurs.
    httpClient.close();
  }
}

/// Send a request to update the user's email
Future<bool> submitEmailChange({required String newEmail}) async {
  final authToken = await getAuthToken();

  if (authToken == null) {
    throw AuthException('User not authenticated');
  }

  String apiBaseUrl = Environment.apiUrl;
  final uri = Uri.parse(apiBaseUrl).resolve('/user/update-email');

  final httpClient = http.Client();
  try {
    final response = await httpClient.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken', // Pass token for auth
      },
      body: jsonEncode({'new_email': newEmail}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    } else {
      throw AuthException(
        'Failed to update email: ${response.body}',
        statusCode: response.statusCode,
      );
    }
  } catch (e) {
    if (e is AuthException) rethrow;
    throw AuthException('Network error occurred: $e');
  } finally {
    httpClient.close();
  }
}

/// Send a request to update the user's password
Future<bool> submitPasswordChange({required String newPasswordHash}) async {
  final authToken = await getAuthToken();

  if (authToken == null) {
    throw AuthException('User not authenticated');
  }

  String apiBaseUrl = Environment.apiUrl;
  final uri = Uri.parse(apiBaseUrl).resolve('/user/update-password');

  final httpClient = http.Client();
  try {
    final response = await httpClient.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({'new_password_hash': newPasswordHash}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    } else {
      throw AuthException(
        'Failed to update password: ${response.body}',
        statusCode: response.statusCode,
      );
    }
  } catch (e) {
    if (e is AuthException) rethrow;
    throw AuthException('Network error occurred: $e');
  } finally {
    httpClient.close();
  }
}

Future<bool> savePlantSubmission({
  required List<Map<String, dynamic>> allPredictions,
  required String userGuess,
  required double latitude,
  required double longitude,
  String imgUrl = "",
}) async {
  String apiBaseUrl = Environment.apiUrl;
  final uri = Uri.parse(apiBaseUrl).resolve('/user/submissions');
  final authToken = await getAuthToken();
  if (authToken == null) throw AuthException('User not authenticated');

  final List<int> predictionIds = allPredictions.map((p) => p['class_index'] as int).toList();
  final payload = jsonEncode({
    'prediction_ids': predictionIds, 
    'user_guess': userGuess,
    'latitude': latitude,
    'longitude': longitude,
    'img_url': imgUrl,
  });

  final httpClient = http.Client();
  try {
    final response = await httpClient.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: payload,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    } else if (response.statusCode == 400 || response.statusCode == 404) {
      throw AuthException(
        'Submission failed (referenced data not found): ${response.body}',
        statusCode: response.statusCode,
      );
    } else {
      throw HttpException(
        'API error ${response.statusCode}: ${response.body}',
        uri: uri,
      );
    }
  } finally {
    httpClient.close();
  }
}
// Permanently deletes the currently logged in user's account.
Future<bool> submitDeleteAccount() async {
  final authToken = await getAuthToken();
  if (authToken == null) throw AuthException('User not authenticated');

  final uri = Uri.parse(Environment.apiUrl).resolve('/user/account');
  final httpClient = http.Client();

  try {
    final response = await httpClient.delete(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
    );

    return response.statusCode >= 200 && response.statusCode < 300;
  } finally {
    httpClient.close();
  }
}

// Fetches the user's plant submission history, needs to be updated to new
// History format
Future<List<Map<String, dynamic>>> fetchSubmissionHistory() async {
  String apiBaseUrl = Environment.apiUrl;
  final uri = Uri.parse(apiBaseUrl).resolve('/user/history');
  final authToken = await getAuthToken();
  if (authToken == null) throw AuthException('User not authenticated');

  final httpClient = http.Client();
  try {
    final response = await httpClient.get(
      uri,
      headers: {'Authorization': 'Bearer $authToken'},
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(jsonList);
    } else if (response.statusCode == 404) {
      throw AuthException(
        'No submission history found: ${response.body}',
        statusCode: 404,
      );
    } else {
      throw HttpException(
        'API error ${response.statusCode}: ${response.body}',
        uri: uri,
      );
    }
  } finally {
    httpClient.close();
  }
}
