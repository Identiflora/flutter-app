
// still need to implement: Token secure storage using flutter_secure_storage package

class AuthToken {
  final String tokenType;
  final String accessToken;
  final int expiresIn;

  AuthToken({
    required this.tokenType,
    required this.accessToken,
    required this.expiresIn,
  });

  // specific factory constructor for creating the instance from JSON
  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      tokenType: json['token_type'] as String,
      accessToken: json['access_token'] as String,
      expiresIn: json['expires_in'] as int,
    );
  }

  @override
  String toString() {
    return 'AuthToken(tokenType: $tokenType, accessToken: $accessToken, expiresIn: $expiresIn)';
  }
}

class AuthException implements Exception {
  final String message;
  final int? statusCode;

  AuthException(this.message, {this.statusCode});

  @override
  String toString() => 'AuthException: $message (Status: $statusCode)';
}

class RateLimitException implements Exception {
  final String message;
  final int? statusCode;

  RateLimitException([this.message = "Rate limit exceeded", this.statusCode = 429]);

  @override
  String toString() => 'RateLimitException: $message (Status: $statusCode)';
}