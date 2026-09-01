import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sf6_tracker/core/utils/app_logger.dart';
import 'app.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Global Flutter framework error hook
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      AppLogger.instance.error('FlutterError', '${details.exceptionAsString()}\n${details.stack}');
    };

    // Global platform async error hook
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      AppLogger.instance.error('PlatformDispatcher', '$error\n$stack');
      return true;
    };

    // Set immersive dark status bar and navigation bar styling
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF10121A),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    runApp(const Sf6App());
  }, (Object error, StackTrace stack) {
    AppLogger.instance.error('ZoneError', '$error\n$stack');
  });
}
