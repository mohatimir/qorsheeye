import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/translations.dart';
import '../utils/constants.dart';
import 'home_tab.dart';
import 'tasks_tab.dart';
import 'categories_tab.dart';
import 'stats_tab.dart';
import 'more_tab.dart';
import 'add_task_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const HomeTab(),
    const TasksTab(),
    const SizedBox.shrink(), // dummy for FAB notch
    const CategoriesTab(),
    const StatsTab(),
    const MoreTab(),
  ];

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to sign out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang      = Provider.of<SettingsProvider>(context).languageCode;
    final auth      = context.watch<AuthProvider>();
    final safeIndex = _currentIndex < _tabs.length ? _currentIndex : 0;

    return Scaffold(
      body: IndexedStack(
        index: safeIndex,
        children: _tabs,
      ),

      // ---- Error snackbar from task provider ----
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTaskScreen()));
          if (!context.mounted) return;
          context.read<TaskProvider>().refresh();
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        padding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: kBottomNavigationBarHeight + 2,
          child: BottomNavigationBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            currentIndex: safeIndex,
            onTap: (index) {
              if (index == 2) return;
              // Tapping stats tab refreshes on each visit
              if (index == 4 && _currentIndex != 4) {
                context.read<TaskProvider>().refresh();
              }
              setState(() => _currentIndex = index);
            },
            items: [
              BottomNavigationBarItem(icon: const Icon(Icons.dashboard_rounded),   label: Tr.get('home', lang)),
              BottomNavigationBarItem(icon: const Icon(Icons.list_alt_rounded),    label: Tr.get('tasks', lang)),
              const BottomNavigationBarItem(
                icon: Icon(Icons.circle, color: Colors.transparent, size: 0), label: ''),
              BottomNavigationBarItem(icon: const Icon(Icons.folder_rounded),      label: Tr.get('categories', lang)),
              BottomNavigationBarItem(icon: const Icon(Icons.bar_chart_rounded),   label: Tr.get('stats', lang)),
              BottomNavigationBarItem(icon: const Icon(Icons.more_horiz_rounded),  label: Tr.get('more', lang)),
            ],
          ),
        ),
      ),

      // User avatar / logout in app bar handled per-tab via AppBar actions
      // Provide logout button via a persistent icon
      endDrawer: _buildDrawer(context, auth),
    );
  }

  Drawer _buildDrawer(BuildContext context, AuthProvider auth) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Drawer(
      backgroundColor: isDark ? const Color(0xFF1C1C2E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white.withValues(alpha: 0.25),
                      child: Text(
                        (auth.user?.name.isNotEmpty == true)
                            ? auth.user!.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(auth.user?.name ?? 'User',
                            style: const TextStyle(color: Colors.white,
                              fontWeight: FontWeight.w700, fontSize: 16),
                            overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text(auth.user?.email ?? '',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                            overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const Spacer(),
              // Logout
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                  label: const Text('Sign Out',
                    style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
