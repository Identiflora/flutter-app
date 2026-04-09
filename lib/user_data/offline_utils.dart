import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:identiflora/database_utils.dart';
import 'package:identiflora/user_data/cache_utils.dart';
import 'package:identiflora/user_data/history_utils.dart';

class ConnService {
  // Ensure only one instance is present throughout app lifecycle
  static final ConnService _inst = ConnService._internal();
  factory ConnService() => _inst;
  ConnService._internal();

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _processing = false, _isOffline = false;

  void init() async {
    _subscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) async { 
      bool connected = results.any((result) => 
        result == ConnectivityResult.wifi || 
        result == ConnectivityResult.mobile || 
        result == ConnectivityResult.ethernet ||
        result == ConnectivityResult.vpn
      ),
      disconnected = results.any((result) => 
        result == ConnectivityResult.none
      );

      if (connected) {
        // Prod identiflora website to ensure connection is actually obtained
        final bool prodSuccess = await _tryProd();
        if (prodSuccess) {
          await _sendDataQueue();
        }
      }
      else if (disconnected) {
        // Prod identiflora website to ensure connection is actually obtained
        final bool prodSuccess = await _tryProd();
        if (!prodSuccess) {
          _isOffline = true;
        }
      }
    });

    // Set _isOffline
    await getIsOffline;

    if (!_isOffline) {
      await _sendDataQueue();
    }
  }

  Future<bool> get getIsOffline async {
    final bool prodSuccess = await _tryProd();
    
    if (prodSuccess) {
      _isOffline = false;
    }
    else {
      _isOffline = true;
    }

    return _isOffline;
  }

  Future<bool> _tryProd() async {
    try {
      final List<InternetAddress> ping = await InternetAddress.lookup('identifloraapp.wordpress.com').timeout(const Duration(seconds: 5));
      return ping.isNotEmpty && ping[0].rawAddress.isNotEmpty;
    }
    on SocketException catch (_) {
      debugPrint("Connection prod to identifloraapp.wordpress.com failed.");
      return false;
    }
    on TimeoutException catch (_) {
      debugPrint("Connection prod to identifloraapp.wordpress.com timed out.");
      return false;
    }
  }

  Future<void> _sendDataQueue() async {
    // Guard for multiple data queue sending at once
    if (_processing) return;

    try {
      _processing = true;

      // Process data queue here
      final int? userPts = await getUserOfflinePts();
      if (userPts != null) {
        try {
          await submitUserGlobalPoints(addPoints: userPts);
          await deleteUserOfflinePts();
        }
        catch (error) {
          debugPrint("Error submitting cached points: $error");
        }
      }

      final List<HistoryData>? userHistory = await getUserOfflineHistory();
      if (userHistory != null) {
        try {
          for (HistoryData history in userHistory) {
            await history.updateImgUrl();
            await savePlantSubmission(
              allPredictions: history.allPredictions, 
              userGuess: history.userGuess, 
              latitude: history.latitude, 
              longitude: history.longitude,
              imgUrl: history.imgUrl
            );
          }

          await deleteUserOfflineHistory();
        }
        catch (error) {
          debugPrint("Error submitting cached history: $error");
        }
      }

      String? badgeFilePath = await getUserBadge();
      if(badgeFilePath != null) {
        await submitUserBadge(badgeFilePath: badgeFilePath);
      }

      _processing = false;
    }
    on SocketException catch (_) {
      debugPrint("Internet access is no longer available for data queue.");
      _processing = false;
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}