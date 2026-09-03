import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sf6_tracker/core/constants/app_colors.dart';
import 'package:sf6_tracker/core/constants/characters.dart';
import 'package:sf6_tracker/core/storage/database_helper.dart';
import 'package:sf6_tracker/core/utils/app_logger.dart';
import 'package:sf6_tracker/models/app_settings.dart';
import 'package:sf6_tracker/models/account_profile.dart';
import 'package:sf6_tracker/services/auth_service.dart';
import 'package:sf6_tracker/services/battle_log_service.dart';
import 'package:sf6_tracker/services/stats_service.dart';
import 'package:sf6_tracker/services/social_service.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sf6_tracker/services/update_service.dart';
import 'package:sf6_tracker/ui/screens/auth/login_webview_screen.dart';
import 'package:sf6_tracker/ui/widgets/character_avatar.dart';
import 'package:sf6_tracker/ui/widgets/quick_sync_dialog.dart';

class SettingsScreen extends StatelessWidget {
  final AuthService authService;
  final BattleLogService? battleLogService;
  final StatsService? statsService;
  final SocialService? socialService;
  final AppSettings settings;
  final Function(AppSettings) onUpdateSettings;

  const SettingsScreen({
    super.key,
    required this.authService,
    this.battleLogService,
    this.statsService,
    this.socialService,
    required this.settings,
    required this.onUpdateSettings,
  });

