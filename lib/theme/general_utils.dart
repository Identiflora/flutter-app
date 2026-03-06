import 'package:flutter/material.dart';

/// Returns an error popup based on error string and optional duration
/// ```dart
/// ScaffoldMessenger.of(context).showSnackBar(
///   SnackBar(
///     content: Text(
///       errorString,
///     ),
///     backgroundColor: Colors.red,
///   ),
/// );
ScaffoldFeatureController<SnackBar, SnackBarClosedReason> errorPopupMessage(BuildContext context, String errorString, Duration? duration) {
  if(duration == null) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          errorString,
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
  else {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          errorString,
        ),
        backgroundColor: Colors.red,
        duration: duration,
      ),
    );
  }
}

/// Get the blacklisted chars for inputted strings
List<String> getCharBlacklist() {
  // Note: Some chars require '\' before due to being part of variable insertions or string literal manipulation
  // Ex: '\$' and '\\' due to '$variableName' and things like '\n'
  return [
    '#', "\$", '%', '^', '&', '*', '(', ')', '[', ']', '{', '}', '<', '>', 
    ';', ':', '\\', '/', '\'', '"', '?', '|', '=', '+', '~', ','
  ];
}

/// Get a printable list of the char blacklist for input strings
String printBlacklistedChars() {
  List<String> blacklist = getCharBlacklist();
  String blacklistString = blacklist.join(', ');
  blacklistString = "${blacklistString.substring(0, blacklistString.length - 2)} or \",\" itself";
  return blacklistString;
}

/// Returns if a string has any blacklisted characters based a predefined list and whether it is an email or not.<br>
/// This is to prevent possible harmful characters from entering the backend.
/// ```dart
/// List<String> blacklist = [
///   '#', "\$", '%', '^', '&', '*', '(', ')', '[', ']', '{', '}', '<', '>', 
///   ';', ':', '\\', '/', '\'', '"', '?', '|', '=', '+', '~'
/// ];
/// ```
/// If ```emailString == false``` or ```emailString == null```, blacklist also contains ```'@'```
bool hasBlacklistedChar(String stringToCheck, bool? emailString) {
  List<String> blacklist = getCharBlacklist();

  if(emailString != true) {
    blacklist.add('@');
  }

  return blacklist.any((char) => stringToCheck.contains(char));
}

/// Returns if an email string is valid.<br>
/// Defined conditions for email string to be valid:
/// * Does not contain any blacklisted characters
/// * Contains '@' and '.'
/// * Greater than or equal to 5 characters
bool validEmail(String emailString) {
  List<String> emailCharReq = ['@', '.'];
  return !hasBlacklistedChar(emailString, true) 
          && emailCharReq.any((char) => emailString.contains(char)) 
          && emailString.length >= 5;
}

/// Returns if username string is valid.<br>
/// Defined conditions for username string to be valid:
/// * Does not contain any blacklisted characters
/// * String is not empty
/// * Less than or equal to 20 characters
bool validUsername(String usernameString) {
  return !hasBlacklistedChar(usernameString, null) 
          && usernameString.isNotEmpty 
          && usernameString.length <= 20;
}

/// Returns if password is valid.<br>
/// Defined conditions for password string to be valid:
/// * Does not contain any blacklisted characters
/// * Greater than or equal to 4 characters
bool validPassword(String unhashedPasswordString) {
  return !hasBlacklistedChar(unhashedPasswordString, null) 
          && unhashedPasswordString.length >= 4;
}