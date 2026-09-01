enum MoveType {
  normal,
  unique,
  special,
  superArt,
  throwTech,
  driveAction;

  String get displayName {
    switch (this) {
      case MoveType.normal:
        return '通常技';
      case MoveType.unique:
        return '特殊技';
      case MoveType.special:
        return '必杀技';
      case MoveType.superArt:
        return '超必杀技 (SA)';
      case MoveType.throwTech:
        return '普通投';
      case MoveType.driveAction:
        return '斗气系统';
    }
  }

  static MoveType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'normal':
        return MoveType.normal;
      case 'unique':
      case 'command':
        return MoveType.unique;
      case 'special':
        return MoveType.special;
      case 'sa':
      case 'superart':
        return MoveType.superArt;
      case 'throw':
        return MoveType.throwTech;
      case 'drive':
        return MoveType.driveAction;
      default:
        return MoveType.normal;
    }
  }
}

class FrameMove {
  final String name;
  final String command;
  final MoveType type;
  final int damage;
  final String startup;
  final String active;
  final String recovery;
  final String onBlock; // e.g. "+2", "-4", "-12"
  final String onHit;   // e.g. "+5", "KD" (Knockdown)
  final String driveGaugeDamage;
  final String driveGaugeRecovery;
  final bool isCancelable;
  final String notes;

  FrameMove({
    required this.name,
    required this.command,
    required this.type,
    required this.damage,
    required this.startup,
    required this.active,
    required this.recovery,
    required this.onBlock,
    required this.onHit,
    this.driveGaugeDamage = '0',
    this.driveGaugeRecovery = '0',
    this.isCancelable = false,
    this.notes = '',
  });

  bool get isPlusOnBlock {
    final clean = onBlock.trim();
    if (clean.startsWith('+')) {
      final val = int.tryParse(clean.substring(1));
      return val != null && val > 0;
    }
    return false;
  }

  bool get isPunishableOnBlock {
    final clean = onBlock.trim();
    if (clean.startsWith('-')) {
      final val = int.tryParse(clean.substring(1));
      return val != null && val >= 4; // 4f jab punish standard in SF6
    }
    return false;
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'command': command,
    'type': type.name,
    'damage': damage,
    'startup': startup,
    'active': active,
    'recovery': recovery,
    'onBlock': onBlock,
    'onHit': onHit,
    'driveGaugeDamage': driveGaugeDamage,
    'driveGaugeRecovery': driveGaugeRecovery,
    'isCancelable': isCancelable,
    'notes': notes,
  };

  factory FrameMove.fromJson(Map<String, dynamic> json) => FrameMove(
    name: json['name'] ?? '',
    command: json['command'] ?? '',
    type: MoveType.fromString(json['type'] ?? 'normal'),
    damage: json['damage'] ?? 0,
    startup: json['startup'] ?? '-',
    active: json['active'] ?? '-',
    recovery: json['recovery'] ?? '-',
    onBlock: json['onBlock'] ?? '-',
    onHit: json['onHit'] ?? '-',
    driveGaugeDamage: json['driveGaugeDamage'] ?? '0',
    driveGaugeRecovery: json['driveGaugeRecovery'] ?? '0',
    isCancelable: json['isCancelable'] == true || json['isCancelable'] == 1,
    notes: json['notes'] ?? '',
  );
}

class CharacterFrameData {
  final String characterId;
  final List<FrameMove> moves;

  CharacterFrameData({
    required this.characterId,
    required this.moves,
  });

  Map<String, dynamic> toJson() => {
    'characterId': characterId,
    'moves': moves.map((m) => m.toJson()).toList(),
  };

  factory CharacterFrameData.fromJson(Map<String, dynamic> json) => CharacterFrameData(
    characterId: json['characterId'] ?? '',
    moves: (json['moves'] as List<dynamic>?)
            ?.map((e) => FrameMove.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
  );
}
