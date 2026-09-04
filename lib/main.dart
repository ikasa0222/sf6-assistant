import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sf6_tracker/core/utils/app_logger.dart';
import 'app.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await AppLogger.instance.init();

    // Global Flutter framework error hook
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      AppLogger.instance.error('FlutterError', '${details.exceptionAsString()}\n${details.stack}');
    };

    // Custom ErrorWidget to eliminate Release mode black screen
    ErrorWidget.builder = (FlutterErrorDetails details) {
      AppLogger.instance.error('WidgetBuildCrash', '${details.exceptionAsString()}\n${details.stack}');
      return Material(
        color: const Color(0xFF161922),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.refresh, color: Color(0xFF00E5FF), size: 48),
                  const SizedBox(height: 12),
                  const Text(
                    '界面渲染受阻，已记录运行日志',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    details.exceptionAsString().split('\n').first,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xFF8E9BAE), fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF),
                      foregroundColor: Colors.black,
                    ),
                    icon: const Icon(Icons.home),
                    label: const Text('重置并恢复主页', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      runApp(const Sf6App());
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    };

    // Global platform async error hook

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
