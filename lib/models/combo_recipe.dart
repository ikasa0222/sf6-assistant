// Combo Recipe Model for SF6 Assistant
// Represents structured combo recipes from Supercombo GG & community data

class ComboRecipe {
  final String id;
  final String characterId;
  final String starterType; // e.g., 'Punish Counter', 'Normal Hit', 'Counter Hit', 'Drive Impact', 'Drive Rush'
  final String comboSequence; // e.g., 'PC 5HK, dash, 2HP > 623HP'
  final String position; // e.g., 'Anywhere', 'Corner', 'Midscreen'
  final String damage; // e.g., '3000 / 3430'
  final String driveGauge; // e.g., '0' or '1' or '2' or '3'
  final String superGauge; // e.g., '0' or '1' or '3'
  final String difficulty; // e.g., 'Easy', 'Medium', 'Hard'
  final String notes;
  final String source;

  const ComboRecipe({
    required this.id,
    required this.characterId,
    required this.starterType,
    required this.comboSequence,
    this.position = 'Anywhere',
    this.damage = '-',
    this.driveGauge = '0',
    this.superGauge = '0',
    this.difficulty = 'Easy',
    this.notes = '',
    this.source = 'Supercombo GG',
  });

  String get starterZh {
    switch (starterType.trim().toLowerCase()) {
      case 'punish counter':
      case 'punish':
        return '确反康';
      case 'counter hit':
      case 'ch':
        return '打断康';
      case 'drive impact':
      case 'di':
        return '斗气迸发';
      case 'drive rush':
      case 'drive rush combos':
      case 'dr':
        return '绿冲起手';
      case 'normal hit':
      case 'normal':
        return '普通命中';
      case 'anti-air':
        return '对空截杀';
      case 'corner':
        return '版边专属';
      default:
        return starterType;
    }
  }

  String get positionZh {
    final lower = position.toLowerCase();
    if (lower.contains('corner')) return '版边';
    if (lower.contains('midscreen')) return '版中';
    return '全屏/任意';
  }

  String get difficultyZh {
    final lower = difficulty.toLowerCase();
    if (lower.contains('very easy')) return '入门级';
    if (lower.contains('easy')) return '民工推荐';
    if (lower.contains('hard') || lower.contains('expert')) return '高难进阶';
    return '标准实用';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'characterId': characterId,
    'starterType': starterType,
    'comboSequence': comboSequence,
    'position': position,
    'damage': damage,
    'driveGauge': driveGauge,
    'superGauge': superGauge,
    'difficulty': difficulty,
    'notes': notes,
    'source': source,
  };

  factory ComboRecipe.fromJson(Map<String, dynamic> json) => ComboRecipe(
    id: json['id'] ?? '',
    characterId: json['characterId'] ?? '',
    starterType: json['starterType'] ?? 'Normal Hit',
    comboSequence: json['comboSequence'] ?? '',
    position: json['position'] ?? 'Anywhere',
    damage: json['damage'] ?? '-',
    driveGauge: json['driveGauge']?.toString() ?? '0',
    superGauge: json['superGauge']?.toString() ?? '0',
    difficulty: json['difficulty'] ?? 'Easy',
    notes: json['notes'] ?? '',
    source: json['source'] ?? 'Supercombo GG',
  );
}
