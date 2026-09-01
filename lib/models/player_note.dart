class PlayerNote {
  final String id;
  final String targetKey; // Character ID (e.g. 'akuma') OR Opponent Fighter ID / Short ID
  final bool isCharacterNote; // true if character matchup note, false if player-specific note
  final String title;
  final String content;
  final List<String> tags; // e.g. ['起身习惯', '确反点', '对空', '压制']
  final DateTime updatedAt;

  PlayerNote({
    required this.id,
    required this.targetKey,
    required this.isCharacterNote,
    required this.title,
    required this.content,
    this.tags = const [],
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'targetKey': targetKey,
    'isCharacterNote': isCharacterNote ? 1 : 0,
    'title': title,
    'content': content,
    'tags': tags.join(','),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory PlayerNote.fromMap(Map<String, dynamic> map) => PlayerNote(
    id: map['id'] ?? '',
    targetKey: map['targetKey'] ?? '',
    isCharacterNote: map['isCharacterNote'] == 1 || map['isCharacterNote'] == true,
    title: map['title'] ?? '',
    content: map['content'] ?? '',
    tags: map['tags'] != null && (map['tags'] as String).isNotEmpty
        ? (map['tags'] as String).split(',')
        : [],
    updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
  );
}
