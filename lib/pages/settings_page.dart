import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../utils/constants.dart';
import '../services/managers.dart';
import '../services/update_service.dart';
import '../services/user_session.dart';
import '../services/supabase_service.dart';
import 'personal_details_page.dart';
import 'phone_numbers_page.dart';
import 'change_email_page.dart';
import 'chat_settings_page.dart';
import 'notification_settings_page.dart';
import 'info_page.dart';
import 'dark_mode_page.dart';
import 'change_password_page.dart';
import 'delete_account_page.dart';
import 'home_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String selectedLanguage = "English";
  String _phone = "";
  String _email = "";
  bool _checkingUpdate = false;

  @override
  void initState() {
    super.initState();
    _loadSettingsData();
  }

  Future<void> _loadSettingsData() async {
    final data = await ProfileManager.getProfileData();
    setState(() {
      _phone = data['phone'] ?? "";
      _email = data['email'] ?? "";
    });
  }

  void _showLanguagePicker(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: pureBlack,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: pureWhite.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 24),
                        const Text(
                          "Change language",
                          style: TextStyle(
                            color: pureWhite,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: pureWhite),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: pureWhite.withValues(alpha: 0.1)),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildLanguageItem(
                          "English",
                          "English",
                          selectedLanguage == "English",
                          () {
                            setState(() => selectedLanguage = "English");
                            setModalState(() {});
                            Navigator.pop(context);
                          },
                        ),
                        _buildLanguageItem(
                          "Swahili",
                          "Kiswahili",
                          selectedLanguage == "Swahili",
                          () {
                            setState(() => selectedLanguage = "Swahili");
                            setModalState(() {});
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildLanguageItem(String title, String subtitle, bool isSelected, VoidCallback onTap) {
    return ListTile(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? pureYellow : pureWhite,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: tajiTextLight.withValues(alpha: 0.6),
          fontSize: 14,
        ),
      ),
      trailing: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? pureYellow : pureWhite.withValues(alpha: 0.24),
            width: 2,
          ),
        ),
        child: isSelected
            ? Center(
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: pureYellow,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Settings",
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          _buildSettingGroup([
            _buildSettingItem(
              "Personal info",
              Icons.person_rounded,
              pureYellow,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PersonalDetailsPage())),
            ),

          ]),
          const SizedBox(height: 24),

          _buildSettingGroup([
            _buildSettingItem(
              "Phone numbers",
              Icons.phone_rounded,
              pureYellow,
              value: _phone,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PhoneNumbersPage())),
            ),
            _buildSettingItem(
              "Change email",
              Icons.alternate_email_rounded,
              pureYellow,
              value: _email,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangeEmailPage())),
            ),
            _buildSettingItem(
              "Change language",
              Icons.language_rounded,
              pureYellow,
              value: selectedLanguage,
              onTap: () => _showLanguagePicker(context),
            ),
          ]),
          const SizedBox(height: 24),

          _buildSettingGroup([
            _buildSettingItem(
              "Disable chats",
              Icons.chat_bubble_rounded,
              pureYellow,
              value: "Enabled",
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatSettingsPage())),
            ),

            _buildSettingItem(
              "Manage notifications",
              Icons.notifications_rounded,
              pureYellow,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationSettingsPage())),
            ),
          ]),
          const SizedBox(height: 24),

          _buildSettingGroup([
            _buildSettingItem(
              "About Taji",
              Icons.info_rounded,
              pureYellow,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const InfoPage(title: "About Taji"))),
            ),

            _buildSettingItem(
              "Dark mode",
              Icons.dark_mode_rounded,
              pureYellow,
              value: themeNotifier.value == ThemeMode.dark 
                  ? "On" 
                  : themeNotifier.value == ThemeMode.light 
                      ? "Off" 
                      : "System (default)",
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DarkModePage())),
            ),
            _buildSettingItem(
              "Check for updates",
              Icons.system_update_rounded,
              pureYellow,
              value: _checkingUpdate ? "Checking..." : null,
              trailing: _checkingUpdate
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: pureYellow, strokeWidth: 2))
                  : null,
              onTap: _checkForUpdateManually,
            ),
          ]),
          const SizedBox(height: 24),

          _buildSettingGroup([
            _buildSettingItem(
              "Change password",
              Icons.lock_rounded,
              pureYellow,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordPage())),
            ),
            _buildSettingItem(
              "Delete my account permanently",
              Icons.delete_forever_rounded,
              pureYellow,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DeleteAccountPage())),
            ),
            _buildSettingItem(
              "Log out",
              Icons.logout_rounded,
              pureYellow,
              onTap: () => _showLogoutConfirmation(context),
            ),
          ]),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Future<void> _checkForUpdateManually() async {
    setState(() => _checkingUpdate = true);
    String currentVersion = '0.1.0';
    try {
      final info = await PackageInfo.fromPlatform();
      currentVersion = info.version;
    } catch (_) {}
    final update = await UpdateService.checkForUpdate(currentVersion);
    if (!mounted) return;
    setState(() => _checkingUpdate = false);

    if (update == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have the latest version'), backgroundColor: Color(0xFF22C55E)),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A202C),
        title: const Text('Update Available', style: TextStyle(color: pureWhite)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('v${update['version']}', style: const TextStyle(color: pureYellow, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(update['notes'] as String, style: const TextStyle(color: pureWhite)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Later', style: TextStyle(color: tajiTextMutedDark)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              UpdateService.downloadAndInstall(update['url'] as String, context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: pureYellow, foregroundColor: pureBlack),
            child: const Text('Update Now'),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: pureBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close, color: pureWhite, size: 24),
                ),
              ],
            ),
            const Text(
              "Are you sure you want to log out?",
              style: TextStyle(
                color: pureWhite,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "You won't receive any messages or notifications",
              style: TextStyle(
                color: pureWhite.withValues(alpha: 0.5),
                fontSize: 14,
                
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () async {
                  HapticFeedback.mediumImpact();
                  await SupabaseService.signOut();
                  await UserSession.clearSession();
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomePage()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF87171),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Log out",
                  style: TextStyle(
                    color: tajiTextLight,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFF87171)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "I changed my mind",
                  style: TextStyle(
                    color: Color(0xFFF87171),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: List.generate(children.length, (index) {
          if (index == children.length - 1) return children[index];
          return Column(
            children: [
              children[index],
              Divider(height: 1, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05)),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSettingItem(
    String title,
    IconData icon,
    Color iconBgColor, {
    String? value,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconBgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: tajiTextLight, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            Text(
              value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 14,
                
              ),
            ),
          const SizedBox(width: 8),
          trailing ?? Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), size: 20),
        ],
      ),
    );
  }


}
