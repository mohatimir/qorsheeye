class TaskModel {
  final int id;
  final String title;
  final String description;
  final String priority;
  final String status;
  final DateTime? dueDate;
  final int? categoryId;
  final String? categoryName;
  final String? categoryColor;
  final String repeat; // 'None', 'Daily', 'Weekly', 'Monthly'

  TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    this.priority = 'Medium',
    this.status = 'Pending',
    this.dueDate,
    this.categoryId,
    this.categoryName,
    this.categoryColor,
    this.repeat = 'None',
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      priority: json['priority'] ?? 'Medium',
      status: json['status'] ?? 'Pending',
      dueDate: json['due_date'] != null ? DateTime.tryParse(json['due_date']) : null,
      categoryId: json['category_id'] != null ? int.tryParse(json['category_id'].toString()) : null,
      categoryName: json['category_name'],
      categoryColor: json['category_color'],
      repeat: json['repeat'] ?? 'None',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority,
      'status': status,
      'due_date': dueDate?.toIso8601String(),
      'category_id': categoryId,
      'category_name': categoryName,
      'category_color': categoryColor,
      'repeat': repeat,
    };
  }

  TaskModel copyWith({
    int? id,
    String? title,
    String? description,
    String? priority,
    String? status,
    DateTime? dueDate,
    int? categoryId,
    String? categoryName,
    String? categoryColor,
    String? repeat,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryColor: categoryColor ?? this.categoryColor,
      repeat: repeat ?? this.repeat,
    );
  }
}
