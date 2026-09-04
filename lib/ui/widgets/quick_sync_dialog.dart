import 'package:flutter/material.dart';
import 'package:sf6_tracker/core/constants/app_colors.dart';
import 'package:sf6_tracker/core/network/capcom_sync_engine.dart';
import 'package:sf6_tracker/services/auth_service.dart';
import 'package:sf6_tracker/services/battle_log_service.dart';
import 'package:sf6_tracker/services/social_service.dart';
import 'package:sf6_tracker/services/stats_service.dart';
import 'package:sf6_tracker/ui/screens/auth/login_webview_screen.dart';

class QuickSyncDialog extends StatefulWidget {
  final AuthService authService;
  final BattleLogService battleLogService;
  final StatsService statsService;
  final SocialService socialService;

  const QuickSyncDialog({
    super.key,
    required this.authService,
    required this.battleLogService,
    required this.statsService,
    required this.socialService,
  });

  static Future<void> show(
    BuildContext context, {
    required AuthService authService,
    required BattleLogService battleLogService,
    required StatsService statsService,
    required SocialService socialService,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => QuickSyncDialog(
        authService: authService,
        battleLogService: battleLogService,
        statsService: statsService,
        socialService: socialService,
      ),
    );
  }

  @override
  State<QuickSyncDialog> createState() => _QuickSyncDialogState();
}

class _QuickSyncDialogState extends State<QuickSyncDialog> {
  String _status = '正在准备官方高速同步...';
  double _progress = 0.1;
  bool _isDone = false;
  bool _isError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startDirectHttpSync();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.bgCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            _isDone ? Icons.check_circle : (_isError ? Icons.error_outline : Icons.sync),
            color: _isDone ? AppColors.winGreen : (_isError ? AppColors.loseRed : AppColors.accentNeonCyan),
          ),
          const SizedBox(width: 8),
          Text(
            _isDone ? '同步完成' : (_isError ? '需要重新登录' : '一键官方数据同步'),
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: AppColors.bgSecondary,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _isDone ? AppColors.winGreen : (_isError ? AppColors.loseRed : AppColors.accentNeonCyan),
                ),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              _status,
              style: TextStyle(
                color: _isError ? AppColors.loseRed : AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            if (_isError) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage,
                style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (_isError) ...[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentNeonCyan),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LoginWebViewScreen(authService: widget.authService),
                ),
              );
            },
            child: const Text('前往网页登录授权', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ] else if (_isDone) ...[
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.winGreen),
            onPressed: () => Navigator.pop(context),
            child: const Text('完成', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ],
    );
  }

  Future<void> _startDirectHttpSync() async {
    final result = await CapcomSyncEngine.performFullSync(
      authService: widget.authService,
      battleLogService: widget.battleLogService,
      statsService: widget.statsService,
      socialService: widget.socialService,
      onProgress: (prog, status) {
        if (mounted) {
          setState(() {
            _progress = prog;
            _status = status;
          });
        }
      },
    );

    if (!mounted) return;

    if (result.success) {
      setState(() {
        _isDone = true;
        _progress = 1.0;
        _status = result.message;
      });

      await Future.delayed(const Duration(milliseconds: 900));
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: AppColors.winGreen,
          ),
        );
      }
    } else {
      setState(() {
        _isError = true;
        _status = result.message;
        _errorMessage = result.needLogin ? '请点击下方按钮前往官方网页登录授权。' : '请检查网络连接后稍后重试。';
      });
    }
  }
}
