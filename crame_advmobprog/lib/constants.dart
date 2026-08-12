import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  AppConstants._();

  /// Gets the HOST configuration safely.
  /// Converts 'localhost' / '127.0.0.1' to '10.0.2.2' when running on Android Emulator.
  static String get host {
    String rawHost = dotenv.env['HOST'] ?? 'https://dummyjson.com';
    if (rawHost.isEmpty) {
      rawHost = 'https://dummyjson.com';
    }

    if (!kIsWeb && Platform.isAndroid) {
      return rawHost
          .replaceAll('localhost', '10.0.2.2')
          .replaceAll('127.0.0.1', '10.0.2.2');
    }

    return rawHost;
  }
}

/// Convenience getter for top-level access to host URL.
String get host => AppConstants.host;

