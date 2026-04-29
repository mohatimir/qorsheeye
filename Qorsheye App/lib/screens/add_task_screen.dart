import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/settings_provider.dart';
import '../models/task_model.dart';
import '../models/category_model.dart';
import '../utils/constants.dart';
import '../utils/translations.dart';
import 'package:intl/intl.dart';

class AddTaskScreen extends StatefulWidget {
  final TaskModel? task;
  const AddTaskScreen({super.key, this.task});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;

  late String _priority;
  DateTime? _dueDate;
  int? _categoryId;
  late String _repeat;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descController = TextEditingController(
      text: widget.task?.description ?? '',
    );
    _priority = widget.task?.priority ?? 'Medium';
    _dueDate = widget.task?.dueDate;
    _categoryId = widget.task?.categoryId;
    _repeat = widget.task?.repeat ?? 'None';

    // Smart priority suggestion when adding new task
    if (widget.task == null) {
      _titleController.addListener(() {
        final provider = context.read<TaskProvider>();
        final suggested = provider.suggestPriority(_titleController.text);
        if (_priority != suggested) {
          setState(() {
            _priority = suggested;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final lang = settings.languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isEdit = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit
              ? (lang == 'so' ? 'Wax ka beddel' : 'Edit Task')
              : (lang == 'so' ? 'Hawl Cusub' : 'Add New Task'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.backgroundDark, AppColors.cardDark]
                : [AppColors.backgroundLight, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Consumer<TaskProvider>(
            builder: (context, provider, child) {
              return Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16,
                  ),
                  children: [
                    _buildSectionTitle(
                      lang == 'so' ? 'Magaca Hawsha' : 'Task Name',
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _titleController,
                      hint: lang == 'so'
                          ? 'Maxaad qabanaysaa?'
                          : 'What needs to be done?',
                      isDark: isDark,
                    ),

                    const SizedBox(height: 24),
                    _buildSectionTitle(
                      lang == 'so' ? 'Faahfaahin' : 'Description',
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _descController,
                      hint: lang == 'so'
                          ? 'Sharaxaad dheeraad ah...'
                          : 'Add more details...',
                      maxLines: 4,
                      isDark: isDark,
                    ),

                    const SizedBox(height: 24),
                    Row(
                      children: [
                        // Date Picker Column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle(Tr.get('date', lang)),
                              const SizedBox(height: 12),
                              _buildActionCard(
                                icon: Icons.calendar_month,
                                label: _dueDate == null
                                    ? (lang == 'so' ? 'Maalinta' : 'Date')
                                    : DateFormat('MMM dd').format(_dueDate!),
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: _dueDate ?? DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2100),
                                  );
                                  if (date != null) {
                                    setState(() {
                                      _dueDate = DateTime(
                                        date.year,
                                        date.month,
                                        date.day,
                                        _dueDate?.hour ?? 12,
                                        _dueDate?.minute ?? 0,
                                      );
                                    });
                                  }
                                },
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Time Picker Column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle(
                                lang == 'so' ? 'Saacadda' : 'Time',
                              ),
                              const SizedBox(height: 12),
                              _buildActionCard(
                                icon: Icons.access_time_rounded,
                                label: _dueDate == null
                                    ? (lang == 'so' ? 'Saacadda' : 'Time')
                                    : DateFormat('HH:mm').format(_dueDate!),
                                onTap: () async {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: _dueDate != null
                                        ? TimeOfDay.fromDateTime(_dueDate!)
                                        : TimeOfDay.now(),
                                  );
                                  if (time != null) {
                                    setState(() {
                                      final now = _dueDate ?? DateTime.now();
                                      _dueDate = DateTime(
                                        now.year,
                                        now.month,
                                        now.day,
                                        time.hour,
                                        time.minute,
                                      );
                                    });
                                  }
                                },
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle(Tr.get('priority', lang)),
                              const SizedBox(height: 12),
                              _buildPrioritySelector(isDark, lang),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle(Tr.get('category', lang)),
                              const SizedBox(height: 12),
                              _buildCategorySelector(provider, isDark, lang),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle(
                      lang == 'so' ? 'Soo noqoshada' : 'Repeat',
                    ),
                    const SizedBox(height: 12),
                    _buildRepeatSelector(isDark, lang),

                    const SizedBox(height: 48),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final newTask = TaskModel(
                            id:
                                widget.task?.id ??
                                DateTime.now().millisecondsSinceEpoch,
                            title: _titleController.text,
                            description: _descController.text,
                            priority: _priority,
                            dueDate: _dueDate,
                            categoryId: _categoryId,
                            status: widget.task?.status ?? 'Pending',
                            repeat: _repeat,
                          );

                          if (isEdit) {
                            await provider.updateTask(newTask);
                          } else {
                            await provider.addTask(newTask);
                          }

                          if (!context.mounted) return;
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isEdit
                                    ? (lang == 'so'
                                          ? 'Waa la beddelay'
                                          : 'Updated successfully')
                                    : Tr.get('task_added', lang),
                              ),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 8,
                        shadowColor: AppColors.primary.withAlpha(100),
                      ),
                      child: Text(
                        isEdit
                            ? (lang == 'so' ? 'Cusboonaysii' : 'Update Task')
                            : (lang == 'so' ? 'Keydi Hawsha' : 'Save Task'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        color: Colors.grey,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 30 : 5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.withAlpha(150), fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
        validator: (val) =>
            val == null || val.isEmpty ? 'Field is required' : null,
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 30 : 5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrioritySelector(bool isDark, String lang) {
    final priorities = [
      {
        'label': lang == 'so' ? 'Hoose' : 'Low',
        'value': 'Low',
        'color': Colors.green,
      },
      {
        'label': lang == 'so' ? 'Dhexe' : 'Medium',
        'value': 'Medium',
        'color': Colors.orange,
      },
      {
        'label': lang == 'so' ? 'Sare' : 'High',
        'value': 'High',
        'color': Colors.red,
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: priorities.map((p) {
        final isSelected = _priority == p['value'];
        final color = p['color'] as Color;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _priority = p['value'] as String),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: p['value'] == 'High' ? 0 : 8),
              height: 56,
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withAlpha(isDark ? 50 : 30)
                    : (isDark ? AppColors.cardDark : Colors.white),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? color : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 30 : 5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                p['label'] as String,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? color
                      : (isDark ? Colors.white70 : Colors.black54),
                  fontSize: 13,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategorySelector(
    TaskProvider provider,
    bool isDark,
    String lang,
  ) {
    CategoryModel? selectedCategory;
    try {
      if (_categoryId != null) {
        selectedCategory = provider.categories.firstWhere(
          (c) => c.id == _categoryId,
        );
      }
    } catch (_) {}

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 30 : 5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: selectedCategory != null
            ? Border.all(
                color: AppConstants.parseColor(
                  selectedCategory.color,
                ).withAlpha(100),
                width: 1.5,
              )
            : null,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _categoryId,
          hint: Text(
            lang == 'so' ? 'Dooro qayb' : 'Select category',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          isExpanded: true,
          dropdownColor: isDark ? AppColors.cardDark : Colors.white,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          items: provider.categories.map((c) {
            final catColor = AppConstants.parseColor(c.color);
            return DropdownMenuItem(
              value: c.id,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: catColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      IconData(c.iconCode, fontFamily: 'MaterialIcons'),
                      color: catColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    c.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) => setState(() => _categoryId = val),
        ),
      ),
    );
  }

  Widget _buildRepeatSelector(bool isDark, String lang) {
    final options = [
      {'label': lang == 'so' ? 'Marna' : 'None', 'value': 'None'},
      {'label': lang == 'so' ? 'Maalinle' : 'Daily', 'value': 'Daily'},
      {'label': lang == 'so' ? 'Isbuuclle' : 'Weekly', 'value': 'Weekly'},
      {'label': lang == 'so' ? 'Bille' : 'Monthly', 'value': 'Monthly'},
      {'label': lang == 'so' ? 'Sanadle' : 'Yearly', 'value': 'Yearly'},
    ];

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 30 : 5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _repeat,
          isExpanded: true,
          dropdownColor: isDark ? AppColors.cardDark : Colors.white,
          icon: Icon(
            Icons.repeat_rounded,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          items: options.map((o) {
            return DropdownMenuItem(
              value: o['value'],
              child: Text(
                o['label']!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
          onChanged: (val) => setState(() => _repeat = val!),
        ),
      ),
    );
  }
}
