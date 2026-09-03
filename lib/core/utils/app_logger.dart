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

  static const String currentAppVersion = 'v1.2.3';
  final List<LogEntry> _logs = [];
  static const int _maxLogs = 600;

  void info(String tag, String message) => _add('INFO', tag, message);
  void net(String tag, String message) => _add('NET', tag, message);
  void sql(String tag, String message) => _add('SQL', tag, message);
  void auth(String tag, String message) => _add('AUTH', tag, message);
  void ui(String tag, String message) => _add('UI', tag, message);
  void sync(String tag, String message) => _add('SYNC', tag, message);
  void warn(String tag, String message) => _add('WARN', tag, sanitizeMessage(message));
  void error(String tag, String message, [dynamic stackTrace]) {
    String cleanMsg = sanitizeMessage(message);
    if (stackTrace != null) {
      final stStr = stackTrace.toString();
      final lines = stStr.split('\n').where((l) => l.trim().isNotEmpty).take(3).join('\n  ');
      cleanMsg = '$cleanMsg\n  Stack: $lines';
    }
    _add('ERROR', tag, cleanMsg);
  }

  static String sanitizeMessage(String message) {
    if (message.contains('This exception was thrown because the response has a status code of')) {
      final m = RegExp(r'status code of (\d+)').firstMatch(message);
      final code = m != null ? m.group(1) : 'HTTP 错误';
      return '[$code] 接口响应异常 (请确认网络连接或稍后重试)';
    }
    if (message.length > 300 && message.contains('DioException')) {
      return message.split('\n').first;
    }
    return message;
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

  int get errorCount => _logs.where((e) => e.level == 'ERROR').length;
  int get warnCount => _logs.where((e) => e.level == 'WARN').length;
  int get syncCount => _logs.where((e) => e.level == 'SYNC').length;
  int get netCount => _logs.where((e) => e.level == 'NET').length;

  List<LogEntry> getLogsByLevel(String? level) {
    if (level == null || level == 'ALL') return List.unmodifiable(_logs);
    if (level == 'ISSUES') {
      return _logs.where((e) => e.level == 'ERROR' || e.level == 'WARN').toList();
    }
    return _logs.where((e) => e.level == level).toList();
  }

  String exportFormattedLogs({String? filterLevel, int maxEntries = 200}) {
    if (_logs.isEmpty) return '【暂无流水日志】';
    final target = getLogsByLevel(filterLevel);
    if (target.isEmpty) return '【该分类暂无日志记录】';
    final takeList = target.length > maxEntries ? target.sublist(target.length - maxEntries) : target;
    return takeList.map((e) => e.toString()).join('\n');
  }

  /// Builds a concise summary report (~15 lines) ideal for fast sharing with developer
  String buildConciseDiagnosticSummary({
    String appVersion = currentAppVersion,
    String activeAccountName = '未登录',
    String activePlatformName = '未选择',
    String activeShortId = '无',
    int activeLp = 0,
    int activeMr = 0,
    String clubName = '',
    int dbBattleRecordsCount = 0,
    String? currentUrl,
  }) {
    final nowStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final sb = StringBuffer();
    sb.writeln('📋 【街霸6战绩助手 - 运行诊断摘要】 ($nowStr)');
    sb.writeln('• 版本: $appVersion  •  环境: Android Release');
    sb.writeln('• 账号: $activeAccountName (Short ID: $activeShortId, 平台: $activePlatformName)');
    sb.writeln('• 段位: $activeLp LP  •  $activeMr MR' + (clubName.isNotEmpty ? '  •  战队: [$clubName]' : ''));
    sb.writeln('• 本地 SQLite 对局库: 已缓存 $dbBattleRecordsCount 场历史战绩');
    if (currentUrl != null && currentUrl.isNotEmpty) {
      sb.writeln('• 网页定位: $currentUrl');
    }
    sb.writeln('• 日志状态: 异常 $errorCount 次 | 警告 $warnCount 次 | 同步流水 $syncCount 条');

    final recentIssues = _logs.where((e) => e.level == 'ERROR' || e.level == 'WARN').toList();
    if (recentIssues.isEmpty) {
      sb.writeln('• 健康状态: ✅ 运行稳定，未检测到关键报错');
    } else {
      sb.writeln('• 核心异常简报 (最新 ${recentIssues.length > 4 ? 4 : recentIssues.length} 项):');
      for (final issue in recentIssues.reversed.take(4)) {
        final timeStr = DateFormat('HH:mm:ss').format(issue.timestamp);
        sb.writeln('  [$timeStr] [${issue.level}] ${issue.tag}: ${issue.message}');
      }
    }
    return sb.toString();
  }

  /// Builds a comprehensive report with both summary and full execution logs
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
    sb.writeln(buildConciseDiagnosticSummary(
      appVersion: appVersion,
      activeAccountName: activeAccountName,
      activePlatformName: activePlatformName,
      activeShortId: activeShortId,
      activeLp: activeLp,
      activeMr: activeMr,
      clubName: clubName,
      dbBattleRecordsCount: dbBattleRecordsCount,
      currentUrl: currentUrl,
    ));
    sb.writeln('');

    if (webviewDiagnosticJson != null && webviewDiagnosticJson.isNotEmpty) {
      sb.writeln('------------------ 🌐 网页抓包与 Next.js 数据 ------------------');
      sb.writeln(webviewDiagnosticJson);
      sb.writeln('');
    }

    sb.writeln('------------------ ⚡ 全量运行流水 (最新 ${_logs.length} 条) ------------------');
    sb.writeln(exportFormattedLogs(maxEntries: 150));
    sb.writeln('========================================================================');

    return sb.toString();
  }

  void clear() {
    _logs.clear();
  }
}
