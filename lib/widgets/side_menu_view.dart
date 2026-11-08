import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import '../models/user_model.dart';
import '../utils/background_fetch_service.dart';
import '../pages/hall_of_fame_page.dart';
import '../pages/initial_page.dart';
import '../utils/step_tracker_service.dart';
import '../utils/user_repository.dart';

class SideMenuView extends StatefulWidget {
  final User? user;
  final UserModel? userData;
  final UserDetailedData? detailedData;
  final String? bgImageUrl;

  const SideMenuView({
    super.key,
    required this.user,
    required this.userData,
    this.detailedData,
    this.bgImageUrl,
  });

  @override
  State<SideMenuView> createState() => _SideMenuViewState();
}

class _SideMenuViewState extends State<SideMenuView> {
  late String _displayName;
  final UserRepository _userRepository = UserRepository();

  @override
  void initState() {
    super.initState();
    _displayName = widget.user?.displayName ?? 'Traveler';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '----/--/--';
    final local = date.toLocal();
    return '${local.year}/${local.month.toString().padLeft(2, '0')}/${local.day.toString().padLeft(2, '0')}';
  }

  Future<void> _showEditDisplayNameDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: _displayName);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.menuChangeNicknameTitle),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: l10n.menuChangeNicknameHint,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.menuCancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: Text(l10n.menuSave),
            ),
          ],
        );
      },
    );

    if (newName != null && newName.isNotEmpty && newName != _displayName) {
      try {
        await widget.user?.updateDisplayName(newName);
        await widget.user?.reload();
        setState(() {
          _displayName = newName;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.menuNicknameUpdated)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.menuNicknameUpdateFailed(e.toString()))),
          );
        }
      }
    }
  }

  /// 📩 Googleフォーム（事前入力パラメータ付き）を開く
  Future<void> _launchInquiryForm(BuildContext context) async {
    const String appVersion = '1.0.0';
    final String userId = widget.user?.uid ?? 'unknown';
    final String currentLang = (localeNotifier.value ?? Localizations.localeOf(context)).languageCode;
    final String langLabel = currentLang == 'en' ? 'English' : '日本語 (Japanese)';
    final String nickName = _displayName;

    final uri = Uri.parse(
      'https://docs.google.com/forms/d/e/1FAIpQLSeEZ7nhFIHcs_qzXr7ztMhNvCTInLRgBsAsSkVDNK_pdbC_hw/viewform'
      '?usp=pp_url'
      '&entry.1157106942=${Uri.encodeComponent(appVersion)}'
      '&entry.1722390190=${Uri.encodeComponent(userId)}'
      '&entry.855014139=${Uri.encodeComponent(langLabel)}'
      '&entry.1846488604=${Uri.encodeComponent(nickName)}',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('お問い合わせページを開けませんでした')),
        );
      }
    }
  }

  /// 🚪 ログアウト処理
  Future<void> _handleLogout(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final dialogBgColor = isDarkMode
        ? Colors.black.withValues(alpha: 0.80)
        : Colors.white.withValues(alpha: 0.90);
    final borderColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.20)
        : Colors.white.withValues(alpha: 0.50);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final navigator = Navigator.of(context, rootNavigator: true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AlertDialog(
            backgroundColor: dialogBgColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: borderColor),
            ),
            title: Text(
              l10n.logoutDialogTitle,
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
            content: Text(
              l10n.logoutDialogMessage,
              style: TextStyle(color: textColor, fontSize: 13, height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.logoutCancelButton),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.logoutConfirmButton),
              ),
            ],
          ),
        );
      },
    );

    if (shouldLogout != true) return;
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(child: CircularProgressIndicator()),
      ),
    );

    try {
      if (widget.user != null && widget.userData != null) {
        await _userRepository.saveStepsOnLogout(
          userId: widget.user!.uid,
          todaySteps: widget.userData!.steps,
          totalSteps: widget.userData!.totalSteps,
        ).timeout(const Duration(seconds: 4));
      }
      StepTrackerService.stopTracking();
      await BackgroundFetchService.stop();
      await Future.wait([
        FirebaseAuth.instance.signOut(),
        GoogleSignIn().signOut(),
      ]).timeout(const Duration(seconds: 4));

      navigator.pop();
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const InitialPage()),
        (route) => false,
      );
    } catch (e) {
      navigator.pop();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('ログアウトに失敗しました: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  /// ⚠️ アカウント削除処理（"delete" 入力確認モーダル）
  Future<void> _handleDeleteAccount(BuildContext context) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final dialogBgColor = isDarkMode
        ? Colors.black.withValues(alpha: 0.85)
        : Colors.white.withValues(alpha: 0.95);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.white70 : Colors.black54;
    final navigator = Navigator.of(context, rootNavigator: true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        String inputText = '';
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final isDeleteEnabled = inputText.trim() == 'delete';
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: AlertDialog(
                backgroundColor: dialogBgColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Colors.redAccent, width: 1.5),
                ),
                title: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                    SizedBox(width: 8),
                    Text(
                      'アカウントの削除',
                      style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'アカウントを削除すると、これまでの歩数、獲得した年代、アーティファクトのデータはすべて完全に消去され、復旧できません。\n\n続行するには、下に「delete」と入力してください。',
                      style: TextStyle(color: textColor, fontSize: 13, height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      autofocus: true,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'delete',
                        hintStyle: TextStyle(color: subTextColor),
                        filled: true,
                        fillColor: isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: isDeleteEnabled ? Colors.redAccent : Colors.grey),
                        ),
                      ),
                      onChanged: (val) {
                        setDialogState(() {
                          inputText = val;
                        });
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogCtx, false),
                    child: Text('キャンセル', style: TextStyle(color: subTextColor)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDeleteEnabled ? Colors.redAccent : Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: isDeleteEnabled ? () => Navigator.pop(dialogCtx, true) : null,
                    child: const Text('削除する', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (confirmed != true) return;
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(child: CircularProgressIndicator()),
      ),
    );

    try {
      final user = widget.user;
      if (user != null) {
        // Firestore 側のユーザードキュメント削除
        await FirebaseFirestore.instance.collection('user').doc(user.uid).delete();
        // 追跡停止
        StepTrackerService.stopTracking();
        await BackgroundFetchService.stop();
        // 認証削除
        await user.delete();
      }

      navigator.pop();
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const InitialPage()),
        (route) => false,
      );
    } catch (e) {
      navigator.pop();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('アカウント削除に失敗しました（再ログインが必要な場合があります）: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final currentTheme = themeModeNotifier.value;
    final currentLocale = localeNotifier.value ?? Localizations.localeOf(context);

    final drawerBgColor = isDarkMode
        ? Colors.black.withValues(alpha: 0.55)
        : Colors.white.withValues(alpha: 0.65);
    final borderColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.white.withValues(alpha: 0.40);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.white70 : Colors.black54;

    final int roundNumber = (widget.userData?.gameMode ?? 0) + 1;
    final String startDateStr = _formatDate(widget.userData?.appStartDate);

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: drawerBgColor,
              border: Border(right: BorderSide(color: borderColor)),
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _displayName,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit, size: 18, color: textColor),
                              onPressed: () => _showEditDisplayNameDialog(context),
                              tooltip: l10n.menuChangeNicknameTitle,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // 🌟 周回数
                        Row(
                          children: [
                            Icon(Icons.replay, size: 14, color: subTextColor),
                            const SizedBox(width: 4),
                            Text(
                              '周回数: $roundNumber周目',
                              style: TextStyle(fontSize: 12, color: subTextColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        // 🌟 開始日
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 14, color: subTextColor),
                            const SizedBox(width: 4),
                            Text(
                              '開始日: $startDateStr',
                              style: TextStyle(fontSize: 12, color: subTextColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        SelectableText(
                          'UserID: ${widget.user?.uid ?? l10n.menuNotLoggedIn}',
                          style: TextStyle(fontSize: 11, color: subTextColor),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(color: borderColor),

                // 殿堂
                ListTile(
                  leading: const Icon(Icons.account_balance, color: Colors.amberAccent),
                  title: Text(
                    l10n.hallOfFameTitle,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: subTextColor,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HallOfFamePage(
                          detailedData: widget.detailedData,
                          bgImageUrl: widget.bgImageUrl,
                        ),
                      ),
                    );
                  },
                ),

                // 🌟 お問い合わせ（不具合・オーパーツ報告）
                ListTile(
                  leading: Icon(Icons.help_outline_rounded, color: textColor),
                  title: Text(
                    'お問い合わせ（不具合・オーパーツ報告）',
                    style: TextStyle(color: textColor, fontSize: 14),
                  ),
                  trailing: Icon(Icons.open_in_new, size: 16, color: subTextColor),
                  onTap: () {
                    Navigator.pop(context);
                    _launchInquiryForm(context);
                  },
                ),

                Divider(color: borderColor),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    l10n.menuThemeSection,
                    style: TextStyle(color: subTextColor, fontSize: 12),
                  ),
                ),
                ListTile(
                  leading: Icon(
                    currentTheme == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                    color: textColor,
                  ),
                  title: Text(l10n.menuDarkMode, style: TextStyle(color: textColor)),
                  trailing: Switch(
                    value: isDarkMode,
                    onChanged: (bool value) {
                      setState(() {
                        themeModeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
                      });
                    },
                  ),
                ),
                Divider(color: borderColor),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    l10n.menuLanguageSection,
                    style: TextStyle(color: subTextColor, fontSize: 12),
                  ),
                ),
                RadioListTile<String>(
                  title: Text('日本語', style: TextStyle(color: textColor)),
                  value: 'ja',
                  groupValue: currentLocale.languageCode,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        localeNotifier.value = Locale(value);
                      });
                    }
                  },
                ),
                RadioListTile<String>(
                  title: Text('English', style: TextStyle(color: textColor)),
                  value: 'en',
                  groupValue: currentLocale.languageCode,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        localeNotifier.value = Locale(value);
                      });
                    }
                  },
                ),
                Divider(color: borderColor),

                // ログアウト
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.orangeAccent),
                  title: Text(
                    l10n.menuLogOut,
                    style: const TextStyle(color: Colors.orangeAccent),
                  ),
                  onTap: () => _handleLogout(context),
                ),

                // 🌟 アカウント削除（赤字）
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
                  title: const Text(
                    'アカウントを削除',
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                  onTap: () => _handleDeleteAccount(context),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
