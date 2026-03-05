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