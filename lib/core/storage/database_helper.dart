import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sf6_tracker/models/battle_record.dart';
import 'package:sf6_tracker/models/player_note.dart';
import 'package:sf6_tracker/models/matchup_stat.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sf6_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
      onOpen: (db) async {
        try {
          await db.execute("ALTER TABLE battle_records ADD COLUMN playerControlType TEXT DEFAULT 'C'");
        } catch (_) {}
        try {
          await db.execute("ALTER TABLE battle_records ADD COLUMN opponentControlType TEXT DEFAULT 'C'");
        } catch (_) {}
        try {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS official_rival_matchups (
              shortId TEXT NOT NULL,
              platform TEXT NOT NULL,
              myCharacterId TEXT NOT NULL,
              rivalCharacterId TEXT NOT NULL,
              totalMatches INTEGER NOT NULL,
              wins INTEGER NOT NULL,
              losses INTEGER NOT NULL,
              winRate REAL NOT NULL,
              PRIMARY KEY (shortId, platform, myCharacterId, rivalCharacterId)
            )
          ''');
        } catch (_) {}
      },
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute("ALTER TABLE battle_records ADD COLUMN playerControlType TEXT DEFAULT 'C'");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE battle_records ADD COLUMN opponentControlType TEXT DEFAULT 'C'");
      } catch (_) {}
    }
    if (oldVersion < 3) {
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS official_rival_matchups (
            shortId TEXT NOT NULL,
            platform TEXT NOT NULL,
            myCharacterId TEXT NOT NULL,
            rivalCharacterId TEXT NOT NULL,
            totalMatches INTEGER NOT NULL,
            wins INTEGER NOT NULL,
            losses INTEGER NOT NULL,
            winRate REAL NOT NULL,
            PRIMARY KEY (shortId, platform, myCharacterId, rivalCharacterId)
          )
        ''');
      } catch (_) {}
    }
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE battle_records (
        id TEXT PRIMARY KEY,
        shortId TEXT NOT NULL,
        platform TEXT NOT NULL,
        playedAt TEXT NOT NULL,
        battleType TEXT NOT NULL,
        playerCharacterId TEXT NOT NULL,
        playerScore INTEGER NOT NULL,
        playerLpChange INTEGER NOT NULL,
        playerMrChange INTEGER NOT NULL,
        playerCurrentLp INTEGER,
        playerCurrentMr INTEGER,
        playerControlType TEXT DEFAULT 'C',
        opponentFighterId TEXT NOT NULL,
        opponentShortId TEXT NOT NULL,
        opponentPlatform TEXT NOT NULL,
        opponentCharacterId TEXT NOT NULL,
        opponentScore INTEGER NOT NULL,
        opponentLp INTEGER,
        opponentMr INTEGER,
        opponentRankTier TEXT NOT NULL,
        opponentControlType TEXT DEFAULT 'C',
        isWin INTEGER NOT NULL,
        replayCode TEXT,
        roundsJson TEXT
      )
    ''');

    await db.execute('CREATE INDEX idx_battle_user_plat ON battle_records (shortId, platform)');
    await db.execute('CREATE INDEX idx_battle_playedAt ON battle_records (playedAt DESC)');
    await db.execute('CREATE INDEX idx_battle_opponent_char ON battle_records (opponentCharacterId)');

    await db.execute('''
      CREATE TABLE player_notes (
        id TEXT PRIMARY KEY,
        targetKey TEXT NOT NULL,
        isCharacterNote INTEGER NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        tags TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX idx_notes_target ON player_notes (targetKey)');

    await db.execute('''
      CREATE TABLE official_rival_matchups (
        shortId TEXT NOT NULL,
        platform TEXT NOT NULL,
        myCharacterId TEXT NOT NULL,
        rivalCharacterId TEXT NOT NULL,
        totalMatches INTEGER NOT NULL,
        wins INTEGER NOT NULL,
        losses INTEGER NOT NULL,
        winRate REAL NOT NULL,
        PRIMARY KEY (shortId, platform, myCharacterId, rivalCharacterId)
      )
    ''');
  }

  Future<int> insertOrUpdateBattleRecord(BattleRecord record) async {
    final db = await database;
    return await db.insert(
      'battle_records',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> batchInsertBattleRecords(List<BattleRecord> records) async {
    final db = await database;
    final batch = db.batch();
    for (final record in records) {
      batch.insert(
        'battle_records',
        record.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    final results = await batch.commit(noResult: true);
    return results.length;
  }

  Future<int> deleteBattleRecordsByShortId(String shortId) async {
    final db = await database;
    return await db.delete(
      'battle_records',
      where: 'shortId = ?',
      whereArgs: [shortId],
    );
  }

  Future<List<BattleRecord>> getBattleRecords({
    required String shortId,
    required String platform,
    BattleType? battleType,
    int limit = 50,
    int offset = 0,
  }) async {
    final db = await database;
    String whereClause = 'shortId = ? AND platform = ?';
    List<dynamic> whereArgs = [shortId, platform];

    if (battleType != null) {
      whereClause += ' AND battleType = ?';
      whereArgs.add(battleType.name);
    }

    final maps = await db.query(
      'battle_records',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'playedAt DESC',
      limit: limit,
      offset: offset,
    );

    return maps.map((m) => BattleRecord.fromMap(m)).toList();
  }

  Future<List<MatchupStat>> getMatchupStats({
    required String shortId,
    required String platform,
    String? myCharacterId,
    BattleType? battleType,
  }) async {
    final db = await database;
    String whereClause = 'shortId = ? AND platform = ?';
    List<dynamic> whereArgs = [shortId, platform];

    if (myCharacterId != null && myCharacterId.isNotEmpty && myCharacterId != 'all') {
      whereClause += ' AND playerCharacterId = ?';
      whereArgs.add(myCharacterId);
    }

    if (battleType != null) {
      whereClause += ' AND battleType = ?';
      whereArgs.add(battleType.code);
    }

    final result = await db.rawQuery('''
      SELECT 
        opponentCharacterId,
        COUNT(*) as totalMatches,
        SUM(isWin) as wins,
        COUNT(*) - SUM(isWin) as losses
      FROM battle_records
      WHERE $whereClause
      GROUP BY opponentCharacterId
      ORDER BY totalMatches DESC
    ''', whereArgs);

    final list = <MatchupStat>[];
    for (final row in result) {
      final charId = row['opponentCharacterId'] as String;
      final total = (row['totalMatches'] as num?)?.toInt() ?? 0;
      final wins = (row['wins'] as num?)?.toInt() ?? 0;
      final losses = (row['losses'] as num?)?.toInt() ?? 0;
      final winRate = total > 0 ? (wins / total) * 100.0 : 0.0;

      String formWhere = 'shortId = ? AND platform = ? AND opponentCharacterId = ?';
      List<dynamic> formArgs = [shortId, platform, charId];
      if (myCharacterId != null && myCharacterId.isNotEmpty && myCharacterId != 'all') {
        formWhere += ' AND playerCharacterId = ?';
        formArgs.add(myCharacterId);
      }
      if (battleType != null) {
        formWhere += ' AND battleType = ?';
        formArgs.add(battleType.code);
      }

      final recentRows = await db.rawQuery('''
        SELECT isWin FROM battle_records
        WHERE $formWhere
        ORDER BY playedAt DESC
        LIMIT 5
      ''', formArgs);

      final form = recentRows.map((r) => r['isWin'] == 1).toList();

      list.add(MatchupStat(
        characterId: charId,
        totalMatches: total,
        wins: wins,
        losses: losses,
        winRate: winRate,
        recentForm: form,
      ));
    }
    return list;
  }

  Future<Map<String, int>> getMyCharacterMatchCounts({
    required String shortId,
    required String platform,
    BattleType? battleType,
  }) async {
    final db = await database;
    String whereClause = 'shortId = ? AND platform = ?';
    List<dynamic> whereArgs = [shortId, platform];

    if (battleType != null) {
      whereClause += ' AND battleType = ?';
      whereArgs.add(battleType.code);
    }

    final rows = await db.rawQuery('''
      SELECT playerCharacterId, COUNT(*) as match_count
      FROM battle_records
      WHERE $whereClause
      GROUP BY playerCharacterId
      ORDER BY match_count DESC
    ''', whereArgs);

    final map = <String, int>{};
    for (final r in rows) {
      map[r['playerCharacterId'].toString()] = (r['match_count'] as num).toInt();
    }
    return map;
  }

  Future<List<Map<String, dynamic>>> getRatingHistory({
    required String shortId,
    required String platform,
    BattleType? battleType,
    int limit = 50,
  }) async {
    final db = await database;
    String whereClause = 'shortId = ? AND platform = ?';
    List<dynamic> whereArgs = [shortId, platform];

    if (battleType != null) {
      whereClause += ' AND battleType = ?';
      whereArgs.add(battleType.code);
    }

    whereArgs.add(limit);

    return await db.rawQuery('''
      SELECT playedAt, playerCurrentMr, playerCurrentLp, playerMrChange, playerLpChange, isWin
      FROM battle_records
      WHERE $whereClause
      ORDER BY playedAt ASC
      LIMIT ?
    ''', whereArgs);
  }

  Future<int> saveNote(PlayerNote note) async {
    final db = await database;
    return await db.insert(
      'player_notes',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<PlayerNote>> getNotesForTarget(String targetKey) async {
    final db = await database;
    final maps = await db.query(
      'player_notes',
      where: 'targetKey = ?',
      whereArgs: [targetKey],
      orderBy: 'updatedAt DESC',
    );
    return maps.map((m) => PlayerNote.fromMap(m)).toList();
  }

  Future<List<PlayerNote>> getAllNotes() async {
    final db = await database;
    final maps = await db.query(
      'player_notes',
      orderBy: 'updatedAt DESC',
    );
    return maps.map((m) => PlayerNote.fromMap(m)).toList();
  }

  Future<int> deleteNote(String id) async {
    final db = await database;
    return await db.delete(
      'player_notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> insertOfficialMatchupStats({
    required String shortId,
    required String platform,
    required Map<String, List<MatchupStat>> statsMap,
  }) async {
    final db = await database;
    final batch = db.batch();
    for (final entry in statsMap.entries) {
      final myCharId = entry.key;
      for (final stat in entry.value) {
        batch.insert(
          'official_rival_matchups',
          {
            'shortId': shortId,
            'platform': platform,
            'myCharacterId': myCharId,
            'rivalCharacterId': stat.characterId,
            'totalMatches': stat.totalMatches,
            'wins': stat.wins,
            'losses': stat.losses,
            'winRate': stat.winRate,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
    await batch.commit(noResult: true);
  }

  Future<List<MatchupStat>> getOfficialMatchupStats({
    required String shortId,
    required String platform,
    String? myCharacterId,
  }) async {
    final db = await database;
    final myChar = (myCharacterId == null || myCharacterId.isEmpty || myCharacterId == 'all') ? 'all' : myCharacterId;
    
    // First try exact myCharacterId match
    var rows = await db.query(
      'official_rival_matchups',
      where: 'shortId = ? AND platform = ? AND myCharacterId = ?',
      whereArgs: [shortId, platform, myChar],
      orderBy: 'totalMatches DESC',
    );

    // If empty and requested a specific character, fall back to 'all'
    if (rows.isEmpty && myChar != 'all') {
      rows = await db.query(
        'official_rival_matchups',
        where: 'shortId = ? AND platform = ? AND myCharacterId = ?',
        whereArgs: [shortId, platform, 'all'],
        orderBy: 'totalMatches DESC',
      );
    }

    return rows.map((r) => MatchupStat(
      characterId: r['rivalCharacterId'] as String,
      totalMatches: (r['totalMatches'] as num).toInt(),
      wins: (r['wins'] as num).toInt(),
      losses: (r['losses'] as num).toInt(),
      winRate: (r['winRate'] as num).toDouble(),
    )).toList();
  }
}
