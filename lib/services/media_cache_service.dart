import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class MediaCacheService {
  MediaCacheService._();
  static final MediaCacheService instance = MediaCacheService._();

  static const String cacheDirName = 'sf6_hitbox_cache';

  Future<Directory> _getCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/$cacheDirName');
    if (!cacheDir.existsSync()) {
      cacheDir.createSync(recursive: true);
    }
    return cacheDir;
  }

  Future<String> getLocalHitboxFilePath(String characterSlug, String filename) async {
    final cacheDir = await _getCacheDirectory();
    return '${cacheDir.path}/$characterSlug/$filename';
  }

  Future<File?> getCachedHitboxFile(String characterSlug, String filename) async {
    try {
      final path = await getLocalHitboxFilePath(characterSlug, filename);
      final file = File(path);
      if (file.existsSync() && file.lengthSync() > 0) {
        return file;
      }
    } catch (e) {
      debugPrint('Error getting cached hitbox file: $e');
    }
    return null;
  }

  Future<File> saveHitboxBytes(String characterSlug, String filename, List<int> bytes) async {
    final path = await getLocalHitboxFilePath(characterSlug, filename);
    final file = File(path);
    final parent = file.parent;
    if (!parent.existsSync()) {
      parent.createSync(recursive: true);
    }
    return file.writeAsBytes(bytes, flush: true);
  }

  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final cacheDir = await _getCacheDirectory();
      if (!cacheDir.existsSync()) {
        return {'fileCount': 0, 'totalBytes': 0, 'formattedSize': '0.0 KB'};
      }
      int count = 0;
      int totalBytes = 0;
      final entities = cacheDir.listSync(recursive: true);
      for (final entity in entities) {
        if (entity is File) {
          count++;
          totalBytes += entity.lengthSync();
        }
      }
      final sizeMb = totalBytes / (1024 * 1024);
      final formatted = sizeMb >= 1.0
          ? '${sizeMb.toStringAsFixed(1)} MB'
          : '${(totalBytes / 1024).toStringAsFixed(1)} KB';
      return {
        'fileCount': count,
        'totalBytes': totalBytes,
        'formattedSize': formatted,
      };
    } catch (e) {
      return {'fileCount': 0, 'totalBytes': 0, 'formattedSize': '0.0 KB'};
    }
  }

  Future<String> getCacheSize() async {
    final stats = await getCacheStats();
    return stats['formattedSize'] as String? ?? '0.0 KB';
  }

  Future<void> clearCache() async {
    try {
      final cacheDir = await _getCacheDirectory();
      if (cacheDir.existsSync()) {
        cacheDir.deleteSync(recursive: true);
      }
      cacheDir.createSync(recursive: true);
    } catch (e) {
      debugPrint('Error clearing hitbox cache: $e');
    }
  }
}
