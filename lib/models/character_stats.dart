// Character Stats & Attributes Model for SF6 Assistant
// Matches Supercombo GG & official game data

class CharacterStats {
  final String characterId;
  final String nameZh;
  final String nameEn;
  final String quote;
  final String difficulty;
  final String archetype;

  // Vitals & Throws
  final int lifePoints;
  final double throwRange;
  final double throwHurtbox;

  // Ground Movement
  final double forwardWalkSpeed;
  final double backwardWalkSpeed;
  final int forwardDashSpeed; // Frames
  final int backwardDashSpeed; // Frames
  final double forwardDashDistance;
  final double backwardDashDistance;
  final double driveRushMinThrow;
  final double driveRushMinBlock;
  final double driveRushMax;

  // Jumping
  final String jumpSpeed; // e.g. '4+38+3'
  final double jumpApex;

  // Hitbox library count
  final int hitboxCount;

  const CharacterStats({
    required this.characterId,
    required this.nameZh,
    required this.nameEn,
    required this.quote,
    this.difficulty = '普通',
    this.archetype = '平衡全能型',
    this.lifePoints = 10000,
    this.throwRange = 0.8,
    this.throwHurtbox = 0.33,
    this.forwardWalkSpeed = 0.047,
    this.backwardWalkSpeed = 0.032,
    this.forwardDashSpeed = 19,
    this.backwardDashSpeed = 23,
    this.forwardDashDistance = 1.252,
    this.backwardDashDistance = 0.923,
    this.driveRushMinThrow = 0.525,
    this.driveRushMinBlock = 1.878,
    this.driveRushMax = 3.628,
    this.jumpSpeed = '4+38+3',
    this.jumpApex = 2.115,
    this.hitboxCount = 78,
  });
}
