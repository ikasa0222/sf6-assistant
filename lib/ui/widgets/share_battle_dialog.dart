import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sf6_tracker/core/constants/app_colors.dart';
import 'package:sf6_tracker/models/battle_record.dart';
import 'package:sf6_tracker/ui/widgets/share_battle_card.dart';

class ShareBattleDialog extends StatefulWidget {
  final BattleRecord record;

  const ShareBattleDialog({super.key, required this.record});

  static Future<void> show(BuildContext context, BattleRecord record) {
    return showDialog(
      context: context,
      builder: (ctx) => ShareBattleDialog(record: record),
    );
  }

  @override
  State<ShareBattleDialog> createState() => _ShareBattleDialogState();
}

class _ShareBattleDialogState extends State<ShareBattleDialog> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isExporting = false;

  Future<void> _shareImage() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);

    try {
      final Uint8List? imageBytes = await _screenshotController.capture(
        delay: const Duration(milliseconds: 50),
        pixelRatio: 2.5,
      );

      if (imageBytes == null) {
        throw Exception('图片捕获失败');
      }

      final tempDir = await getTemporaryDirectory();
      final fileName = 'sf6_battle_${widget.record.playedAt.millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(imageBytes);

      final shareText = widget.record.replayCode.isNotEmpty
          ? '街霸6战报 (录像号: ${widget.record.replayCode})'
          : '街霸6对战战报';

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text: shareText,
        subject: '街霸6对战战报',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('战报图片生成或分享失败: $e'),
            backgroundColor: AppColors.loseRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  void _copyBattleText() {
    final r = widget.record;
    final winText = r.isWin ? '胜利 (VICTORY)' : '战败 (DEFEAT)';
    final replayText = r.replayCode.isNotEmpty ? '\n录像代码: ${r.replayCode}' : '';
    final text = '【街霸6对战战报】\n结果: $winText\n比分: ${r.playerScore} : ${r.opponentScore}\n对手: ${r.opponentFighterId} (Short ID: ${r.opponentShortId})\n对局模式: ${r.battleType.displayName}$replayText\n来自街霸6助手';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已复制战报文字与录像码至剪贴板'),
        backgroundColor: AppColors.winGreen,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Screenshot(
              controller: _screenshotController,
              child: ShareBattleCard(record: widget.record),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentNeonCyan,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: _isExporting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                          )
                        : const Icon(Icons.share, size: 18),
                    label: Text(
                      _isExporting ? '生成海报中...' : '分享海报图片',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    onPressed: _isExporting ? null : _shareImage,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bgSecondary,
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: AppColors.borderSubtle),
                    ),
                  ),
                  icon: const Icon(Icons.copy, size: 16, color: AppColors.accentNeonYellow),
                  label: const Text('复制文本', style: TextStyle(fontSize: 13)),
                  onPressed: _copyBattleText,
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: '关闭',
                  icon: const Icon(Icons.close, color: AppColors.textTertiary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
