import 'package:flutter_test/flutter_test.dart';
import 'package:sf6_tracker/models/combo_recipe.dart';
import 'package:sf6_tracker/services/combo_service.dart';
import 'package:sf6_tracker/data/sf6_combos_database.dart';
import 'package:sf6_tracker/ui/widgets/sf6_command_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Sf6CommandView Translation Tests', () {
    test('Translates numpad commands to Chinese terminology correctly', () {
      expect(Sf6CommandView.translateToChinese('5LP'), '站轻拳');
      expect(Sf6CommandView.translateToChinese('2MK'), '蹲中腿');
      expect(Sf6CommandView.translateToChinese('623HP'), '重升龙拳');
      expect(Sf6CommandView.translateToChinese('236P'), '波动拳');
      expect(Sf6CommandView.translateToChinese('214K'), '龙卷旋风腿');
      expect(Sf6CommandView.translateToChinese('PC 5HK, dash, 2HP > 623HP'), contains('确反康'));
    });

    test('Translates commands to modern notation correctly', () {
      expect(Sf6CommandView.translateToModern('5LP'), '5L');
      expect(Sf6CommandView.translateToModern('2MK'), '2M');
      expect(Sf6CommandView.translateToModern('236P'), 'SP');
      expect(Sf6CommandView.translateToModern('623P'), '6+SP');
    });
  });

  group('ComboRecipe Model Tests', () {
    test('Serializes and deserializes correctly', () {
      const recipe = ComboRecipe(
        id: 'test_1',
        characterId: 'ryu',
        starterType: 'Punish Counter',
        comboSequence: 'PC 5HK, dash, 2HP > 623HP',
        position: 'Corner',
        damage: '3000',
        driveGauge: '0',
        superGauge: '0',
        difficulty: 'Easy',
        notes: 'Test notes',
      );

      final json = recipe.toJson();
      final fromJson = ComboRecipe.fromJson(json);

      expect(fromJson.id, 'test_1');
      expect(fromJson.characterId, 'ryu');
      expect(fromJson.starterZh, '确反康');
      expect(fromJson.positionZh, '版边');
      expect(fromJson.difficultyZh, '民工推荐');
      expect(fromJson.damage, '3000');
    });
  });

  group('Sf6CombosDatabase & ComboService Tests', () {
    test('Returns built-in combos for core characters when json cache empty', () {
      final ryuCombos = Sf6CombosDatabase.getCombosForCharacter('ryu');
      expect(ryuCombos.isNotEmpty, true);
      expect(ryuCombos.any((c) => c.starterType.contains('Punish')), true);

      final kenCombos = Sf6CombosDatabase.getCombosForCharacter('ken');
      expect(kenCombos.isNotEmpty, true);

      final lukeCombos = Sf6CombosDatabase.getCombosForCharacter('luke');
      expect(lukeCombos.isNotEmpty, true);
    });

    test('ComboService filters correctly by starter and search text', () {
      final service = ComboService();
      service.loadCombosForCharacter('ryu');

      expect(service.currentCombos.isNotEmpty, true);

      // Filter by starter '确反'
      service.setStarterFilter('确反');
      final filtered = service.filteredCombos;
      expect(filtered.every((c) => c.starterZh.contains('确反')), true);

      // Filter search query
      service.setStarterFilter(null);
      service.setSearchQuery('623HP');
      final searched = service.filteredCombos;
      expect(searched.every((c) => c.comboSequence.contains('623HP') || c.notes.contains('623HP')), true);
    });
  });
}
