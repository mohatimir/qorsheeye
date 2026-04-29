import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../utils/translations.dart';
import '../utils/constants.dart';
import 'settings_screen.dart';

class MoreTab extends StatelessWidget {
  const MoreTab({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final lang = settings.languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          physics: const BouncingScrollPhysics(),
          children: [
            Text(Tr.get('more', lang), style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87)),
            const SizedBox(height: 32),
            
            // Profile Preview Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primary, AppColors.primary.withAlpha(150)]),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: AppColors.primary.withAlpha(50), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withAlpha(50),
                    child: const Icon(Icons.person, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Qorsheye User', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(Tr.get('manage_profile', lang), style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined, color: Colors.white)),
                ],
              ),
            ),

            const SizedBox(height: 32),
            
            _buildSectionTitle(Tr.get('app_customization', lang)),
            const SizedBox(height: 12),
            _buildActionTile(
              icon: Icons.language,
              title: Tr.get('language', lang),
              subtitle: lang == 'so' ? 'Soomaali' : (lang == 'ar' ? 'العربية' : 'English'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
              isDark: isDark,
            ),
            _buildActionTile(
              icon: Icons.dark_mode_outlined,
              title: Tr.get('dark_theme', lang),
              trailing: Switch(
                value: settings.isDarkMode,
                onChanged: (val) => settings.toggleTheme(val),
                thumbColor: WidgetStateProperty.all(AppColors.primary),
              ),
              onTap: () {},
              isDark: isDark,
            ),

            const SizedBox(height: 24),
            _buildSectionTitle(Tr.get('support', lang)),
            const SizedBox(height: 12),
            _buildActionTile(
              icon: Icons.help_outline_rounded,
              title: Tr.get('help_center', lang),
              onTap: () {},
              isDark: isDark,
            ),
            _buildActionTile(
              icon: Icons.info_outline_rounded,
              title: Tr.get('about', lang),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Qorsheye',
                  applicationVersion: '1.2.0',
                  applicationLegalese: '© 2026 Qorsheye Team',
                );
              },
              isDark: isDark,
            ),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.2),
    );
  }

  Widget _buildActionTile({required IconData icon, required String title, String? subtitle, Widget? trailing, required VoidCallback onTap, required bool isDark}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10)],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.primary.withAlpha(20), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)) : null,
        trailing: trailing ?? Icon(Icons.arrow_forward_ios_rounded, size: 14, color: isDark ? Colors.white24 : Colors.black26),
      ),
    );
  }
}
