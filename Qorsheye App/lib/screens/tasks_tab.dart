import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../providers/settings_provider.dart';
import '../models/task_model.dart';
import '../utils/translations.dart';
import '../utils/constants.dart';
import 'add_task_screen.dart';

class TasksTab extends StatefulWidget {
  const TasksTab({super.key});

  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> {
  String _searchQuery = '';
  String _filterStatus = 'all';
  int? _filterCategoryId;
  String _sortBy = 'date'; // 'date', 'priority', 'name'
  bool _isAscending = false;


  @override
  void dispose() {
    super.dispose();
  }



  void _showTaskDetails(TaskModel task, TaskProvider provider, String lang) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildTaskDetailsSheet(task, provider, lang),
    );
  }

  Widget _buildTaskDetailsSheet(TaskModel task, TaskProvider provider, String lang) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.withAlpha(100), borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  Tr.get('task_details', lang),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              )
            ],
          ),
          const Divider(),
          const SizedBox(height: 10),
          Text(task.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          if (task.description.isNotEmpty)
            Text(task.description, style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 20),
          _buildDetailRow(Icons.calendar_month, Tr.get('date', lang), DateFormat('MMM dd, yyyy').format(task.dueDate ?? DateTime.now())),
          _buildDetailRow(Icons.priority_high, Tr.get('priority', lang), task.priority),
          _buildDetailRow(Icons.info_outline, 'Status', task.status),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    provider.deleteTask(task.id);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: Text(Tr.get('delete', lang)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    provider.changeTaskStatus(task.id, task.status == 'Completed' ? 'Pending' : 'Completed');
                    Navigator.pop(context);
                  },
                  icon: Icon(task.status == 'Completed' ? Icons.undo : Icons.check_circle_outline),
                  label: Text(task.status == 'Completed' ? 'Undo' : Tr.get('mark_done', lang)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final lang = settings.languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Consumer<TaskProvider>(
          builder: (context, provider, child) {
            var tasks = provider.tasks;

            // Search filtering
            if (_searchQuery.isNotEmpty) {
              tasks = tasks.where((t) => t.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
            }
            // Status filtering
            if (_filterStatus != 'all') {
              tasks = tasks.where((t) => t.status.toLowerCase() == _filterStatus.toLowerCase()).toList();
            }
            // Category filtering
            if (_filterCategoryId != null) {
              tasks = tasks.where((t) => t.categoryId == _filterCategoryId).toList();
            }

            // Sorting
            tasks.sort((a, b) {
              int cmp = 0;
              if (_sortBy == 'date') {
                cmp = (a.dueDate ?? DateTime.now()).compareTo(b.dueDate ?? DateTime.now());
              } else if (_sortBy == 'priority') {
                final pMap = {'High': 3, 'Medium': 2, 'Low': 1};
                cmp = (pMap[a.priority] ?? 0).compareTo(pMap[b.priority] ?? 0);
              } else {
                cmp = a.title.compareTo(b.title);
              }
              return _isAscending ? cmp : -cmp;
            });

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 1. Header & Quick Add
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              Tr.get('tasks', lang),
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => setState(() => _isAscending = !_isAscending),
                                  icon: Icon(_isAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 20),
                                ),
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.sort),
                                  onSelected: (val) => setState(() => _sortBy = val),
                                  itemBuilder: (context) => [
                                    PopupMenuItem(value: 'date', child: Text(Tr.get('date', lang))),
                                    PopupMenuItem(value: 'priority', child: Text(Tr.get('priority', lang))),
                                    PopupMenuItem(value: 'name', child: Text(Tr.get('name', lang))),
                                  ],
                                ),
                                IconButton(
                                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTaskScreen())),
                                  icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 32),
                                )
                              ],
                            )
                          ],
                        ),
                        // Removed Quick Add Box as per user request
                      ],
                    ),
                  ),
                ),

                // 2. Category Chips
                SliverToBoxAdapter(
                  child: Container(
                    height: 50,
                    margin: const EdgeInsets.only(top: 16),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: provider.categories.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          final isSelected = _filterCategoryId == null;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(Tr.get('all', lang)),
                              selected: isSelected,
                              onSelected: (_) => setState(() => _filterCategoryId = null),
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87)),
                            ),
                          );
                        }
                        final cat = provider.categories[index - 1];
                        final isSelected = _filterCategoryId == cat.id;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(cat.name),
                            selected: isSelected,
                            onSelected: (_) => setState(() => _filterCategoryId = cat.id),
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87)),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // 3. Search Bar & Status Filters
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TaskFilterHeaderDelegate(
                    searchQuery: _searchQuery,
                    filterStatus: _filterStatus,
                    onSearchChanged: (val) => setState(() => _searchQuery = val),
                    onStatusChanged: (val) => setState(() => _filterStatus = val),
                    isDark: isDark,
                    lang: lang,
                  ),
                ),

                // 4. Task List
                tasks.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.assignment_late_outlined, size: 64, color: Colors.grey.withAlpha(100)),
                              const SizedBox(height: 16),
                              Text(Tr.get('no_tasks_found', lang), style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final task = tasks[index];
                              return _buildPremiumTaskCard(context, task, provider, isDark, lang);
                            },
                            childCount: tasks.length,
                          ),
                        ),
                      ),
              ],
            );
          },
        ),
      ),
    );
  }



  Widget _buildPremiumTaskCard(BuildContext context, TaskModel task, TaskProvider provider, bool isDark, String lang) {
    Color statusColor = _getStatusColor(task.status);
    bool isCompleted = task.status == 'Completed';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Dismissible(
        key: Key('task_${task.id}'),
        direction: DismissDirection.horizontal,
        background: _buildDismissBackground(Icons.check_circle, AppColors.success, Alignment.centerLeft),
        secondaryBackground: _buildDismissBackground(Icons.delete_sweep, AppColors.error, Alignment.centerRight),
        onDismissed: (direction) {
          if (direction == DismissDirection.startToEnd) {
            provider.changeTaskStatus(task.id, 'Completed');
          } else {
            provider.deleteTask(task.id);
          }
        },
        child: GestureDetector(
          onTap: () => _showTaskDetails(task, provider, lang),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isDark ? 40 : 5),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Container(
                    width: 6,
                    decoration: BoxDecoration(
                      color: _getPriorityColor(task.priority),
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () => provider.changeTaskStatus(task.id, isCompleted ? 'Pending' : 'Completed'),
                                child: Container(
                                  margin: const EdgeInsets.only(top: 2, right: 12),
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: isCompleted ? AppColors.success : Colors.transparent,
                                    border: Border.all(
                                      color: isCompleted ? AppColors.success : Colors.grey.shade400,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: isCompleted 
                                    ? const Icon(Icons.check, size: 16, color: Colors.white) 
                                    : null,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task.title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                                        color: isCompleted ? Colors.grey : (isDark ? Colors.white : Colors.black87),
                                      ),
                                    ),
                                    if (task.description.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          task.description,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(Icons.more_vert, size: 20, color: isDark ? Colors.white70 : Colors.black54),
                                onSelected: (val) {
                                  if (val == 'view') _showTaskDetails(task, provider, lang);
                                  if (val == 'edit') {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => AddTaskScreen(task: task)));
                                  }
                                  if (val == 'delete') provider.deleteTask(task.id);
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(value: 'view', child: Row(children: [Icon(Icons.visibility_outlined, size: 18), SizedBox(width: 8), Text(Tr.get('view', lang))])),
                                  PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 18), SizedBox(width: 8), Text(Tr.get('edit', lang))])),
                                  PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: Colors.red), SizedBox(width: 8), Text(Tr.get('delete', lang), style: TextStyle(color: Colors.red))])),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 14, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                task.dueDate != null ? DateFormat('MMM dd, HH:mm').format(task.dueDate!) : 'No Date',
                                style: TextStyle(fontSize: 12, color: statusColor, fontWeight: FontWeight.w600),
                              ),
                              const Spacer(),
                              if (task.categoryId != null)
                                () {
                                  final cats = provider.categories.where((c) => c.id == task.categoryId);
                                  if (cats.isEmpty) return const SizedBox();
                                  final cat = cats.first;
                                  final catColor = AppConstants.parseColor(cat.color);
                                  return Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: catColor.withAlpha(20),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: catColor.withAlpha(40)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(IconData(cat.iconCode, fontFamily: 'MaterialIcons'), size: 10, color: catColor),
                                        const SizedBox(width: 4),
                                        Text(cat.name, style: TextStyle(fontSize: 9, color: catColor, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  );
                                } (),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withAlpha(30),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  Tr.get(task.status.toLowerCase().replaceAll(' ', '_'), lang),
                                  style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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

  Widget _buildDismissBackground(IconData icon, Color color, Alignment alignment) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      alignment: alignment,
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed': return AppColors.success;
      case 'Overdue': return AppColors.error;
      case 'In Progress': return Colors.blue;
      default: return Colors.orange;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High': return AppColors.error;
      case 'Low': return AppColors.success;
      default: return AppColors.warning;
    }
  }
}

class _TaskFilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String searchQuery;
  final String filterStatus;
  final Function(String) onSearchChanged;
  final Function(String) onStatusChanged;
  final bool isDark;
  final String lang;

  _TaskFilterHeaderDelegate({
    required this.searchQuery,
    required this.filterStatus,
    required this.onSearchChanged,
    required this.onStatusChanged,
    required this.isDark,
    required this.lang,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: Tr.get('search_hint', lang),
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: isDark ? AppColors.cardDark : Colors.grey.shade100,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['all', 'Pending', 'In Progress', 'Completed', 'Overdue'].map((status) {
                final isSelected = filterStatus.toLowerCase() == status.toLowerCase();
                final displayLabel = Tr.get(status.toLowerCase().replaceAll(' ', '_'), lang);
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(displayLabel, style: TextStyle(
                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    )),
                    selected: isSelected,
                    onSelected: (val) => onStatusChanged(status.toLowerCase()),
                    selectedColor: AppColors.primary,
                    backgroundColor: isDark ? AppColors.cardDark : Colors.grey.shade200,
                    elevation: isSelected ? 4 : 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 110;

  @override
  double get minExtent => 110;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}

