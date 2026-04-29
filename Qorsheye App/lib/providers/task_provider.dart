// ============================================================
// lib/providers/task_provider.dart  (v2 — remote API)
// Replaces local Hive-only storage with full remote sync
// ============================================================

import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../models/category_model.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../services/widget_service.dart';

class TaskProvider with ChangeNotifier {
  List<TaskModel>     _tasks      = [];
  List<CategoryModel> _categories = [];
  bool   _isLoading = false;
  bool   _isSyncing = false;
  String? _error;

  // Pagination state
  int  _currentPage = 1;
  int  _lastPage    = 1;
  int  _total       = 0;

  // Active filters
  String _filterStatus   = '';
  String _filterPriority = '';
  int?   _filterCategory;
  String _searchQuery    = '';
  String _sortBy         = 'due_date';

  // --- Getters ---
  List<TaskModel>     get tasks        => _tasks;
  List<CategoryModel> get categories   => _categories;
  bool                get isLoading    => _isLoading;
  bool                get isSyncing    => _isSyncing;
  String?             get error        => _error;
  int                 get total        => _total;
  int                 get currentPage  => _currentPage;
  int                 get lastPage     => _lastPage;
  bool                get hasMorePages => _currentPage < _lastPage;

  String get filterStatus   => _filterStatus;
  String get filterPriority => _filterPriority;
  int?   get filterCategory => _filterCategory;
  String get searchQuery    => _searchQuery;
  String get sortBy         => _sortBy;

  // ----------------------------------------------------------------
  // Init — called after auth succeeds
  // ----------------------------------------------------------------
  Future<void> init() async {
    _currentPage = 1;
    _tasks       = [];
    await loadTasks();
    await loadCategories();
  }

  // ----------------------------------------------------------------
  // Load tasks with current filters (resets to page 1)
  // ----------------------------------------------------------------
  Future<void> loadTasks({bool append = false}) async {
    if (!append) {
      _currentPage = 1;
      _isLoading   = true;
      _error       = null;
      notifyListeners();
    } else {
      _isSyncing = true;
      notifyListeners();
    }

    try {
      final query = <String, String>{
        'action': 'get_tasks',
        'page':   _currentPage.toString(),
        if (_filterStatus.isNotEmpty)   'status':      _filterStatus,
        if (_filterPriority.isNotEmpty) 'priority':    _filterPriority,
        if (_filterCategory != null)    'category_id': _filterCategory.toString(),
        if (_searchQuery.isNotEmpty)    'search':      _searchQuery,
        'sort': _sortBy,
      };

      final res    = await ApiService.get('tasks.php', query: query);
      final data   = res['data'] as Map<String, dynamic>;
      final list   = (data['tasks'] as List).map((j) => TaskModel.fromJson(j)).toList();

      _lastPage = data['last_page'] ?? 1;
      _total    = data['total']     ?? 0;

      if (append) {
        _tasks.addAll(list);
      } else {
        _tasks = list;
      }
      _error = null;
      _updateWidget();
      
      // Update notifications for all loaded tasks
      NotificationService.scheduleTaskNotifications(_tasks);
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _isLoading = false;
      _isSyncing = false;
      notifyListeners();
    }
  }

