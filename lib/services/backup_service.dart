import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sf6_tracker/core/storage/database_helper.dart';
import 'package:sf6_tracker/core/storage/secure_storage.dart';
import 'package:sf6_tracker/core/utils/app_logger.dart';
import 'package:sf6_tracker/models/battle_record.dart';
import 'package:sf6_tracker/models/friend_model.dart';
import 'package:sf6_tracker/models/player_note.dart';

class ExportResult {
  final bool success;
  final String filePath;
  final int recordCount;
  final int noteCount;
  final String? errorMessage;

  const ExportResult({
    required this.success,
    this.filePath = '',
    this.recordCount = 0,
    this.noteCount = 0,
    this.errorMessage,
  });
}

class ImportResult {
  final bool success;
  final int recordsImported;
  final int notesImported;
  final String message;

  const ImportResult({
    required this.success,
    this.recordsImported = 0,
    this.notesImported = 0,
    required this.message,
  });
}

class BackupService {
  static final BackupService instance = BackupService._init();
  final DatabaseHelper _db = DatabaseHelper.instance;

  BackupService._init();

  /// Resolves the primary directory where backups should be stored.
  Future<Directory> getBackupDirectory() async {
    // 1. Try public Android Download directory if available
    try {
      final publicDownload = Directory('/storage/emulated/0/Download/SF6_Assistant_Backups');
      if (await publicDownload.exists() || await _canCreateDir(publicDownload)) {
        return publicDownload;
      }
    } catch (_) {}

    // 2. Try path_provider getDownloadsDirectory
    try {
      final dDir = await getDownloadsDirectory();
      if (dDir != null) {
        final target = Directory('${dDir.path}/SF6_Assistant_Backups');
        if (await target.exists() || await _canCreateDir(target)) {
          return target;
        }
      }
    } catch (_) {}

    // 3. Fallback to external storage / application documents
    try {
      final ext = await getExternalStorageDirectory();
      if (ext != null) {
        final target = Directory('${ext.path}/SF6_Assistant_Backups');
        if (await target.exists() || await _canCreateDir(target)) {
          return target;
        }
      }
    } catch (_) {}

    final appDoc = await getApplicationDocumentsDirectory();
    final target = Directory('${appDoc.path}/SF6_Assistant_Backups');
    if (!await target.exists()) {
      await target.create(recursive: true);
    }
    return target;
  }

  Future<bool> _canCreateDir(Directory dir) async {
    try {
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Exports all battle records, notes, and friends to a local JSON file.
  Future<ExportResult> exportBackup({String? shortId, bool invokeShare = true}) async {
    try {
      final records = await _db.getAllBattleRecords(shortId: shortId);
      final notes = await _db.getAllNotes();
      final followedPlayers = await StorageService.instance.getFollowedPlayers();
      final clubName = await StorageService.instance.getClubName();
      final accounts = await StorageService.instance.getAccounts();

      final now = DateTime.now();
      final dateStr = DateFormat('yyyyMMdd_HHmmss').format(now);

      final Map<String, dynamic> backupData = {
        'appName': '街霸6助手 (SF6 Assistant)',
        'appVersion': AppLogger.currentAppVersion,
        'exportedAt': now.toIso8601String(),
        'shortId': shortId ?? '',
        'totalRecords': records.length,
        'totalNotes': notes.length,
        'clubName': clubName,
        'accounts': accounts.map((a) => a.toJson()).toList(),
        'followedPlayers': followedPlayers.map((p) => p.toJson()).toList(),
        'records': records.map((r) => r.toMap()).toList(),
        'notes': notes.map((n) => n.toMap()).toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);
      final dir = await getBackupDirectory();
      final fileName = 'sf6_backup_${shortId != null && shortId.isNotEmpty ? "${shortId}_" : ""}$dateStr.json';
      final file = File('${dir.path}/$fileName');

      await file.writeAsString(jsonString);

      if (invokeShare) {
        try {
          await Share.shareXFiles(
            [XFile(file.path)],
            text: '街霸6助手战绩备份 ($dateStr, 共 ${records.length} 局对战)',
            subject: 'SF6 Assistant Backup',
          );
        } catch (e) {
          AppLogger.instance.warn('BackupService', '调用系统分享异常 (文件已安全保存在本地): $e');
        }
      }

      AppLogger.instance.info(
        'BackupService',
        '数据备份成功: ${records.length} 局对战, ${notes.length} 条笔记, 文件路径: ${file.path}',
      );

      return ExportResult(
        success: true,
        filePath: file.path,
        recordCount: records.length,
        noteCount: notes.length,
      );
    } catch (e, stack) {
      AppLogger.instance.error('BackupService', '导出备份失败: $e\n$stack');
      return ExportResult(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Lists existing backup files found in the backup directory.
  Future<List<File>> listLocalBackups() async {
    try {
      final dir = await getBackupDirectory();
      if (!await dir.exists()) return [];
      final files = dir.listSync().whereType<File>().where((f) => f.path.endsWith('.json')).toList();
      files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      return files;
    } catch (e) {
      AppLogger.instance.warn('BackupService', '获取备份列表异常: $e');
      return [];
    }
  }

  /// Imports and restores data from a JSON string.
  Future<ImportResult> importBackupJson(String jsonString) async {
    try {
      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        return const ImportResult(
          success: false,
          message: '备份文件格式非法: 必须为 JSON 对象',
        );
      }

      final rawRecords = decoded['records'];
      int recordsCount = 0;
      if (rawRecords is List) {
        final List<BattleRecord> battleList = [];
        for (final r in rawRecords) {
          if (r is Map) {
            try {
              battleList.add(BattleRecord.fromMap(Map<String, dynamic>.from(r)));
            } catch (_) {}
          }
        }
        if (battleList.isNotEmpty) {
          await _db.batchInsertBattleRecords(battleList);
          recordsCount = battleList.length;
        }
      }

      final rawNotes = decoded['notes'];
      int notesCount = 0;
      if (rawNotes is List) {
        for (final n in rawNotes) {
          if (n is Map) {
            try {
              final note = PlayerNote.fromMap(Map<String, dynamic>.from(n));
              await _db.saveNote(note);
              notesCount++;
            } catch (_) {}
          }
        }
      }

      final rawPlayers = decoded['followedPlayers'];
      if (rawPlayers is List) {
        final List<FriendModel> friends = [];
        for (final p in rawPlayers) {
          if (p is Map) {
            try {
              friends.add(FriendModel.fromJson(Map<String, dynamic>.from(p)));
            } catch (_) {}
          }
        }
        if (friends.isNotEmpty) {
          await StorageService.instance.saveFollowedPlayers(friends);
        }
      }

      AppLogger.instance.info(
        'BackupService',
        '数据恢复完成: 成功导入 $recordsCount 局对战, $notesCount 条笔记',
      );

      return ImportResult(
        success: true,
        recordsImported: recordsCount,
        notesImported: notesCount,
        message: '数据恢复成功！已增量合并 $recordsCount 局对战、 $notesCount 条笔记与关注列表。',
      );
    } catch (e, stack) {
      AppLogger.instance.error('BackupService', '导入恢复失败: $e\n$stack');
      return ImportResult(
        success: false,
        message: '导入失败: $e',
      );
    }
  }

  /// Reads a file and restores from it.
  Future<ImportResult> importBackupFromFile(File file) async {
    try {
      if (!await file.exists()) {
        return const ImportResult(success: false, message: '备份文件不存在');
      }
      final content = await file.readAsString();
      return await importBackupJson(content);
    } catch (e) {
      return ImportResult(success: false, message: '读取文件异常: $e');
    }
  }
}
