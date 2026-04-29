// ============================================================
// lib/screens/splash_screen.dart
// Checks auth state and routes to Login or Dashboard
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
// unused import removed
import 'login_screen.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl      = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fadeAnim  = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);

    _ctrl.forward();
    _initApp();
  }

  Future<void> _initApp() async {
    // Minimum splash duration
    await Future.delayed(const Duration(milliseconds: 1800));

    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    await auth.init();

    if (!mounted) return;

    if (auth.isAuth) {
      // Load tasks for authenticated user
      await context.read<TaskProvider>().init();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
          (_) => false,
        );
      }
    } else {
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
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF00D4AA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                    ),
                    child: const Icon(Icons.check_circle_rounded, size: 56, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  const Text('Qorsheye',
                    style: TextStyle(
                      fontSize: 34, fontWeight: FontWeight.w900,
                      color: Colors.white, letterSpacing: -1,
                    )),
                  const SizedBox(height: 6),
                  Text('Your smart task manager',
                    style: TextStyle(
                      fontSize: 14, color: Colors.white.withValues(alpha: 0.8), letterSpacing: 0.3,
                    )),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: 28, height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