  // ----------------------------------------------------------------
  // Smart Feature: Auto-guess priority from text
  // ----------------------------------------------------------------
  String suggestPriority(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('urgent') || lower.contains('asap') || lower.contains('important') || lower.contains('emergency') || lower.contains('deadline') || lower.contains('doctor')) {
      return 'High';
    }
    if (lower.contains('meeting') || lower.contains('call') || lower.contains('review') || lower.contains('soon') || lower.contains('tomorrow')) {
      return 'Medium';
    }
    return 'Low';
  }

  // ----------------------------------------------------------------
  // Load next page
  // ----------------------------------------------------------------
  Future<void> loadMore() async {
    if (_isSyncing || !hasMorePages) return;
    _currentPage++;
    await loadTasks(append: true);
  }

  // ----------------------------------------------------------------
  // Refresh (pull-to-refresh)
  // ----------------------------------------------------------------
  Future<void> refresh() async {
    _currentPage = 1;
    await loadTasks();
  }

  // ----------------------------------------------------------------
  // Filter & Search helpers
  // ----------------------------------------------------------------
  void setFilter({String? status, String? priority, int? categoryId, String? search, String? sort}) {
    if (status   != null) _filterStatus   = status;
    if (priority != null) _filterPriority = priority;
    if (categoryId != null) _filterCategory = categoryId == -1 ? null : categoryId;
    if (search   != null) _searchQuery    = search;
    if (sort     != null) _sortBy         = sort;
    loadTasks();
  }

  void clearFilters() {
    _filterStatus   = '';
    _filterPriority = '';
    _filterCategory = null;
    _searchQuery    = '';
    _sortBy         = 'due_date';
    loadTasks();
  }

  // ----------------------------------------------------------------
  // CRUD
  // ----------------------------------------------------------------
  Future<bool> addTask(TaskModel task) async {
    try {
      final res    = await ApiService.post('tasks.php?action=add_task', task.toJson());
      final newTask = TaskModel.fromJson(res['data'] as Map<String, dynamic>);
      _tasks.insert(0, newTask);
      _total++;
      notifyListeners();
      _updateWidget();
      NotificationService.scheduleTaskNotifications(_tasks);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTask(TaskModel task) async {
    try {
      final res     = await ApiService.put('tasks.php?action=update_task', task.toJson());
      final updated = TaskModel.fromJson(res['data'] as Map<String, dynamic>);
      final idx     = _tasks.indexWhere((t) => t.id == task.id);
      if (idx != -1) _tasks[idx] = updated;
      notifyListeners();
      _updateWidget();
      NotificationService.scheduleTaskNotifications(_tasks);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changeTaskStatus(int id, String status) async {
    try {
      await ApiService.patch('tasks.php?action=change_status', {'id': id, 'status': status});
      final idx = _tasks.indexWhere((t) => t.id == id);
      if (idx != -1) {
        _tasks[idx] = _tasks[idx].copyWith(status: status);
        notifyListeners();
        _updateWidget();
      }
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTask(int id) async {
    try {
      await ApiService.delete('tasks.php?action=delete_task', {'id': id});
      _tasks.removeWhere((t) => t.id == id);
      _total--;
      notifyListeners();
      _updateWidget();
      NotificationService.scheduleTaskNotifications(_tasks);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  // ----------------------------------------------------------------
  // Categories
  // ----------------------------------------------------------------
  Future<void> loadCategories() async {
    try {
      final res       = await ApiService.get('categories.php', query: {'action': 'get_categories'});
      final list      = (res['data'] as List).map((j) => CategoryModel.fromJson(j)).toList();
      _categories     = list;
      notifyListeners();
    } on ApiException catch (e) {
      debugPrint('Categories load error: $e');
    }
  }

  Future<bool> addCategory(CategoryModel cat) async {
    try {
      final res  = await ApiService.post('categories.php?action=add_category', cat.toJson());
      final newCat = CategoryModel.fromJson(res['data'] as Map<String, dynamic>);
      _categories.add(newCat);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCategory(CategoryModel cat) async {
    try {
      final res     = await ApiService.put('categories.php?action=update_category', cat.toJson());
      final updated = CategoryModel.fromJson(res['data'] as Map<String, dynamic>);
      final idx     = _categories.indexWhere((c) => c.id == cat.id);
      if (idx != -1) _categories[idx] = updated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCategory(int id) async {
    try {
      await ApiService.delete('categories.php?action=delete_category', {'id': id});
      _categories.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _updateWidget() {
    WidgetService.updateWidgetData(_tasks);
  }
}
