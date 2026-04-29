import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import '../utils/constants.dart';
import 'package:intl/intl.dart';
import '../providers/settings_provider.dart';
import '../utils/translations.dart';
import 'settings_screen.dart';
import 'notifications_screen.dart';
import 'add_task_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _selectedTimeFilter = 'daily';
  final List<String> _timeFilters = ['daily', 'weekly', 'monthly', 'yearly'];
  String _searchQuery = '';
  String _selectedQuickFilter = '';
  final TextEditingController _searchController = TextEditingController();

  String _getDayName(int weekday, String lang) {
    switch (weekday) {
      case 1: return Tr.get('mon', lang);
      case 2: return Tr.get('tue', lang);
      case 3: return Tr.get('wed', lang);
      case 4: return Tr.get('thu', lang);
      case 5: return Tr.get('fri', lang);
      case 6: return Tr.get('sat', lang);
      case 7: return Tr.get('sun', lang);
      default: return '';
    }
  }

  String _getGreeting(String lang) {
    var hour = DateTime.now().hour;
    if (hour < 12) return Tr.get('good_morning', lang);
    if (hour < 18) return Tr.get('good_afternoon', lang);
    return Tr.get('good_evening', lang);
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = settings.languageCode;

    return SafeArea(
      child: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          final tasks = provider.tasks;
          
          final total = tasks.length;
          final completed = tasks.where((t) => t.status == 'Completed').length;
          final pending = tasks.where((t) => t.status == 'Pending').length;
          final overdue = tasks.where((t) => t.status == 'Overdue').length;

          // Filter tasks based on Search, Quick Filter, AND Time Filter
          var filteredTasks = tasks.where((task) {
            bool matchesSearch = _searchQuery.isEmpty || task.title.toLowerCase().contains(_searchQuery.toLowerCase());
            
            bool matchesQuickFilter = true;
            if (_selectedQuickFilter == 'Priority: High') {
              matchesQuickFilter = task.priority == 'High';
            } else if (_selectedQuickFilter == 'Status: In Progress') {
              matchesQuickFilter = task.status == 'In Progress';
            }

            bool matchesTimeFilter = true;
            if (task.dueDate != null) {
              final now = DateTime.now();
              final date = task.dueDate!;
              if (_selectedTimeFilter == 'daily') {
                matchesTimeFilter = date.year == now.year && date.month == now.month && date.day == now.day;
              } else if (_selectedTimeFilter == 'weekly') {
                final weekStart = now.subtract(Duration(days: now.weekday - 1));
                final weekEnd = weekStart.add(const Duration(days: 7));
                matchesTimeFilter = date.isAfter(weekStart.subtract(const Duration(seconds: 1))) && date.isBefore(weekEnd);
              } else if (_selectedTimeFilter == 'monthly') {
                matchesTimeFilter = date.year == now.year && date.month == now.month;
              } else if (_selectedTimeFilter == 'yearly') {
                matchesTimeFilter = date.year == now.year;
              }
            } else if (_selectedTimeFilter != 'all') {
              // If no due date, only show in 'all' or if we want to show 'No Date' tasks in daily? 
              // Usually, undated tasks might show in 'all'. Let's keep them out of specific time filters for organization.
              matchesTimeFilter = false; 
            }

            return matchesSearch && matchesQuickFilter && matchesTimeFilter;
          }).toList();

          final dailyTasks = tasks.where((t) {
            if (t.dueDate == null) return false;
            final now = DateTime.now();
            return t.dueDate!.year == now.year && t.dueDate!.month == now.month && t.dueDate!.day == now.day;
          }).toList();
          final dailyCompleted = dailyTasks.where((t) => t.status == 'Completed').length;
          final dailyProgress = dailyTasks.isEmpty ? 0.0 : dailyCompleted / dailyTasks.length;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF673AB7)]),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(color: AppColors.primary.withAlpha(100), blurRadius: 8, offset: const Offset(0, 4))],
                            ),
                            child: const Text('Q', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Qorsheye', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87)),
                              Text(
                                '${_getGreeting(lang)} | ${_getDayName(DateTime.now().weekday, lang)}, ${DateFormat('d MMM').format(DateTime.now())}',
                                style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _buildHeaderIcon(Icons.notifications_none, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())), isDark),
                          const SizedBox(width: 12),
                          _buildHeaderIcon(Icons.settings_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())), isDark),
                        ],
                      )
                    ],
                  ),
                ),
              ),

              // Progress Card
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark ? [AppColors.primary.withAlpha(200), const Color(0xFF673AB7).withAlpha(200)] : [AppColors.primary, const Color(0xFF673AB7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: AppColors.primary.withAlpha(80), blurRadius: 15, offset: const Offset(0, 10))],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(lang == 'so' ? 'Horumarka Maanta' : "Today's Progress", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text(
                                lang == 'so' ? 'Waxaad dhammaysay $dailyCompleted oo ka mid ah ${dailyTasks.length} hawlood' : 'You completed $dailyCompleted of ${dailyTasks.length} tasks',
                                style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 13),
                              ),
                              const SizedBox(height: 16),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: dailyProgress,
                                  backgroundColor: Colors.white.withAlpha(50),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                  minHeight: 8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 60,
                              height: 60,
                              child: CircularProgressIndicator(
                                value: dailyProgress,
                                backgroundColor: Colors.white.withAlpha(50),
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 6,
                              ),
                            ),
                            Text('${(dailyProgress * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),

              // Search & Filter
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      _buildSearchField(isDark, lang),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildQuickFilterChip(Tr.get('priority_high', lang), 'Priority: High', Colors.red, isDark),
                          const SizedBox(width: 8),
                          _buildQuickFilterChip(Tr.get('in_progress', lang), 'Status: In Progress', Colors.blue, isDark),
                        ],
                      )
                    ],
                  ),
                ),
              ),

              // Summary Cards
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildSummaryCard(Tr.get('total_tasks', lang), total, Colors.blueGrey, Icons.task_alt, isDark)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildSummaryCard(Tr.get('completed', lang), completed, Colors.green, Icons.check_circle_outline, isDark)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildSummaryCard(Tr.get('pending', lang), pending, Colors.orange, Icons.pending_actions, isDark)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildSummaryCard(Tr.get('overdue', lang), overdue, Colors.red, Icons.warning_amber_rounded, isDark)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Time filter
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: _timeFilters.map((f) => _buildTimeFilterTab(f, lang, isDark)).toList(),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Task List
              filteredTasks.isEmpty 
                ? SliverFillRemaining(child: Center(child: Text(Tr.get('list_empty', lang), style: const TextStyle(color: Colors.grey))))
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildTaskCard(filteredTasks.reversed.toList()[index], provider, isDark),
                        childCount: filteredTasks.length,
                      ),
                    ),
                  ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, VoidCallback onTap, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.grey.shade100,
        shape: BoxShape.circle,
      ),
      child: IconButton(icon: Icon(icon, color: isDark ? Colors.white : Colors.black87, size: 20), onPressed: onTap),
    );
  }

  Widget _buildSearchField(bool isDark, String lang) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          hintText: Tr.get('search_hint', lang),
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildQuickFilterChip(String label, String value, Color color, bool isDark) {
    bool isSelected = _selectedQuickFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedQuickFilter = isSelected ? '' : value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(50) : (isDark ? AppColors.cardDark : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : Colors.transparent),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? color : (isDark ? Colors.white70 : Colors.black87), fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSummaryCard(String title, int count, Color color, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Text('$count', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: isDark ? Colors.white : color)),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildTimeFilterTab(String filter, String lang, bool isDark) {
    bool isSelected = _selectedTimeFilter == filter;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTimeFilter = filter),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? (isDark ? AppColors.primary : Colors.white) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected ? [const BoxShadow(color: Colors.black12, blurRadius: 4)] : [],
          ),
          child: Text(
            Tr.get(filter, lang),
            style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? (isDark ? Colors.white : AppColors.primary) : Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(TaskModel task, TaskProvider provider, bool isDark) {
    final priorityColor = task.priority == 'High' ? Colors.red : task.priority == 'Low' ? Colors.green : Colors.orange;
    final isCompleted = task.status == 'Completed';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Dismissible(
        key: Key('home_task_${task.id}'),
        background: _buildSwipeBg(Icons.check, Colors.green, Alignment.centerLeft),
        secondaryBackground: _buildSwipeBg(Icons.delete, Colors.red, Alignment.centerRight),
        onDismissed: (dir) => dir == DismissDirection.startToEnd ? provider.changeTaskStatus(task.id, 'Completed') : provider.deleteTask(task.id),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withAlpha(isDark ? 30 : 5), blurRadius: 10, offset: const Offset(0, 4))],
            border: Border(left: BorderSide(color: priorityColor, width: 4)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: GestureDetector(
              onTap: () => provider.changeTaskStatus(task.id, isCompleted ? 'Pending' : 'Completed'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: isCompleted ? AppColors.success : Colors.transparent,
                  border: Border.all(
                    color: isCompleted ? AppColors.success : Colors.grey.shade400,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: isCompleted 
                  ? const Icon(Icons.check, size: 18, color: Colors.white) 
                  : null,
              ),
            ),
            title: Text(
              task.title, 
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                decoration: isCompleted ? TextDecoration.lineThrough : null, 
                color: isCompleted ? Colors.grey : (isDark ? Colors.white : Colors.black87),
                fontSize: 15,
              )
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 10, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(task.dueDate != null ? DateFormat('MMM dd, HH:mm').format(task.dueDate!) : 'No Date', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  const Spacer(),
                  if (task.categoryId != null)
                    () {
                      final cats = provider.categories.where((c) => c.id == task.categoryId);
                      if (cats.isEmpty) return const SizedBox();
                      final cat = cats.first;
                      final catColor = AppConstants.parseColor(cat.color);
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: catColor.withAlpha(20), shape: BoxShape.circle),
                        child: Icon(IconData(cat.iconCode, fontFamily: 'MaterialIcons'), size: 12, color: catColor),
                      );
                    } (),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: priorityColor.withAlpha(30), borderRadius: BorderRadius.circular(6)),
                    child: Text(task.priority, style: TextStyle(color: priorityColor, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            onTap: () {
               Navigator.push(context, MaterialPageRoute(builder: (_) => AddTaskScreen(task: task)));
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBg(IconData icon, Color color, Alignment align) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
      alignment: align,
      child: Icon(icon, color: Colors.white),
    );
  }
}
