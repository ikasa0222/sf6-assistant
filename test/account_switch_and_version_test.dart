import 'package:flutter_test/flutter_test.dart';
import 'package:sf6_tracker/core/utils/app_logger.dart';
import 'package:sf6_tracker/models/account_profile.dart';
import 'package:sf6_tracker/services/update_service.dart';

void main() {
  group('Version and Account Switch Tests', () {
    test('Current app version is v1.2.6', () {
      expect(AppLogger.currentAppVersion, equals('v1.2.6'));
    });

    test('UpdateService compares multi-segment test versions correctly', () {
      final service = UpdateService.instance;
      
      // 1.2.5.1 is newer than formal 1.2.5
      expect(service.compareVersionStrings('v1.2.5.1', 'v1.2.5') > 0, isTrue);

      // 1.2.5.2 is newer than 1.2.5.1
      expect(service.compareVersionStrings('v1.2.5.2', 'v1.2.5.1') > 0, isTrue);

      // 1.2.5.1 is older than 1.2.5.2
      expect(service.compareVersionStrings('v1.2.5.1', 'v1.2.5.2') < 0, isTrue);

      // 1.2.6 is newer than 1.2.5.9
      expect(service.compareVersionStrings('v1.2.6', 'v1.2.5.9') > 0, isTrue);

      // Equal versions return 0
      expect(service.compareVersionStrings('v1.2.5.1', '1.2.5.1'), equals(0));
    });

    test('CapcomAccount serialization and platform switching preserves unique identity', () {
      final platSteam = PlatformProfile(
        platformType: PlatformType.steam,
        shortId: '1923437997',
        fighterId: '绫波永不认输',
        currentLp: 15524,
        currentMr: 0,
      );

      final platSwitch = PlatformProfile(
        platformType: PlatformType.nintendoSwitch2,
        shortId: '9876543210',
        fighterId: 'SwitchFighter',
        currentLp: 28000,
        currentMr: 1650,
      );

      final acc1 = CapcomAccount(
        id: 'acc_steam_primary',
        capcomId: '1923437997',
        displayName: '绫波永不认输',
        cookieSession: 'session_1',
        linkedPlatforms: [platSteam, platSwitch],
        activePlatformIndex: 0,
        lastLoginAt: DateTime.now(),
      );

      expect(acc1.activePlatform?.platformType, equals(PlatformType.steam));
      expect(acc1.activePlatform?.fighterId, equals('绫波永不认输'));

      // Switch platform within account
      final switchedAcc = acc1.copyWith(activePlatformIndex: 1);
      expect(switchedAcc.activePlatform?.platformType, equals(PlatformType.nintendoSwitch2));
      expect(switchedAcc.activePlatform?.fighterId, equals('SwitchFighter'));

      // Verify ID remains unchanged
      expect(switchedAcc.id, equals('acc_steam_primary'));
    });
  });
}
