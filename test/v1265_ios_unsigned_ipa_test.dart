import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sf6_tracker/core/utils/app_logger.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ===========================================================================
  // 1. REQ-VER-001: Application Version and Build Number Specifications (v1.2.6.5 / 2605)
  // ===========================================================================
  group('REQ-VER-001: Version and Build Metadata (v1.2.6.4 / 2604)', () {
    test('AppLogger.currentAppVersion must strictly equal v1.2.6.4', () {
      expect(
        AppLogger.currentAppVersion,
        equals('v1.2.6.4'),
        reason: 'REQ-VER-001: AppLogger.currentAppVersion matches release v1.2.6.4',
      );
    });

    test('AppLogger.currentBuildNumber must strictly equal 2604', () {
      expect(
        AppLogger.currentBuildNumber,
        equals('2604'),
        reason: 'REQ-VER-001: AppLogger.currentBuildNumber matches build 2604',
      );
    });

    test('pubspec.yaml version must strictly be 1.2.6+2604', () {
      final pubspecFile = File('pubspec.yaml');
      expect(pubspecFile.existsSync(), isTrue, reason: 'pubspec.yaml must exist');
      final content = pubspecFile.readAsStringSync();
      final versionMatch = RegExp(r'^version:\s*1\.2\.6(\.4)?\+2604\s*$', multiLine: true);
      expect(
        versionMatch.hasMatch(content),
        isTrue,
        reason: 'REQ-VER-001: pubspec.yaml version must strictly be 1.2.6+2604',
      );
    });

    test('AppLogger diagnostic summary format must output target version v1.2.6.4 and build 2604', () {
      final logger = AppLogger.instance;
      final report = logger.buildConciseDiagnosticSummary();
      expect(
        report.contains('v1.2.6.4'),
        isTrue,
        reason: 'REQ-VER-001: Diagnostic summary report must include version v1.2.6.4',
      );
      expect(
        report.contains('2604'),
        isTrue,
        reason: 'REQ-VER-001: Diagnostic summary report must include build number 2604',
      );
    });
  });

  // ===========================================================================
  // 2. REQ-IPA-001: GitHub Actions Cloud CI/CD Unsigned IPA Workflow
  // ===========================================================================
  group('REQ-IPA-001: GitHub Actions Cloud CI/CD Workflow Specifications', () {
    test('CI/CD workflow file (.github/workflows/build-ios.yml or build-release.yml) must exist', () {
      final iosWorkflow = File('.github/workflows/build-ios.yml');
      final releaseWorkflow = File('.github/workflows/build-release.yml');
      final exists = iosWorkflow.existsSync() || releaseWorkflow.existsSync();
      expect(
        exists,
        isTrue,
        reason: 'REQ-IPA-001: iOS CI/CD workflow file must exist in .github/workflows/',
      );
    });

    test('Workflow must run on macos-latest and declare flutter build ios --release --no-codesign', () {
      final iosWorkflow = File('.github/workflows/build-ios.yml');
      final releaseWorkflow = File('.github/workflows/build-release.yml');
      final content = (iosWorkflow.existsSync() ? iosWorkflow.readAsStringSync() : '') +
          (releaseWorkflow.existsSync() ? releaseWorkflow.readAsStringSync() : '');

      expect(
        content.contains('runs-on: macos-latest'),
        isTrue,
        reason: 'REQ-IPA-001: iOS IPA building must run on macos-latest',
      );
      expect(
        content.contains('flutter build ios --release --no-codesign'),
        isTrue,
        reason: 'REQ-IPA-001: Workflow must execute flutter build ios --release --no-codesign',
      );
    });

    test('Workflow must package Runner.app into Payload/ and generate unsigned IPA and standard IPA', () {
      final iosWorkflow = File('.github/workflows/build-ios.yml');
      final releaseWorkflow = File('.github/workflows/build-release.yml');
      final content = (iosWorkflow.existsSync() ? iosWorkflow.readAsStringSync() : '') +
          (releaseWorkflow.existsSync() ? releaseWorkflow.readAsStringSync() : '');

      expect(
        content.contains('Payload') && content.contains('Runner.app'),
        isTrue,
        reason: 'REQ-IPA-001: Workflow must copy Runner.app into Payload/ directory',
      );
      expect(
        content.contains('SF6_Assistant_') && content.contains('_unsigned.ipa'),
        isTrue,
        reason: 'REQ-IPA-001: Workflow must generate SF6_Assistant_{TAG}_unsigned.ipa primary artifact',
      );
      expect(
        content.contains('.ipa'),
        isTrue,
        reason: 'REQ-IPA-001: Workflow must zip and produce .ipa file',
      );
    });

    test('Workflow must configure softprops/action-gh-release to upload *.ipa to Release Assets', () {
      final iosWorkflow = File('.github/workflows/build-ios.yml');
      final releaseWorkflow = File('.github/workflows/build-release.yml');
      final content = (iosWorkflow.existsSync() ? iosWorkflow.readAsStringSync() : '') +
          (releaseWorkflow.existsSync() ? releaseWorkflow.readAsStringSync() : '');

      expect(
        content.contains('softprops/action-gh-release@v2'),
        isTrue,
        reason: 'REQ-IPA-001: Workflow must use softprops/action-gh-release@v2 for asset upload',
      );
      expect(
        content.contains('*.ipa') || content.contains('.ipa'),
        isTrue,
        reason: 'REQ-IPA-001: Release upload files configuration must match *.ipa',
      );
    });
  });

  // ===========================================================================
  // 3. REQ-IPA-002: iOS Native Configuration, Permissions & Sideload Compatibility
  // ===========================================================================
  group('REQ-IPA-002: iOS Native Project Configuration and Permissions', () {
    test('ios/Runner/Info.plist must exist and contain CFBundleDisplayName with 街霸6助手', () {
      final plistFile = File('ios/Runner/Info.plist');
      expect(plistFile.existsSync(), isTrue, reason: 'ios/Runner/Info.plist must exist');

      final content = plistFile.readAsStringSync();
      expect(
        content.contains('<key>CFBundleDisplayName</key>') && content.contains('<string>街霸6助手</string>'),
        isTrue,
        reason: 'REQ-IPA-002: CFBundleDisplayName must be set to 街霸6助手',
      );
    });

    test('ios/Runner/Info.plist must declare NSPhotoLibraryAddUsageDescription permission', () {
      final plistFile = File('ios/Runner/Info.plist');
      final content = plistFile.readAsStringSync();

      expect(
        content.contains('<key>NSPhotoLibraryAddUsageDescription</key>'),
        isTrue,
        reason: 'REQ-IPA-002: Must declare photo library write permission NSPhotoLibraryAddUsageDescription',
      );
      expect(
        content.contains('保存战绩海报长图到系统相册') || content.contains('相册'),
        isTrue,
        reason: 'REQ-IPA-002: Photo library permission description must explain photo saving',
      );
    });

    test('ios/Runner/Info.plist must configure NSAppTransportSecurity with NSAllowsArbitraryLoads', () {
      final plistFile = File('ios/Runner/Info.plist');
      final content = plistFile.readAsStringSync();

      expect(
        content.contains('<key>NSAppTransportSecurity</key>'),
        isTrue,
        reason: 'REQ-IPA-002: Must declare NSAppTransportSecurity for Capcom API communication',
      );
      expect(
        content.contains('<key>NSAllowsArbitraryLoads</key>') && content.contains('<true/>'),
        isTrue,
        reason: 'REQ-IPA-002: NSAllowsArbitraryLoads must be true for cross-domain proxy network access',
      );
    });

    test('ios/Runner/Info.plist must enable ProMotion high refresh rate CADisableMinimumFrameDurationOnPhone', () {
      final plistFile = File('ios/Runner/Info.plist');
      final content = plistFile.readAsStringSync();

      expect(
        content.contains('<key>CADisableMinimumFrameDurationOnPhone</key>') && content.contains('<true/>'),
        isTrue,
        reason: 'REQ-IPA-002: Must enable CADisableMinimumFrameDurationOnPhone for 120Hz display',
      );
    });
  });

  // ===========================================================================
  // 4. REQ-IPA-003: Local Packaging Utility Scripts (Shell & PowerShell)
  // ===========================================================================
  group('REQ-IPA-003: Local Packaging Automation Scripts', () {
    test('scripts/package_unsigned_ipa.sh must exist with complete build and packaging logic', () {
      final shFile = File('scripts/package_unsigned_ipa.sh');
      expect(
        shFile.existsSync(),
        isTrue,
        reason: 'REQ-IPA-003: scripts/package_unsigned_ipa.sh must exist for Unix/macOS build automation',
      );

      final content = shFile.readAsStringSync();
      expect(
        content.contains('flutter build ios --release --no-codesign'),
        isTrue,
        reason: 'REQ-IPA-003: Shell script must execute flutter build ios --release --no-codesign',
      );
      expect(
        content.contains('Payload') && content.contains('zip'),
        isTrue,
        reason: 'REQ-IPA-003: Shell script must assemble Payload/ and zip to .ipa',
      );
      expect(
        content.contains('_unsigned.ipa'),
        isTrue,
        reason: 'REQ-IPA-003: Shell script must produce _unsigned.ipa output',
      );
    });

    test('scripts/package_unsigned_ipa.ps1 must exist with PowerShell packaging logic', () {
      final ps1File = File('scripts/package_unsigned_ipa.ps1');
      expect(
        ps1File.existsSync(),
        isTrue,
        reason: 'REQ-IPA-003: scripts/package_unsigned_ipa.ps1 must exist for Windows PowerShell automation',
      );

      final content = ps1File.readAsStringSync();
      expect(
        content.contains('flutter build ios --release --no-codesign') || content.contains('flutter build ios'),
        isTrue,
        reason: 'REQ-IPA-003: PowerShell script must include flutter build ios command',
      );
      expect(
        content.contains('Payload') && (content.contains('Compress-Archive') || content.contains('zip')),
        isTrue,
        reason: 'REQ-IPA-003: PowerShell script must include Payload assembly and archive logic',
      );
      expect(
        content.contains('_unsigned.ipa') || content.contains('.ipa'),
        isTrue,
        reason: 'REQ-IPA-003: PowerShell script must generate .ipa package',
      );
    });
  });

  // ===========================================================================
  // 5. REQ-DOC-001: iOS Sideloading and Installation Documentation
  // ===========================================================================
  group('REQ-DOC-001: iOS Sideloading Documentation in README & WIKI', () {
    test('README.md must contain comprehensive iOS Sideloading section', () {
      final readmeFile = File('README.md');
      expect(readmeFile.existsSync(), isTrue);

      final content = readmeFile.readAsStringSync();
      expect(
        content.contains('iOS') && (content.contains('巨魔') || content.contains('TrollStore')),
        isTrue,
        reason: 'REQ-DOC-001: README.md must feature TrollStore / 巨魔商店 installation guide',
      );
      expect(
        content.contains('Sideloadly') || content.contains('爱思助手'),
        isTrue,
        reason: 'REQ-DOC-001: README.md must feature Sideloadly / 爱思助手 7-day signing guide',
      );
      expect(
        content.contains('开发者模式') || content.contains('Developer Mode'),
        isTrue,
        reason: 'REQ-DOC-001: README.md must guide users on iOS 16+ Developer Mode',
      );
      expect(
        content.contains('不丢失') || content.contains('不会丢失') || content.contains('覆盖安装'),
        isTrue,
        reason: 'REQ-DOC-001: README.md must explicitly reassure that renewing signing retains local data',
      );
    });

    test('WIKI.md must contain detailed iOS Sideloading and FAQ section', () {
      final wikiFile = File('WIKI.md');
      expect(wikiFile.existsSync(), isTrue);

      final content = wikiFile.readAsStringSync();
      expect(
        content.contains('iOS') && (content.contains('TrollStore') || content.contains('巨魔商店')),
        isTrue,
        reason: 'REQ-DOC-001: WIKI.md must feature TrollStore installation details',
      );
      expect(
        content.contains('Sideloadly') || content.contains('爱思助手'),
        isTrue,
        reason: 'REQ-DOC-001: WIKI.md must feature Sideloadly / 爱思助手 installation details',
      );
      expect(
        content.contains('开发者模式') || content.contains('Developer Mode'),
        isTrue,
        reason: 'REQ-DOC-001: WIKI.md must guide users on Developer Mode',
      );
      expect(
        content.contains('7天') || content.contains('续签') || content.contains('过期'),
        isTrue,
        reason: 'REQ-DOC-001: WIKI.md must explain 7-day expiration and renewal without data loss',
      );
    });
  });
}
