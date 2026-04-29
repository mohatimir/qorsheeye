import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/settings_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/task_model.dart';
import '../utils/constants.dart';
import '../utils/translations.dart';

class StatsTab extends StatefulWidget {
  const StatsTab({super.key});

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  String _selectedFilter = 'all'; // 'all', 'daily', 'weekly', 'monthly', 'yearly'

  List<TaskModel> _filterTasks(List<TaskModel> tasks) {
    final now = DateTime.now();
    if (_selectedFilter == 'all') return tasks;

    return tasks.where((task) {
      final dueDate = task.dueDate;
      if (dueDate == null) return false;
      final date = dueDate;

      switch (_selectedFilter) {
        case 'daily':
          return date.year == now.year && date.month == now.month && date.day == now.day;
        case 'weekly':
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          final weekEnd = weekStart.add(const Duration(days: 6));
          return date.isAfter(weekStart.subtract(const Duration(seconds: 1))) && 
                 date.isBefore(weekEnd.add(const Duration(days: 1)));
        case 'monthly':
          return date.year == now.year && date.month == now.month;
        case 'yearly':
          return date.year == now.year;
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = Provider.of<SettingsProvider>(context).languageCode;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Consumer<TaskProvider>(
          builder: (context, provider, child) {
            final allTasks = provider.tasks;
            final categories = provider.categories;
            final tasks = _filterTasks(allTasks);

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 100, top: 16, left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppColors.primary.withAlpha(30), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.analytics_outlined, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Text(Tr.get('stats', lang), style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('all', Tr.get('all', lang), isDark),
                        const SizedBox(width: 8),
                        _buildFilterChip('daily', Tr.get('daily', lang), isDark),
                        const SizedBox(width: 8),
                        _buildFilterChip('weekly', Tr.get('weekly', lang), isDark),
                        const SizedBox(width: 8),
                        _buildFilterChip('monthly', Tr.get('monthly', lang), isDark),
                        const SizedBox(width: 8),
                        _buildFilterChip('yearly', Tr.get('yearly', lang), isDark),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  if (tasks.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Icon(Icons.bar_chart_rounded, size: 80, color: Colors.grey.withAlpha(50)),
                            const SizedBox(height: 16),
                            Text(Tr.get('no_tasks_found', lang), style: const TextStyle(color: Colors.grey, fontSize: 16)),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    // Overview Cards
                    _buildOverview(tasks, lang, isDark),

                    const SizedBox(height: 24),
                    
                    // Status Distribution
                    _buildStatusChart(tasks, lang, isDark),

                    const SizedBox(height: 24),

                    // Category Breakdown
                    _buildCategoryBreakdown(tasks, categories, lang, isDark),

                    const SizedBox(height: 24),
                    
                    // Productivity Score Card
                    _buildProductivityCard(tasks, lang),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterChip(String filter, String label, bool isDark) {
    final isSelected = _selectedFilter == filter;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = filter),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : (isDark ? AppColors.cardDark : Colors.white),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withAlpha(80), blurRadius: 8, offset: const Offset(0, 2))] : [],
          border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.withAlpha(50)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildOverview(List<TaskModel> tasks, String lang, bool isDark) {
    final completed = tasks.where((t) => t.status == 'Completed').length;
    final pending = tasks.where((t) => t.status == 'Pending').length;
    final total = tasks.length;

    return Row(
      children: [
        _buildSummaryMetric(lang == 'so' ? 'Dhammaaday' : 'Done', completed, AppColors.success, isDark),
        const SizedBox(width: 12),
        _buildSummaryMetric(lang == 'so' ? 'Qabyo' : 'Pending', pending, AppColors.warning, isDark),
        const SizedBox(width: 12),
        _buildSummaryMetric(lang == 'so' ? 'Wadarta' : 'Total', total, AppColors.primary, isDark),
      ],
    );
  }

  Widget _buildStatusChart(List<TaskModel> tasks, String lang, bool isDark) {
    final completed = tasks.where((t) => t.status == 'Completed').length;
    final pending = tasks.where((t) => t.status == 'Pending').length;
    final overdue = tasks.where((t) => t.status == 'Overdue').length;
    final total = tasks.length;

    return _buildSectionCard(
      title: lang == 'so' ? 'Qaybinta Heerka' : 'Status Distribution',
      isDark: isDark,
      child: SizedBox(
        height: 200,
        child: PieChart(
          PieChartData(
            sectionsSpace: 4,
            centerSpaceRadius: 40,
            sections: [
              if (completed > 0) PieChartSectionData(
                color: AppColors.success,
                value: completed.toDouble(),
                title: '${((completed/total)*100).toInt()}%',
                radius: 50,
                titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              if (pending > 0) PieChartSectionData(
                color: AppColors.warning,
                value: pending.toDouble(),
                title: '${((pending/total)*100).toInt()}%',
                radius: 50,
                titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              if (overdue > 0) PieChartSectionData(
                color: AppColors.error,
                value: overdue.toDouble(),
                title: '${((overdue/total)*100).toInt()}%',
                radius: 50,
                titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(List<TaskModel> tasks, List<dynamic> categories, String lang, bool isDark) {
    final total = tasks.length;
    return _buildSectionCard(
      title: lang == 'so' ? ' Hawlaha iyo Qaybaha' : 'Tasks by Category',
      isDark: isDark,
      child: Column(
        children: categories.map((cat) {
          final catTasks = tasks.where((t) => t.categoryId == cat.id).length;
          if (catTasks == 0) return const SizedBox();
          final color = AppConstants.parseColor(cat.color);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(IconData(cat.iconCode, fontFamily: 'MaterialIcons'), color: color, size: 16),
                    const SizedBox(width: 8),
                    Text(cat.name, style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black87)),
                    const Spacer(),
                    Text('$catTasks', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : catTasks / total,
                    backgroundColor: color.withAlpha(20),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductivityCard(List<TaskModel> tasks, String lang) {
    final completed = tasks.where((t) => t.status == 'Completed').length;
    final total = tasks.length;
    final score = total == 0 ? 0 : ((completed / total) * 100).toInt();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF673AB7), Color(0xFF3F51B5)]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.primary.withAlpha(50), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Text(lang == 'so' ? 'Heerka Wax-qabadka' : 'Productivity Score', style: const TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 12),
          Text(
            '$score%',
            style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            score > 80 
              ? (lang == 'so' ? 'Shaqo fiican!' : 'Great job!') 
              : (lang == 'so' ? 'Sii wad dedaalka' : 'Keep it up!'),
            style: TextStyle(color: Colors.white.withAlpha(200), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryMetric(String label, int value, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10)],
        ),
        child: Column(
          children: [
            Text('$value', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child, required bool isDark}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}
