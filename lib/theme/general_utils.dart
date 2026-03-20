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

/// General use loading screen for easy implementation that requires end action among other required fields. 
/// * Navigation to a new window using postLoadingBuilder.
/// * Pop from window to a specific route using postLoadingPop and popErrorScreenButton.
/// 
/// 
/// <br>Example navigation use case:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => LoadingScreen<String>.withNav(
///       loadingMsg: "Retrieving this identification information...", 
///       foundMsg: "Identification information found! One moment...", 
///       errorMsg: "Unable to find identification information. One moment...", 
///       futureFunction: getPlantSpeciesUrl(
///          scientificName: widget.predictions[correctIndex]['label']
///       ),
///       postLoadingBuilder: (context, imgURL) => ResultsWidget(
///         userChoiceIndex: userChoice!,
///         correctIndex: correctIndex,
///         allPredictions: widget.predictions,
///          imgURL: imgURL ?? "",
///       ),
///       navigateOnError: true,
///      )
///   ),
/// );
/// ```
/// 
/// <br>Example pop use case:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => LoadingScreen<bool>.withPop(
///       loadingMsg: "Please wait while we update your points...", 
///       foundMsg: "Points updated! One moment...", 
///       errorMsg: "We could not find your account to update points for.", 
///       futureFunction: submitUserGlobalPoints(addPoints: addPoints), 
///       postLoadingPop: ModalRoute.withName("/"),
///       popErrorScreenButton: "Return to Homepage",
///       valueEqualCheck: true,
///     )
///   ),
/// );
/// ```
class LoadingScreen<T> extends StatelessWidget {
  final String loadingMsg, foundMsg, errorMsg;
  final Future<T>? futureFunction;
  final RoutePredicate? postLoadingPop;
  final String? popErrorScreenButton, successMsg;
  final Widget Function(BuildContext, T?)? postLoadingBuilder;
  final bool? navigateOnError, errorPopup; 
  final T? valueEqualCheck;

  /// General use loading screen for easy implementation that requires end action among other required fields.
  /// 
  /// 
  /// <br>Example pop use case:
  /// ```dart
  /// Navigator.push(
  ///   context,
  ///   MaterialPageRoute(
  ///     builder: (context) => LoadingScreen<bool>.withPop(
  ///       loadingMsg: "Please wait while we update your points...", 
  ///       foundMsg: "Points updated! One moment...", 
  ///       errorMsg: "We could not find your account to update points for.", 
  ///       futureFunction: submitUserGlobalPoints(addPoints: addPoints), 
  ///       postLoadingPop: ModalRoute.withName("/"),
  ///       popErrorScreenButton: "Return to Homepage",
  ///       valueEqualCheck: true,
  ///     )
  ///   ),
  /// );
  /// ```
  const LoadingScreen.withPop({
    super.key,
    required this.loadingMsg,
    required this.foundMsg,
    required this.errorMsg,
    required this.futureFunction,
    required this.postLoadingPop,
    required this.popErrorScreenButton,
    this.valueEqualCheck,
    this.successMsg,
    this.postLoadingBuilder,
    this.navigateOnError,
    this.errorPopup = true
  });

  /// General use loading screen for easy implementation that requires end action among other required fields. 
  /// 
  /// 
  /// <br>Example navigation use case:
  /// ```dart
  /// Navigator.push(
  ///   context,
  ///   MaterialPageRoute(
  ///     builder: (context) => LoadingScreen<String>.withNav(
  ///       loadingMsg: "Retrieving this identification information...", 
  ///       foundMsg: "Identification information found! One moment...", 
  ///       errorMsg: "Unable to find identification information. One moment...", 
  ///       futureFunction: getPlantSpeciesUrl(
  ///          scientificName: widget.predictions[correctIndex]['label']
  ///       ),
  ///       postLoadingBuilder: (context, imgURL) => ResultsWidget(
  ///         userChoiceIndex: userChoice!,
  ///         correctIndex: correctIndex,
  ///         allPredictions: widget.predictions,
  ///          imgURL: imgURL ?? "",
  ///       ),
  ///       navigateOnError: true,
  ///      )
  ///   ),
  /// );
  /// ```
  const LoadingScreen.withNav({
    super.key,
    required this.loadingMsg,
    required this.foundMsg,
    required this.errorMsg,
    required this.futureFunction,
    required this.postLoadingBuilder,
    this.navigateOnError,
    this.valueEqualCheck,
    this.successMsg,
    this.postLoadingPop,
    this.popErrorScreenButton,
    this.errorPopup = true
  });

  final String exceptionMsg = "Loading screen must have loading builder or pop route and pop error screen message! Please declare these.";

  bool checkValueEqual(T value) {
    if(valueEqualCheck != null) {
      return value == valueEqualCheck;
    }
    return true;
  }

  Widget getMessage(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget getCircleIndicator(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: CircularProgressIndicator(
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loading...'), centerTitle: true),
      body: SafeArea(
        child: FutureBuilder<T>(
          future: futureFunction,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    getMessage(context, loadingMsg),
                    getCircleIndicator(context)
                  ],
                ),
              );
            } else if (snapshot.hasData && snapshot.data != null && checkValueEqual(snapshot.data as T)) {
              // Run after next frame
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if(successMsg != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(successMsg!),
                      backgroundColor: Colors.green,
                    ),
                  );
                }

                if(postLoadingBuilder != null) {
                  // Remove loading screen from stack
                  Navigator.pop(context);

                  // Navigate to new screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => postLoadingBuilder!(context, snapshot.data)
                    ),
                  );
                }
                else if(postLoadingPop != null) {
                  Navigator.popUntil(context, postLoadingPop!);
                }
                else {
                  throw FormatException(exceptionMsg);
                }
              });

              // Return a found message for current frame
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    getMessage(context, foundMsg),
                    getCircleIndicator(context)
                  ],
                ),
              );
            } else {
              if (snapshot.hasError) {
                errorPopupMessage(
                  context, 
                  "Error: ${snapshot.error}", 
                  null
                );
              }

              if(popErrorScreenButton == null && postLoadingPop == null) {
                // Run after next frame
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if(postLoadingBuilder != null) {
                    // Remove loading screen from stack
                    Navigator.pop(context);

                    if(navigateOnError != null && navigateOnError!) {
                      // Navigate to new screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => postLoadingBuilder!(context, snapshot.data),
                        ),
                      );
                    }
                  }
                  else {
                    throw FormatException(exceptionMsg);
                  }
                });

                // Return an error message for current frame
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      getMessage(context, errorMsg),
                      getCircleIndicator(context)
                    ],
                  ),
                );
              }
              else if(popErrorScreenButton != null && postLoadingPop != null) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(errorMsg,
                        textAlign: TextAlign.center, 
                        style: TextStyle(fontSize: 20)
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.popUntil(context, postLoadingPop!);
                      }, 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.surfaceBright,
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: Text(popErrorScreenButton!)
                    )
                  ],
                );
              }
              else if(postLoadingPop != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.popUntil(context, postLoadingPop!);

                  if(errorPopup != null && errorPopup! && errorMsg.isNotEmpty) {
                    errorPopupMessage(
                      context, 
                      errorMsg, 
                      Duration(seconds: 7)
                    );
                  }
                });

                // Return a error message for current frame
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      getMessage(context, errorMsg),
                      getCircleIndicator(context)
                    ],
                  ),
                );
              }
              else {
                throw FormatException(exceptionMsg);
              }
            }
          },
        ),
      ),
    );
  }
}