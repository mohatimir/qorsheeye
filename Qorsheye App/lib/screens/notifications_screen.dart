import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import '../utils/constants.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Ogeysiiska (Notifications)', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          final now = DateTime.now();
          // Hel xogtan si dhab ah (Real Data)
          final tasks = provider.tasks.where((t) => t.status != 'Completed').toList();

          // 1. Ogeysiisyada Khatarta (Overdue)
          final overdueTasks = tasks.where((t) {
            if (t.status == 'Overdue') return true;
            if (t.dueDate != null && t.dueDate!.isBefore(now)) return true;
            return false;
          }).toList();

          // 2. Ogeysiisyada Degdega ah (High Priority, Not Overdue)
          final alertTasks = tasks.where((t) {
            return t.priority == 'High' && !overdueTasks.contains(t);
          }).toList();

          // 3. Xusuusinta Caadiga ah (Reminders - Everything else)
          final reminderTasks = tasks.where((t) {
            return !overdueTasks.contains(t) && !alertTasks.contains(t);
          }).toList();

          if (tasks.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                const Text("Ma jiraan ogeysiisyo cusub!", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16)),
              ],
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              if (overdueTasks.isNotEmpty) ...[
                _buildSectionHeader('Overdue Warnings (Khatar)'),
                ...overdueTasks.map((t) => _buildNotificationCard(
                  context: context,
                  task: t,
                  provider: provider,
                  title: 'Waqtigii Waa Dhacay: ${t.title}',
                  time: t.dueDate != null ? _formatTimeAgo(t.dueDate!) : 'Haddaba',
                  icon: Icons.warning_rounded,
                  color: Colors.red,
                  isEscalating: true,
                  hasSnooze: false,
                )),
                const SizedBox(height: 16),
              ],
              
              if (alertTasks.isNotEmpty) ...[
                _buildSectionHeader('Alerts (Wargelin Degdeg ah)'),
                ...alertTasks.map((t) => _buildNotificationCard(
                  context: context,
                  task: t,
                  provider: provider,
                  title: 'Muhiim: ${t.title}',
                  time: t.dueDate != null ? DateFormat('MMM dd, h:mm a').format(t.dueDate!) : 'Waqti La\'aan',
                  icon: Icons.notifications_active,
                  color: Colors.orange,
                  hasSnooze: true,
                )),
                const SizedBox(height: 16),
              ],
              
              if (reminderTasks.isNotEmpty) ...[
                _buildSectionHeader('Reminders (Xusuusin Caadi ah)'),
                ...reminderTasks.map((t) => _buildNotificationCard(
                  context: context,
                  task: t,
                  provider: provider,
                  title: t.title,
                  time: t.dueDate != null ? DateFormat('MMM dd').format(t.dueDate!) : 'Sida ugu dhaqsiyaha badan',
                  icon: Icons.task_alt,
                  color: Colors.blue,
                  hasSnooze: false
                )),
              ],
            ],
          );
        },
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    Duration diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays} maalmood kahor';
    if (diff.inHours > 0) return '${diff.inHours} saacadood kahor';
    if (diff.inMinutes > 0) return '${diff.inMinutes} daqiiqo kahor';
    return 'Haddaba';
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _buildNotificationCard({
    required BuildContext context,
    required TaskModel task,
    required TaskProvider provider,
    required String title,
    required String time,
    required IconData icon,
    required Color color,
    required bool hasSnooze,
    bool isEscalating = false,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: color.withAlpha(25),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(time, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                ),
                if (isEscalating)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(4)),
                    child: const Text('Urgent', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                  )
              ],
            ),
            if (hasSnooze || isEscalating) ...[
              const SizedBox(height: 12),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (hasSnooze)
                    TextButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xusuusinta "${task.title}" waa dib loo dhigay 15 daqiiqo!')));
                      },
                      icon: const Icon(Icons.snooze, size: 18),
                      label: const Text('Snooze 15 min'),
                    ),
                  TextButton.icon(
                    onPressed: () {
                      provider.changeTaskStatus(task.id, 'Completed');
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('"${task.title}" waa lasoo gabagabeeyay!')));
                    },
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Mark Done', style: TextStyle(color: Colors.green)),
                  ),
                ],
              )
            ]
          ],
        ),
      ),
    );
  }
}
