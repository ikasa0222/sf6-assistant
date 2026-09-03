import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class LogEntry {
  final DateTime timestamp;
  final String level; // NET, SQL, AUTH, UI, SYNC, INFO, WARN, ERROR
  final String tag;
  final String message;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.tag,
    required this.message,
  });

  @override
  String toString() {
    final timeStr = DateFormat('HH:mm:ss.SSS').format(timestamp);
    return '[$timeStr] [$level] [$tag] $message';
  }
}

class AppLogger {
  AppLogger._();
  static final AppLogger instance = AppLogger._();

  static const String currentAppVersion = 'v1.2.2';
  final List<LogEntry> _logs = [];
  static const int _maxLogs = 800;

  void info(String tag, String message) => _add('INFO', tag, message);
  void net(String tag, String message) => _add('NET', tag, message);
  void sql(String tag, String message) => _add('SQL', tag, message);
  void auth(String tag, String message) => _add('AUTH', tag, message);
  void ui(String tag, String message) => _add('UI', tag, message);
  void sync(String tag, String message) => _add('SYNC', tag, message);
  void warn(String tag, String message) => _add('WARN', tag, message);
  void error(String tag, String message, [dynamic stackTrace]) {
    String fullMsg = message;
    if (stackTrace != null) {
      final stStr = stackTrace.toString();
      final lines = stStr.split('\n').where((l) => l.trim().isNotEmpty).take(5).join('\n  ');
      fullMsg = '$message\n  Stack: $lines';
    }
    _add('ERROR', tag, fullMsg);
  }

  void _add(String level, String tag, String message) {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      tag: tag,
      message: message,
    );
    _logs.add(entry);
    if (_logs.length > _maxLogs) {
      _logs.removeAt(0);
    }
    if (kDebugMode) {
      print(entry.toString());
    }
  }

  List<LogEntry> get logs => List.unmodifiable(_logs);

  String exportFormattedLogs({String? filterLevel}) {
    if (_logs.isEmpty) return '【暂无流水日志】';
    final filtered = filterLevel == null
        ? _logs
        : _logs.where((e) => e.level == filterLevel).toList();
    if (filtered.isEmpty) return '【该分类暂无日志记录】';
    return filtered.map((e) => e.toString()).join('\n');
  }

  String buildComprehensiveReport({
    String appVersion = currentAppVersion,
    String activeAccountName = '未登录',
    String activePlatformName = '未选择',
    String activeShortId = '无',
    int activeLp = 0,
    int activeMr = 0,
    String clubName = '',
    int dbBattleRecordsCount = 0,
    String? currentUrl,
    String? pageTitle,
    String? webviewDiagnosticJson,
  }) {
    final sb = StringBuffer();
    sb.writeln('================== 📱 街霸6 战绩助手 - 全链路黑匣子诊断报告 ==================');
    sb.writeln('【系统环境】: Android (Flutter Release)  •  App 版本: $appVersion');
    sb.writeln('【当前激活账号】: $activeAccountName (Short ID: $activeShortId)');
    sb.writeln('【持久化段位数据】: $activeLp LP  •  $activeMr MR  •  平台: $activePlatformName' + (clubName.isNotEmpty ? '  •  战队: [$clubName]' : ''));
    sb.writeln('【SQLite 对局库状态】: 已持久化 $dbBattleRecordsCount 场历史真实对局');
    
    if (currentUrl != null) {
      sb.writeln('【WebView 状态】: URL: $currentUrl  •  标题: ${pageTitle ?? "未知"}');
    }
    sb.writeln('');

    if (webviewDiagnosticJson != null && webviewDiagnosticJson.isNotEmpty) {
      sb.writeln('------------------ 🌐 网页抓包与 Next.js 数据分析 ------------------');
      sb.writeln(webviewDiagnosticJson);
      sb.writeln('');
    }

    sb.writeln('------------------ ⚡ 全链路黑匣子流水日志 (最新 ${_logs.length} 条) ------------------');
    sb.writeln(exportFormattedLogs());
    sb.writeln('========================================================================');

    return sb.toString();
  }

  void clear() {
    _logs.clear();
  }
}
