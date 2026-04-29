import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../utils/translations.dart';
import '../services/audio_service.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _playSound(String soundName) {
    AudioService.playPreview(soundName);
  }

  final List<Color> _accentColors = const [
    AppColors.primary,
    Colors.purple,
    Colors.teal,
    Colors.orange,
    Colors.pink,
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsProvider, AuthProvider>(
      builder: (context, settings, auth, child) {
        String lang = settings.languageCode;
        bool isDarkTheme = settings.isDarkMode;
        final user = auth.user;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(Tr.get('settings', lang)),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // --- User Profile Section ---
              if (user != null) ...[
                _buildSectionHeader(lang == 'so' ? 'MUUQAALKA ISTICMAALAHA' : 'USER PROFILE'),
                _buildCardGroup(context, [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: settings.accentColor.withAlpha(50),
                      child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U', 
                        style: TextStyle(color: settings.accentColor, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(user.name, style: _textStyle(isDarkTheme)),
                    subtitle: Text(user.email, style: _subTextStyle()),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _showEditNameDialog(context, auth, user.name),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.lock_outline, color: Colors.orange),
                    title: Text(lang == 'so' ? 'Bedel Password-ka' : 'Change Password', style: _textStyle(isDarkTheme)),
                    onTap: () => _showChangePasswordDialog(context, auth),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: Text(lang == 'so' ? 'Ka Bax' : 'Logout', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                    onTap: () async {
                      final confirm = await _showConfirmLogout(context);
                      if (confirm == true) {
                        await auth.logout();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                          );
                        }
                      }
                    },
                  ),
                ]),
                const SizedBox(height: 24),
              ],

              _buildSectionHeader(Tr.get('app_customization', lang)),
              _buildCardGroup(context, [
                SwitchListTile(
                  title: Text(Tr.get('dark_theme', lang), style: _textStyle(isDarkTheme)),
                  subtitle: Text(Tr.get('toggle_dark', lang), style: _subTextStyle()),
                  value: settings.isDarkMode,
                  activeTrackColor: settings.accentColor.withAlpha(128),
                  // ignore: deprecated_member_use
                  activeColor: settings.accentColor,
                  onChanged: (val) => settings.toggleTheme(val),
                  secondary: Icon(Icons.dark_mode, color: settings.accentColor),
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.language, color: settings.accentColor),
                  title: Text(Tr.get('language', lang), style: _textStyle(isDarkTheme)),
                  trailing: DropdownButton<String>(
                    value: settings.languageCode,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'so', child: Text('Somali')),
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'ar', child: Text('العربية')),
                    ],
                    onChanged: (val) {
                      if (val != null) settings.setLanguage(val);
                    },
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.library_music, color: settings.accentColor),
                  title: Text(lang == 'so' ? 'Dhawaaqa' : 'Sound', style: _textStyle(isDarkTheme)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButton<String>(
                        value: settings.notificationSound,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: 'universfield_new_notification_022_370046', child: Text('Standard')),
                          DropdownMenuItem(value: 'universfield_new_notification_09_352705', child: Text('Soft')),
                          DropdownMenuItem(value: 'mixkit_doorbell_single_press_333', child: Text('Doorbell')),
                          DropdownMenuItem(value: 'mixkit_happy_bells_notification_937', child: Text('Happy Bells')),
                          DropdownMenuItem(value: 'mixkit_software_interface_remove_2576', child: Text('Interface')),
                          DropdownMenuItem(value: 'mixkit_urgent_simple_tone_loop_2976', child: Text('Urgent')),
                        ],
                        onChanged: (val) {
                          if (val != null) settings.setNotificationSound(val);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.play_circle_fill, color: settings.accentColor),
                        onPressed: () => _playSound(settings.notificationSound),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(Tr.get('accent_color', lang), style: _textStyle(isDarkTheme)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: _accentColors.map((color) {
                          bool isSelected = settings.accentColor == color;
                          return GestureDetector(
                            onTap: () => settings.setAccentColor(color),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: color,
                              child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
                            ),
                          );
                        }).toList(),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ]),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  void _showEditNameDialog(BuildContext context, AuthProvider auth, String currentName) {
    final ctrl = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Full Name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (ctrl.text.trim().isNotEmpty) {
                await auth.updateProfile(ctrl.text.trim());
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, AuthProvider auth) {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: oldCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Current Password')),
            TextField(controller: newCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'New Password (min 8 chars)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (oldCtrl.text.isNotEmpty && newCtrl.text.length >= 8) {
                final success = await auth.changePassword(oldCtrl.text, newCtrl.text);
                if (context.mounted) {
                  if (success) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password changed successfully')));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.error ?? 'Failed to change password')));
                  }
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showConfirmLogout(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Logout', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildCardGroup(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(children: children),
    );
  }

  TextStyle _textStyle(bool isDark) => TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600);
  TextStyle _subTextStyle() => const TextStyle(color: Colors.grey, fontSize: 12);
}
