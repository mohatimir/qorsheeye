// ============================================================
// lib/services/local_db.dart
// Stub — app now uses remote MySQL API via ApiService.
// Kept for compile compatibility with any remaining imports.
// ============================================================

import '../models/task_model.dart';
import '../models/category_model.dart';

/// No-op local DB stub.
/// All data is now stored in the remote MySQL database.
/// This file exists only to prevent compile errors from any
/// legacy references that have not yet been migrated.
class LocalDB {
  static Future<void> init() async {}

  // --- Tasks (no-op stubs) ---
  static List<TaskModel> getTasks() => [];
  static Future<void> saveTasks(List<TaskModel> tasks) async {}
  static Future<void> addTask(TaskModel task) async {}
  static Future<void> updateTask(TaskModel task) async {}
  static Future<void> deleteTask(int id) async {}

  // --- Categories (no-op stubs) ---
  static List<CategoryModel> getCategories() => [];
  static Future<void> saveCategories(List<CategoryModel> categories) async {}
  static Future<void> addCategory(CategoryModel category) async {}
  static Future<void> updateCategory(CategoryModel category) async {}
  static Future<void> deleteCategory(int id) async {}
}
