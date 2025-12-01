import 'dart:convert';
import 'dart:io';

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
  String apiBaseUrl = 'http://localhost:8000',
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
  String apiBaseUrl = 'http://localhost:8000',
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
  String apiBaseUrl = 'http://localhost:8000',
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