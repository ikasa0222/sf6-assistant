import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sf6_tracker/core/constants/app_colors.dart';
import 'package:sf6_tracker/core/constants/characters.dart';
import 'package:sf6_tracker/data/character_stats_database.dart';
import 'package:sf6_tracker/data/frame_data_database.dart';
import 'package:sf6_tracker/models/frame_data_model.dart';
import 'package:sf6_tracker/ui/widgets/character_avatar.dart';
import 'package:sf6_tracker/ui/widgets/move_action_preview.dart';
import 'package:sf6_tracker/ui/widgets/sf6_command_view.dart';
import 'package:sf6_tracker/utils/sf6_move_media_helper.dart';

class HitboxViewerScreen extends StatefulWidget {
  final String characterId;

  const HitboxViewerScreen({
    super.key,
    required this.characterId,
  });

  @override
  State<HitboxViewerScreen> createState() => _HitboxViewerScreenState();
}

class _HitboxViewerScreenState extends State<HitboxViewerScreen> {
  String _selectedCategory = '全部';

  @override
  Widget build(BuildContext context) {
    final char = Sf6Characters.getById(widget.characterId);
    final stats = CharacterStatsDatabase.getStats(widget.characterId);
    final allMoves = FrameDataDatabase.getCharacterMoves(widget.characterId);

    final normalMoves = allMoves.where((m) => m.type == MoveType.normal).toList();
    final specialMoves = allMoves.where((m) => m.type == MoveType.special).toList();
    final superMoves = allMoves.where((m) => m.type == MoveType.superArt).toList();
    final uniqueMoves = allMoves.where((m) => m.type == MoveType.unique).toList();

    List<FrameMove> displayedMoves;
    switch (_selectedCategory) {
      case '普通技':
        displayedMoves = normalMoves;
        break;
      case '必杀技':
        displayedMoves = specialMoves;
        break;
      case '超必杀技':
        displayedMoves = superMoves;
        break;
      case '特殊技':
        displayedMoves = uniqueMoves;
        break;
      case '全部':
      default:
        displayedMoves = allMoves.where((m) => m.type != MoveType.driveAction).toList();
        break;
    }

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${char.nameZh} · 碰撞框',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Fixed Header Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Character Banner Card (Screenshot 9)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bgSecondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderSubtle, width: 0.8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CharacterAvatar(characterId: widget.characterId, size: 48, showBorder: false),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stats.nameEn,
                              style: const TextStyle(
                                color: AppColors.accentNeonCyan,
                                fontSize: 10,
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              stats.nameZh,
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'HITBOX & HURTBOX LIBRARY',
                              style: TextStyle(color: AppColors.textTertiary, fontSize: 9, letterSpacing: 1),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentNeonCyan.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.accentNeonCyan.withOpacity(0.3), width: 0.8),
                        ),
                        child: Text(
                          '${allMoves.length} 招式',
                          style: const TextStyle(color: AppColors.accentNeonCyan, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Source indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.bgSecondary.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.polyline, size: 13, color: AppColors.accentNeonCyan),
                      SizedBox(width: 6),
                      Text('数据源 (Source) : ', style: TextStyle(color: AppColors.textTertiary, fontSize: 10.5)),
                      Text('ultimateframedata / SF6Frames', style: TextStyle(color: AppColors.accentNeonCyan, fontSize: 10.5, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Category Chips (Dynamic Counts)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _categoryChip('全部', allMoves.where((m) => m.type != MoveType.driveAction).length),
                      const SizedBox(width: 6),
                      _categoryChip('普通技', normalMoves.length),
                      const SizedBox(width: 6),
                      _categoryChip('必杀技', specialMoves.length),
                      const SizedBox(width: 6),
                      _categoryChip('超必杀技', superMoves.length),
                      const SizedBox(width: 6),
                      _categoryChip('特殊技', uniqueMoves.length),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // Scrollable Move List with Real Hitbox Cards
          Expanded(
            child: displayedMoves.isEmpty
                ? const Center(
                    child: Text('暂无该分类招式', style: TextStyle(color: AppColors.textTertiary)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    itemCount: displayedMoves.length,
                    itemBuilder: (context, index) {
                      final move = displayedMoves[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildMoveHitboxCard(move),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _categoryChip(String title, int count) {
    final isSelected = _selectedCategory == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7C4DFF).withOpacity(0.25) : AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF7C4DFF) : AppColors.borderSubtle,
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              '$count',
              style: TextStyle(
                color: isSelected ? const Color(0xFFB388FF) : AppColors.textTertiary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoveHitboxCard(FrameMove move) {
    final startupNum = int.tryParse(move.startup) ?? 6;
    final gifUrl = Sf6MoveMediaHelper.getHitboxGifUrl(widget.characterId, move);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle.withOpacity(0.7), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Visual Hitbox Frame Preview Area
          GestureDetector(
            onTap: () => _openHitboxScrubberModal(move),
            child: Container(
              height: 170,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF14161D),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                border: Border.all(color: Colors.white.withOpacity(0.04), width: 0.5),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  // Stage Grid
                  Positioned.fill(
                    child: CustomPaint(painter: _HitboxGridPainter()),
                  ),

                  // Local simulated hitbox preview (Offline-First, Zero Image.network in list view)
                  _buildSimulatedHitbox(move),

                  // Progressive Network GIF if available
                  if (gifUrl != null)
                    Positioned.fill(
                      child: Image.network(
                        gifUrl,
                        fit: BoxFit.contain,
                        cacheWidth: 320,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),

                  // Active Frame Badge (Bottom Left)
                  Positioned(
                    bottom: 8,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$startupNum',
                        style: const TextStyle(
                          color: Color(0xFFFFA726),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Open Scrubber Button (Bottom Right)
                  Positioned(
                    bottom: 8,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.accentNeonCyan.withOpacity(0.6), width: 0.8),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('逐帧播放', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          Text('OPEN VIEWER', style: TextStyle(color: AppColors.accentNeonCyan, fontSize: 7, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Move Description & Details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        move.name,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Sf6CommandView(
                      rawCommand: move.command,
                      mode: CommandDisplayMode.graphic,
                      iconSize: 15,
                    ),
                  ],
                ),
                if (move.notes.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    move.notes,
                    style: const TextStyle(color: AppColors.textTertiary, fontSize: 10.5),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 10),

                // Frame Metric Row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.bgSecondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _metricCell('发生', '${move.startup}F'),
                      _metricCell('持续', move.active),
                      _metricCell('硬直', move.recovery),
                      _metricCell('被防', move.onBlock, color: _getAdvantageColor(move.onBlock)),
                      _metricCell('命中', move.onHit, color: _getAdvantageColor(move.onHit)),
                      _metricCell('伤害', '${move.damage}'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulatedHitbox(FrameMove move) {
    final char = Sf6Characters.getById(widget.characterId);
    final isLow = move.command.contains('2') || move.name.contains('蹲') || move.name.contains('下段');
    final isAir = move.command.contains('j.') || move.command.contains('空中');

    return Stack(
      alignment: Alignment.center,
      children: [
        // Fighter Silhouette
        Positioned(
          left: 36,
          bottom: 15,
          width: 90,
          height: 140,
          child: Opacity(
            opacity: 0.35,
            child: Image.asset(
              'assets/images/characters/${char.id}.png',
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ),

        // Interactive Hurtbox (Green) & Core Box (Blue) & Strike Hitbox (Red)
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Green Hurtbox (Body)
              Container(
                width: isAir ? 65 : 72,
                height: isLow ? 75 : 110,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF00E676), width: 1.5),
                  color: const Color(0xFF00E676).withOpacity(0.08),
                ),
              ),

              // Blue Core Collision Box (Pushbox)
              Container(
                width: 44,
                height: isLow ? 60 : 92,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF2979FF), width: 1.5),
                  color: const Color(0xFF2979FF).withOpacity(0.08),
                ),
              ),

              // Red Active Hitbox (Strike)
              Positioned(
                right: 0,
                top: isLow ? 40 : (isAir ? 55 : 28),
                child: Container(
                  width: 44,
                  height: 36,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFFF1744), width: 1.8),
                    color: const Color(0xFFFF1744).withOpacity(0.25),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _metricCell(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textTertiary, fontSize: 9.5),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getAdvantageColor(String adv) {
    if (adv.startsWith('+')) return const Color(0xFF00E676);
    if (adv.startsWith('-')) {
      final num = int.tryParse(adv.substring(1));
      if (num != null && num >= 4) return const Color(0xFFFF5252);
      return const Color(0xFFFFA726);
    }
    return Colors.white;
  }

  void _openHitboxScrubberModal(FrameMove move) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _HitboxScrubberModal(
        characterId: widget.characterId,
        move: move,
      ),
    );
  }
}

class _HitboxScrubberModal extends StatefulWidget {
  final String characterId;
  final FrameMove move;

  const _HitboxScrubberModal({
    required this.characterId,
    required this.move,
  });

  @override
  State<_HitboxScrubberModal> createState() => _HitboxScrubberModalState();
}

class _HitboxScrubberModalState extends State<_HitboxScrubberModal> {
  late int _totalFrames;
  late int _startupFrame;
  late int _activeDuration;
  int _currentFrame = 1;

  Timer? _playbackTimer;
  bool _isPlaying = false;
  double _playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _startupFrame = int.tryParse(widget.move.startup) ?? 6;
    _activeDuration = int.tryParse(widget.move.active) ?? 3;
    final recovery = int.tryParse(widget.move.recovery) ?? 15;
    _totalFrames = _startupFrame + _activeDuration + recovery;
    _currentFrame = _startupFrame; // Default to active strike frame
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _startPlayback();
      } else {
        _playbackTimer?.cancel();
      }
    });
  }

  void _startPlayback() {
    _playbackTimer?.cancel();
    final int ms = _playbackSpeed == 0.25 ? 66 : (_playbackSpeed == 0.5 ? 33 : 16);
    _playbackTimer = Timer.periodic(Duration(milliseconds: ms), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_currentFrame >= _totalFrames) {
          _currentFrame = 1;
        } else {
          _currentFrame++;
        }
      });
    });
  }

  void _setSpeed(double speed) {
    setState(() {
      _playbackSpeed = speed;
      if (_isPlaying) {
        _startPlayback();
      }
    });
  }

  bool get _isStartupPhase => _currentFrame < _startupFrame;
  bool get _isActivePhase => _currentFrame >= _startupFrame && _currentFrame < (_startupFrame + _activeDuration);
  bool get _isRecoveryPhase => _currentFrame >= (_startupFrame + _activeDuration);

  @override
  Widget build(BuildContext context) {
    final char = Sf6Characters.getById(widget.characterId);
    final gifUrl = Sf6MoveMediaHelper.getHitboxGifUrl(widget.characterId, widget.move);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF10121A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 38,
            height: 4,
            margin: const EdgeInsets.only(top: 8, bottom: 6),
            decoration: BoxDecoration(
              color: AppColors.borderSubtle,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.move.name} · 逐帧碰撞检视',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${char.nameZh} · 指令 ${widget.move.command}',
                        style: const TextStyle(color: AppColors.accentNeonCyan, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Visual Hitbox Stage Screen
          Container(
            height: 210,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF0C0E14),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSubtle, width: 0.8),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(child: CustomPaint(painter: _HitboxGridPainter())),

                // Genuine Hitbox GIF stream overlay if available
                if (gifUrl != null)
                  Positioned.fill(
                    child: Image.network(
                      gifUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const SizedBox.shrink();
                      },
                    ),
                  ),

                // Character Asset
                Positioned(
                  left: 45,
                  bottom: 20,
                  width: 100,
                  height: 160,
                  child: Opacity(
                    opacity: 0.45,
                    child: Image.asset(
                      'assets/images/characters/${char.id}.png',
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomCenter,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ),

                // Interactive Hitbox / Hurtbox Overlay Box
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Green Hurtbox
                      Container(
                        width: 74,
                        height: 120,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _isRecoveryPhase ? const Color(0xFFFFD54F) : const Color(0xFF00E676),
                            width: 1.8,
                          ),
                          color: _isRecoveryPhase
                              ? const Color(0xFFFFD54F).withOpacity(0.12)
                              : const Color(0xFF00E676).withOpacity(0.08),
                        ),
                      ),
                      // Blue Pushbox
                      Container(
                        width: 46,
                        height: 96,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF2979FF), width: 1.5),
                          color: const Color(0xFF2979FF).withOpacity(0.08),
                        ),
                      ),
                      // Red Active Hitbox (Only renders when frame is inside active window)
                      if (_isActivePhase)
                        Positioned(
                          right: 0,
                          top: 32,
                          child: Container(
                            width: 48,
                            height: 40,
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFFF1744), width: 2.2),
                              color: const Color(0xFFFF1744).withOpacity(0.35),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Current Phase Badge
                Positioned(
                  top: 10,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _isActivePhase
                          ? const Color(0xFFFF1744).withOpacity(0.85)
                          : (_isStartupPhase ? const Color(0xFF2979FF).withOpacity(0.85) : const Color(0xFFFFA726).withOpacity(0.85)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _isActivePhase ? '命中判定发生中 (ACTIVE)' : (_isStartupPhase ? '招式起手阶段 (STARTUP)' : '收招硬直阶段 (RECOVERY)'),
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                // Frame Counter
                Positioned(
                  bottom: 10,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$_currentFrame / $_totalFrames F',
                      style: const TextStyle(color: Color(0xFFFFA726), fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Frame Scrubber Timeline & Stepper
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.skip_previous, color: AppColors.accentNeonCyan),
                      tooltip: '上一帧 (-1F)',
                      onPressed: _currentFrame > 1 ? () => setState(() => _currentFrame--) : null,
                    ),
                    IconButton(
                      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: AppColors.accentNeonCyan, size: 28),
                      tooltip: _isPlaying ? '暂停' : '播放',
                      onPressed: _togglePlayPause,
                    ),
                    Text(
                      '当前帧数: $_currentFrame F',
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next, color: AppColors.accentNeonCyan),
                      tooltip: '下一帧 (+1F)',
                      onPressed: _currentFrame < _totalFrames ? () => setState(() => _currentFrame++) : null,
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFF7C4DFF),
                    inactiveTrackColor: AppColors.bgCard,
                    thumbColor: AppColors.accentNeonCyan,
                    overlayColor: AppColors.accentNeonCyan.withOpacity(0.2),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: _currentFrame.toDouble(),
                    min: 1,
                    max: _totalFrames.toDouble(),
                    divisions: _totalFrames > 1 ? _totalFrames - 1 : 1,
                    onChanged: (val) => setState(() => _currentFrame = val.round()),
                  ),
                ),
                const SizedBox(height: 6),
                // Playback speed and Keyframe Jump Anchors
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _speedButton('0.25x', 0.25),
                    const SizedBox(width: 8),
                    _speedButton('0.5x', 0.5),
                    const SizedBox(width: 8),
                    _speedButton('1.0x', 1.0),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _keyframeButton('起手 STARTUP', 1),
                    _keyframeButton('发生 ACTIVE', _startupFrame),
                    _keyframeButton('收招 RECOVERY', (_startupFrame + _activeDuration).clamp(1, _totalFrames)),
                  ],
                ),
                const SizedBox(height: 10),
                // Legend
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.crop_square, size: 14, color: Color(0xFF00E676)),
                        SizedBox(width: 4),
                        Text('受创框 (Hurtbox)', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.crop_square, size: 14, color: Color(0xFFFF1744)),
                        SizedBox(width: 4),
                        Text('打击框 (Hitbox)', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.crop_square, size: 14, color: Color(0xFF2979FF)),
                        SizedBox(width: 4),
                        Text('碰撞框 (Pushbox)', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),
        ],
      ),
    );
  }

  Widget _speedButton(String label, double speed) {
    final isSelected = _playbackSpeed == speed;
    return GestureDetector(
      onTap: () => _setSpeed(speed),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7C4DFF).withOpacity(0.3) : AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF7C4DFF) : AppColors.borderSubtle,
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFFB388FF) : AppColors.textTertiary,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _keyframeButton(String label, int targetFrame) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.borderSubtle, width: 0.8),
        ),
      ),
      icon: const Icon(Icons.flag_outlined, size: 12, color: AppColors.accentNeonCyan),
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
      ),
      onPressed: () {
        setState(() {
          _currentFrame = targetFrame.clamp(1, _totalFrames);
        });
      },
    );
  }
}

class _HitboxGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1.0;

    const step = 20.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Floor line
    final floorPaint = Paint()
      ..color = const Color(0xFF7C4DFF).withOpacity(0.3)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(0, size.height * 0.82), Offset(size.width, size.height * 0.82), floorPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