  @override
  Widget build(BuildContext context) {
    final activeAccount = authService.activeAccount;
    final activePlatform = authService.activePlatform;

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置与账号管理', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          // 1. Account & Platform Switcher Section
          _buildSectionHeader('账号与玩家资料管理 (Account & Profile)'),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              children: [
                // Current Active Capcom ID
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: activeAccount != null ? AppColors.accentNeonCyan : AppColors.bgSecondary,
                    child: Icon(Icons.person, color: activeAccount != null ? Colors.black : AppColors.textTertiary),
                  ),
                  title: Text(
                    activePlatform?.fighterId ?? activeAccount?.displayName ?? '未绑定玩家',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  subtitle: Text(
                    activeAccount != null
                        ? 'Short ID: ${activePlatform?.shortId ?? activeAccount.capcomId}  •  ${activePlatform?.platformType.displayName ?? "Steam"}'
                        : '点击右侧添加账号或直接绑定 Short ID',
                    style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (activeAccount != null)
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppColors.accentNeonCyan, size: 20),
                          tooltip: '修改玩家资料',
                          onPressed: () => _showEditProfileDialog(context),
                        ),
                      TextButton.icon(
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('网页登录'),
                        style: TextButton.styleFrom(foregroundColor: AppColors.accentNeonCyan),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LoginWebViewScreen(authService: authService),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Quick Silent Sync Action
                ListTile(
                  leading: const Icon(Icons.sync, color: AppColors.winGreen),
                  title: const Text('一键静默同步官方最新数据', style: TextStyle(color: AppColors.winGreen, fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('使用已保存会话静默更新 100 场战绩、全角色积分与战队，无需重新登录', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
                  onTap: () {
                    if (battleLogService != null && statsService != null && socialService != null) {
                      QuickSyncDialog.show(
                        context,
                        authService: authService,
                        battleLogService: battleLogService!,
                        statsService: statsService!,
                        socialService: socialService!,
                      );
                    }
                  },
                ),
                const Divider(height: 1),

                // Edit Profile & Quick Bind Actions
                ListTile(
                  leading: const Icon(Icons.edit_note, color: AppColors.accentNeonYellow),
                  title: const Text('修改当前玩家资料 (昵称/积分/平台)', style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                  subtitle: const Text('随时自定义当前玩家名称、Short ID 与段位积分', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
                  onTap: () => _showEditProfileDialog(context),
                ),
                const Divider(height: 1),

                // Manual Bind ID
                ListTile(
                  leading: const Icon(Icons.link, color: AppColors.accentNeonCyan),
                  title: const Text('手动绑定/切换 Short ID', style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                  subtitle: const Text('通过 10 位 Short ID 快速绑定账号', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
                  onTap: () => _showQuickBindDialog(context),
                ),

                // Platform Switcher Chips (Steam, NS2, PSN, Xbox)
                if (activeAccount != null && activeAccount.linkedPlatforms.isNotEmpty) ...[
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '当前生效的游玩平台：',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(activeAccount.linkedPlatforms.length, (index) {
                            final plat = activeAccount.linkedPlatforms[index];
                            final isSelected = activeAccount.activePlatformIndex == index;
                            return ChoiceChip(
                              label: Text(plat.platformType.displayName),
                              selected: isSelected,
                              onSelected: (_) => authService.switchPlatform(index),
                              selectedColor: AppColors.accentNeonCyan.withOpacity(0.25),
                              backgroundColor: AppColors.bgSecondary,
                              labelStyle: TextStyle(
                                color: isSelected ? AppColors.accentNeonCyan : AppColors.textSecondary,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 12,
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ],

                // Logout button
                if (activeAccount != null) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout, color: AppColors.loseRed, size: 20),
                    title: const Text('退出并解绑当前账号', style: TextStyle(color: AppColors.loseRed, fontSize: 14)),
                    onTap: () async {
                      await authService.logoutAccount(activeAccount.id);
                      try {
                        final cookieManager = CookieManager.instance();
                        await cookieManager.deleteAllCookies();
                        await InAppWebViewController.clearAllCache();
                      } catch (_) {}
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('已退出当前账号并清除登录会话凭据')),
                        );
                      }
                    },
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 2. Feature Toggles
          _buildSectionHeader('功能与展示选项 (Features)'),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('官方全角色帧数表', style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                  subtitle: const Text('离线速查全角色发生帧数、防御硬直差与伤害', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
                  value: settings.showFrameData,
                  activeColor: AppColors.accentNeonCyan,
                  onChanged: (val) {
                    onUpdateSettings(settings.copyWith(showFrameData: val));
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('对战对策与心得笔记', style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                  subtitle: const Text('支持为特定角色和对手记录实战对策', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
                  value: settings.showMatchupNotes,
                  activeColor: AppColors.accentNeonCyan,
                  onChanged: (val) {
                    onUpdateSettings(settings.copyWith(showMatchupNotes: val));
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 3. Data & Sync
          _buildSectionHeader('数据归档与系统更新 (Archive & Updates)'),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.system_update_alt, color: AppColors.accentNeonCyan),
                  title: const Text('检查新版本 (GitHub Releases)', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text('在线比对 GitHub 最新发布包与更新日志', style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.accentNeonCyan.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.accentNeonCyan.withOpacity(0.4)),
                    ),
                    child: Text(AppLogger.currentAppVersion, style: const TextStyle(color: AppColors.accentNeonCyan, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  onTap: () => _checkForUpdates(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.download, color: AppColors.accentNeonCyan),
                  title: const Text('导出历史战绩与笔记 (JSON)', style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('已将本地战绩与对策笔记导出至本地备份目录！')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.bug_report, color: AppColors.accentNeonYellow),
                  title: const Text('全局抓包与流水诊断控制台', style: TextStyle(color: AppColors.accentNeonYellow, fontSize: 14, fontWeight: FontWeight.bold)),
                  subtitle: const Text('查看运行日志、网页抓包与一键复制排查报告', style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
                  onTap: () => _showGlobalDiagnosticModal(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: AppColors.loseRed),
                  title: const Text('清空本地战绩缓存', style: TextStyle(color: AppColors.loseRed, fontSize: 14)),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('已清空本地临时缓存。')),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 4. Open Source Info & Version
          Center(
            child: Text(
              '街霸6助手 ${AppLogger.currentAppVersion} (SF6 Assistant Open Source)\nPowered by Buckler\'s Boot Camp & Flutter\nDeveloper: Ayakoi',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textTertiary, fontSize: 11, height: 1.6),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _checkForUpdates(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.accentNeonCyan),
      ),
    );

    final release = await UpdateService.instance.checkForUpdates(isManual: true);
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop(); // Close spinner
    }

    if (!context.mounted) return;

    if (UpdateService.instance.errorMessage.isNotEmpty && release == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ 未能连接到更新服务器，请确认 GitHub 是否有已发布的 Release 或稍后重试。'),
          backgroundColor: AppColors.loseRed,
          duration: Duration(seconds: 4),
        ),
      );
    } else if (release != null && UpdateService.instance.hasNewVersion) {
      UpdateService.instance.showUpdateDialog(context, release);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 当前已是最新版本 (${AppLogger.currentAppVersion})，暂无更新！'),
          backgroundColor: AppColors.winGreen,
        ),
      );
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.accentNeonCyan,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final activePlat = authService.activePlatform;
    final nameController = TextEditingController(text: activePlat?.fighterId ?? 'SF6_Player');
    final shortIdController = TextEditingController(text: activePlat?.shortId ?? '');
    final lpController = TextEditingController(text: '${activePlat?.currentLp ?? 0}');
    final mrController = TextEditingController(text: '${activePlat?.currentMr ?? 0}');
    PlatformType selectedPlatform = activePlat?.platformType ?? PlatformType.steam;
    String selectedMainCharId = activePlat?.mainCharId.isNotEmpty == true ? activePlat!.mainCharId : 'elena';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.bgCard,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.edit, color: AppColors.accentNeonCyan),
                  SizedBox(width: 8),
                  Text('修改玩家资料与主用角色', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: '玩家昵称 (Fighter ID)',
                        prefixIcon: Icon(Icons.person, size: 20, color: AppColors.accentNeonCyan),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: shortIdController,
                      decoration: const InputDecoration(
                        labelText: 'Short ID (个人主页 10 位识别码)',
                        prefixIcon: Icon(Icons.tag, size: 20, color: AppColors.accentNeonYellow),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('选择主玩角色 (Main Character)：', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.bgSecondary,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedMainCharId,
                          isExpanded: true,
                          dropdownColor: AppColors.bgCard,
                          items: Sf6Characters.all.map((c) {
                            return DropdownMenuItem<String>(
                              value: c.id,
                              child: Row(
                                children: [
                                  CharacterAvatar(characterId: c.id, size: 26, showBorder: false),
                                  const SizedBox(width: 8),
                                  Text(c.nameZh, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      '(${c.archetype})',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: AppColors.textTertiary, fontSize: 10),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                selectedMainCharId = val;
                                final usages = battleLogService?.userProfile?.characterUsages ?? [];
                                final match = usages.where((u) => u.characterId.toLowerCase() == val.toLowerCase()).toList();
                                if (match.isNotEmpty && (match.first.lp > 0 || match.first.mr > 0)) {
                                  lpController.text = '${match.first.lp}';
                                  mrController.text = '${match.first.mr}';
                                }
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: lpController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: '当前 LP 积分'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: mrController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: '当前 MR 评分'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text('选择游玩平台：', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: PlatformType.values.map((p) {
                        final isSelected = selectedPlatform == p;
                        return ChoiceChip(
                          label: Text(p.displayName),
                          selected: isSelected,
                          onSelected: (_) => setDialogState(() => selectedPlatform = p),
                          selectedColor: AppColors.accentNeonCyan.withOpacity(0.3),
                          backgroundColor: AppColors.bgSecondary,
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.accentNeonCyan : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('取消', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentNeonCyan),
                  onPressed: () async {
                    final newName = nameController.text.trim().isNotEmpty ? nameController.text.trim() : (activePlat?.fighterId ?? 'SF6_Player');
                    final newSid = shortIdController.text.trim().isNotEmpty ? shortIdController.text.trim() : (activePlat?.shortId ?? '');
                    final newLp = int.tryParse(lpController.text.trim()) ?? (activePlat?.currentLp ?? 0);
                    final newMr = int.tryParse(mrController.text.trim()) ?? (activePlat?.currentMr ?? 0);

                    await authService.updateActiveProfile(
                      fighterId: newName,
                      shortId: newSid,
                      platformType: selectedPlatform,
                      lp: newLp,
                      mr: newMr,
                      mainCharId: selectedMainCharId,
                    );

                    if (dialogContext.mounted) Navigator.pop(dialogContext);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('已成功更新玩家档案：$newName (主用角色: ${Sf6Characters.getById(selectedMainCharId).nameZh})'), backgroundColor: AppColors.winGreen),
                      );
                    }
                  },
                  child: const Text('保存修改', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showQuickBindDialog(BuildContext context) {
    final controller = TextEditingController(text: '');
    final nameController = TextEditingController(text: '');
    final lpController = TextEditingController(text: '0');
    final mrController = TextEditingController(text: '0');
    PlatformType selectedPlatform = PlatformType.steam;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.bgCard,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                 children: [
                  Icon(Icons.person_add, color: AppColors.accentNeonCyan),
                  SizedBox(width: 8),
                  Text('绑定玩家 Short ID / 链接', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '输入 10 位 Short ID 或粘贴个人主页 URL：',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        labelText: 'Short ID 或个人主页网址',
                        hintText: '例如 1234567890 或 https://.../profile/1234567890',
                      ),
                      onChanged: (val) {
                        final reg = RegExp(r'/profile/(\d+)');
                        final match = reg.firstMatch(val);
                        if (match != null) {
                          controller.text = match.group(1)!;
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: '玩家昵称 (Fighter ID)',
                        hintText: '输入你的游戏内昵称',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: lpController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: '当前 LP 积分',
                              hintText: '28000',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: mrController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: '当前 MR 评分',
                              hintText: '1650',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text('选择游玩平台：', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: PlatformType.values.map((p) {
                        final isSelected = selectedPlatform == p;
                        return ChoiceChip(
                          label: Text(p.displayName),
                          selected: isSelected,
                          onSelected: (_) => setDialogState(() => selectedPlatform = p),
                          selectedColor: AppColors.accentNeonCyan.withOpacity(0.3),
                          backgroundColor: AppColors.bgSecondary,
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.accentNeonCyan : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('取消', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentNeonCyan),
                  onPressed: () async {
                    String input = controller.text.trim();
                    final reg = RegExp(r'(\d{8,12})');
                    final match = reg.firstMatch(input);
                    final extractedId = match != null ? match.group(1)! : input;
                    final lpVal = int.tryParse(lpController.text.trim()) ?? 28000;
                    final mrVal = int.tryParse(mrController.text.trim()) ?? 1650;
                    final fighterName = nameController.text.trim().isNotEmpty
                        ? nameController.text.trim()
                        : 'SF6_Player';

                    if (extractedId.isNotEmpty) {
                      await authService.addAccountFromShortId(
                        shortId: extractedId,
                        fighterId: fighterName,
                        platformType: selectedPlatform,
                        lp: lpVal,
                        mr: mrVal,
                      );
                      if (dialogContext.mounted) Navigator.pop(dialogContext);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('已成功绑定玩家: $fighterName (Short ID: $extractedId)')),
                        );
                      }
                    }
                  },
                  child: const Text('确认绑定', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showGlobalDiagnosticModal(BuildContext context) async {
    final activeAccount = authService.activeAccount;
    final activePlatform = authService.activePlatform;
    final dbRecords = await DatabaseHelper.instance.getBattleRecords(
      shortId: activePlatform?.shortId ?? '',
      platform: activePlatform?.platformType.code ?? '',
    );

    if (!context.mounted) return;

    String selectedFilter = 'ALL';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            final logs = AppLogger.instance.getLogsByLevel(selectedFilter);
            final errorWarnCount = AppLogger.instance.errorCount + AppLogger.instance.warnCount;
            final syncCount = AppLogger.instance.syncCount;
            final netCount = AppLogger.instance.netCount;

            final conciseSummary = AppLogger.instance.buildConciseDiagnosticSummary(
              activeAccountName: activeAccount?.displayName ?? '未登录',
              activePlatformName: activePlatform?.platformType.displayName ?? '未选择',
              activeShortId: activePlatform?.shortId ?? '无',
              activeLp: activePlatform?.currentLp ?? 0,
              activeMr: activePlatform?.currentMr ?? 0,
              clubName: activePlatform?.clubName ?? '',
              dbBattleRecordsCount: dbRecords.length,
            );

            final fullReport = AppLogger.instance.buildComprehensiveReport(
              activeAccountName: activeAccount?.displayName ?? '未登录',
              activePlatformName: activePlatform?.platformType.displayName ?? '未选择',
              activeShortId: activePlatform?.shortId ?? '无',
              activeLp: activePlatform?.currentLp ?? 0,
              activeMr: activePlatform?.currentMr ?? 0,
              clubName: activePlatform?.clubName ?? '',
              dbBattleRecordsCount: dbRecords.length,
            );

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Action Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.monitor_heart, color: AppColors.accentNeonYellow, size: 22),
                          const SizedBox(width: 8),
                          const Text('运行黑匣子与诊断日志', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete_sweep, color: AppColors.textTertiary, size: 20),
                            tooltip: '清空历史日志',
                            onPressed: () {
                              AppLogger.instance.clear();
                              setModalState(() {});
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('已清空运行日志缓存'), duration: Duration(seconds: 1)),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: AppColors.textSecondary),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildLogFilterChip('全部 (${AppLogger.instance.logs.length})', 'ALL', selectedFilter, setModalState),
                        const SizedBox(width: 6),
                        _buildLogFilterChip('⚠️ 异常/警告 ($errorWarnCount)', 'ISSUES', selectedFilter, setModalState, alertColor: AppColors.loseRed),
                        const SizedBox(width: 6),
                        _buildLogFilterChip('🔄 同步流水 ($syncCount)', 'SYNC', selectedFilter, setModalState, alertColor: AppColors.winGreen),
                        const SizedBox(width: 6),
                        _buildLogFilterChip('🌐 网络抓包 ($netCount)', 'NET', selectedFilter, setModalState, alertColor: AppColors.accentNeonCyan),
                      ],
                    ),
                  ),
                  const Divider(height: 18),

                  // Log Entries List
                  Expanded(
                    child: logs.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_outline, size: 48, color: AppColors.winGreen.withOpacity(0.5)),
                                const SizedBox(height: 8),
                                const Text('当前分类下暂无日志记录，运行良好', style: TextStyle(color: AppColors.textTertiary, fontSize: 13)),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: logs.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 6),
                            itemBuilder: (c, idx) {
                              final entry = logs[idx];
                              Color badgeColor;
                              Color badgeBg;
                              switch (entry.level) {
                                case 'ERROR':
                                  badgeColor = AppColors.loseRed;
                                  badgeBg = AppColors.loseRed.withOpacity(0.18);
                                  break;
                                case 'WARN':
                                  badgeColor = AppColors.accentNeonYellow;
                                  badgeBg = AppColors.accentNeonYellow.withOpacity(0.18);
                                  break;
                                case 'SYNC':
                                  badgeColor = AppColors.winGreen;
                                  badgeBg = AppColors.winGreen.withOpacity(0.18);
                                  break;
                                case 'NET':
                                  badgeColor = AppColors.accentNeonCyan;
                                  badgeBg = AppColors.accentNeonCyan.withOpacity(0.18);
                                  break;
                                default:
                                  badgeColor = AppColors.textSecondary;
                                  badgeBg = AppColors.bgSecondary;
                              }

                              final timeStr = DateFormat('HH:mm:ss.SSS').format(entry.timestamp);

                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.bgSecondary,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: badgeColor.withOpacity(0.25)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                          decoration: BoxDecoration(
                                            color: badgeBg,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            entry.level,
                                            style: TextStyle(color: badgeColor, fontSize: 9.5, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '[$timeStr]',
                                          style: const TextStyle(color: AppColors.textTertiary, fontSize: 10.5, fontFamily: 'monospace'),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            entry.tag,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    SelectableText(
                                      entry.message,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: entry.level == 'ERROR' ? AppColors.loseRed : AppColors.textPrimary,
                                        fontFamily: 'monospace',
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 10),

                  // Bottom Action Buttons: Quick Summary (Recommended) & Full Blackbox
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.content_paste_go, color: Colors.black, size: 16),
                          label: const Text('📋 复制精简诊断报告 (发给开发)', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12.5)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentNeonYellow,
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: conciseSummary));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('已复制精简诊断报告！内容精炼，无冗余刷屏，可直接发给开发排查。'), backgroundColor: AppColors.winGreen),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.copy_all, size: 15, color: AppColors.accentNeonCyan),
                          label: const Text('复制全量黑匣子', style: TextStyle(color: AppColors.accentNeonCyan, fontSize: 11.5)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.accentNeonCyan),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: fullReport));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('已复制全量黑匣子流水日志！'), backgroundColor: AppColors.accentNeonCyan),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLogFilterChip(String label, String value, String selected, void Function(void Function()) setModalState, {Color? alertColor}) {
    final isSelected = selected == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setModalState(() => selected = value),
      selectedColor: (alertColor ?? AppColors.accentNeonCyan).withOpacity(0.25),
      backgroundColor: AppColors.bgSecondary,
      labelStyle: TextStyle(
        color: isSelected ? (alertColor ?? AppColors.accentNeonCyan) : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 11.5,
      ),
    );
  }
}
