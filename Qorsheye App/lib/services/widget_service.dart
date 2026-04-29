import 'package:home_widget/home_widget.dart';
import '../models/task_model.dart';
import 'dart:convert';

class WidgetService {
  static const String _androidWidgetName = 'QorsheyeWidgetReceiver';

  static Future<void> updateWidgetData(List<TaskModel> tasks) async {
    // Collect pending tasks for the widget
    final pendingTasks = tasks.where((t) => t.status == 'Pending').take(5).toList();
    
    // Prepare data string
    final taskData = pendingTasks.map((t) => {
      'title': t.title,
      'isOverdue': t.dueDate != null && t.dueDate!.isBefore(DateTime.now()),
    }).toList();

    // Save data for the widget to read
    await HomeWidget.saveWidgetData<String>('pending_tasks', jsonEncode(taskData));
    
    // Update the widget UI
    await HomeWidget.updateWidget(
      androidName: _androidWidgetName,
      iOSName: 'QorsheyeWidget',
    );
  }
}
