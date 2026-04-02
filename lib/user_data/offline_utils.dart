import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnService {
  // Ensure only one instance is present throughout app lifecycle
  static final ConnService _inst = ConnService._internal();
  factory ConnService() => _inst;
  ConnService._internal();

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _processing = false;

  void init() {
    _subscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) async { 
      bool connected = results.any((result) => 
        result == ConnectivityResult.wifi || 
        result == ConnectivityResult.mobile || 
        result == ConnectivityResult.ethernet ||
        result == ConnectivityResult.vpn
      );

      if(connected) {
        // Prod identiflora website to ensure connection is actually obtained
        bool prodSuccess = await _tryProd();
        if(prodSuccess) {
          await _sendDataQueue();
        }
      }
    });
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
    if(_processing) return;

    try {
      _processing = true;

      // Process data queue here
      debugPrint("Processing!");

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