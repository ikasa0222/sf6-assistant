import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sf6_tracker/core/constants/api_constants.dart';
import 'package:sf6_tracker/core/utils/app_logger.dart';

class ReleaseInfo {
  final String tagName;
  final String title;
  final String changelog;
  final String publishDate;
  final String htmlUrl;
  final String? apkDownloadUrl;
  final int? apkSizeBytes;

  const ReleaseInfo({
    required this.tagName,
    required this.title,
    required this.changelog,
    required this.publishDate,
    required this.htmlUrl,
    this.apkDownloadUrl,
    this.apkSizeBytes,
  });

  String get formattedSize {
    if (apkSizeBytes == null || apkSizeBytes! <= 0) return '';
    final mb = apkSizeBytes! / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  String get mirrorDownloadUrl {
    if (apkDownloadUrl == null) return htmlUrl;
    return '${ApiConstants.githubMirrorProxyPrefix}$apkDownloadUrl';
  }
}

class UpdateService extends ChangeNotifier {
  static final UpdateService instance = UpdateService._internal();
  UpdateService._internal();

  factory UpdateService() => instance;

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 8),
    headers: {
      'Accept': 'application/vnd.github.v3+json',
      'User-Agent': 'SF6-Assistant-App',
    },
  ));

  bool _isChecking = false;
  bool _hasNewVersion = false;
  ReleaseInfo? _latestRelease;
  String _errorMessage = '';

  bool get isChecking => _isChecking;
  bool get hasNewVersion => _hasNewVersion;
  ReleaseInfo? get latestRelease => _latestRelease;
  String get errorMessage => _errorMessage;

  /// Check GitHub Release for latest version
  Future<ReleaseInfo?> checkForUpdates({bool isManual = false}) async {
    _isChecking = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _dio.get(ApiConstants.githubReleasesApiUrl);
      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        final tagName = (data['tag_name'] ?? '').toString().trim();
        final title = (data['name'] ?? tagName).toString().trim();
        final body = (data['body'] ?? '').toString().trim();
        final htmlUrl = (data['html_url'] ?? ApiConstants.githubReleasesWebUrl).toString();
        final publishDate = (data['published_at'] ?? '').toString().split('T').first;

        String? apkUrl;
        int? apkSize;
        final assets = data['assets'] as List? ?? [];
        for (final asset in assets) {
          if (asset is Map) {
            final name = (asset['name'] ?? '').toString().toLowerCase();
            if (name.endsWith('.apk')) {
              apkUrl = asset['browser_download_url']?.toString();
              apkSize = (asset['size'] as num?)?.toInt();
              if (name.contains('arm64') || name.contains('release')) {
                break;
              }
            }
          }
        }

        final release = ReleaseInfo(
          tagName: tagName,
          title: title,
          changelog: body,
          publishDate: publishDate,
          htmlUrl: htmlUrl,
          apkDownloadUrl: apkUrl,
          apkSizeBytes: apkSize,
        );

        final currentVer = AppLogger.currentAppVersion;
        final isNew = _compareVersions(tagName, currentVer) > 0;

        _latestRelease = release;
        _hasNewVersion = isNew;
        _isChecking = false;
        notifyListeners();

        AppLogger.instance.info(
          'UpdateService',
          '检查更新完成: 当前版本=$currentVer, 最新云端=$tagName, 是否有新版=$isNew',
        );

        return release;
      }
    } catch (e) {
      _errorMessage = '检测更新异常: $e';
      AppLogger.instance.warn('UpdateService', '检查更新失败 (网络离线或接口超限): $e');
    }

    _isChecking = false;
    notifyListeners();
    return null;
  }

  /// Returns > 0 if v1 > v2, < 0 if v1 < v2, 0 if equal
  int _compareVersions(String v1, String v2) {
    try {
      final cleanV1 = v1.replaceAll(RegExp(r'[^0-9.]'), '');
      final cleanV2 = v2.replaceAll(RegExp(r'[^0-9.]'), '');
      final parts1 = cleanV1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final parts2 = cleanV2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      final maxLen = parts1.length > parts2.length ? parts1.length : parts2.length;
      for (int i = 0; i < maxLen; i++) {
        final p1 = i < parts1.length ? parts1[i] : 0;
        final p2 = i < parts2.length ? parts2[i] : 0;
        if (p1 > p2) return 1;
        if (p1 < p2) return -1;
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }
}
