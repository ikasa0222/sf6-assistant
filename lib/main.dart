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
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          color: const Color(0xFF161928),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2336),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.6), width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded, color: Color(0xFF00E5FF), size: 42),
                const SizedBox(height: 10),
                const Text(
                  '界面渲染受阻，已安全隔离记录',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  details.exceptionAsString().split('\n').first,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF9EABB8), fontSize: 11),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5FF),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('重置并恢复主页', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  onPressed: () {
                    runApp(const Sf6App());
                  },
                ),
              ],
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
