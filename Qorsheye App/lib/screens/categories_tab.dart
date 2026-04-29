import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/settings_provider.dart';
import '../models/category_model.dart';
import '../utils/constants.dart';
import '../utils/translations.dart';

class CategoriesTab extends StatefulWidget {
  const CategoriesTab({super.key});

  @override
  State<CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends State<CategoriesTab> {
  static const List<String> _predefinedColors = [
    '#3F51B5', '#F44336', '#4CAF50', '#FF9800', 
    '#9C27B0', '#E91E63', '#00BCD4', '#795548',
    '#607D8B', '#FFEB3B'
  ];

  static const List<IconData> _predefinedIcons = [
    Icons.category, Icons.work, Icons.person, Icons.shopping_cart,
    Icons.fitness_center, Icons.book, Icons.home, Icons.favorite,
    Icons.attach_money, Icons.flight, Icons.school, Icons.computer,
    Icons.restaurant, Icons.local_bar, Icons.sports_esports, Icons.music_note,
    Icons.movie, Icons.directions_car, Icons.pets, Icons.local_hospital,
    Icons.camera_alt, Icons.brush, Icons.train, Icons.business,
    Icons.beach_access, Icons.child_care, Icons.medical_services, Icons.code,
    Icons.gamepad, Icons.fastfood, Icons.pedal_bike, Icons.local_cafe,
    Icons.phone, Icons.wb_sunny, Icons.star, Icons.cake,
    Icons.directions_run, Icons.emoji_emotions, Icons.shopping_bag, Icons.spa
  ];

  void _showCategoryDialog(BuildContext context, {CategoryModel? category}) {
    final nameController = TextEditingController(text: category?.name ?? '');
    String selectedHex = category?.color ?? _predefinedColors.first;
    int selectedIconCode = category?.iconCode ?? _predefinedIcons.first.codePoint;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<TaskProvider>(context, listen: false);
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final lang = settings.languageCode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24, right: 24, top: 16
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: Colors.grey.withAlpha(50), borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  category == null 
                    ? (lang == 'so' ? 'Qayb Cusub' : 'Add Category') 
                    : (lang == 'so' ? 'Wax ka beddel' : 'Edit Category'),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: lang == 'so' ? 'Magaca qaybta' : 'Category name',
                    filled: true,
                    fillColor: isDark ? Colors.white.withAlpha(5) : Colors.grey.shade100,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Select Icon', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: GridView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemCount: _predefinedIcons.length,
                    itemBuilder: (context, index) {
                      final icon = _predefinedIcons[index];
                      final isSelected = selectedIconCode == icon.codePoint;
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedIconCode = icon.codePoint),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary.withAlpha(40) : (isDark ? Colors.white.withAlpha(10) : Colors.grey.shade100),
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
                          ),
                          child: Icon(icon, color: isSelected ? AppColors.primary : (isDark ? Colors.white70 : Colors.black54)),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Select Color', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12, runSpacing: 12,
                  children: _predefinedColors.map((hex) {
                    final color = AppConstants.parseColor(hex);
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedHex = hex),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: selectedHex == hex ? Border.all(color: AppColors.primary, width: 3) : null,
                          boxShadow: [
                            if (selectedHex == hex) BoxShadow(color: color.withAlpha(100), blurRadius: 8, spreadRadius: 2)
                          ]
                        ),
                        child: selectedHex == hex ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameController.text.trim().isEmpty) return;
                      
                      final newCat = CategoryModel(
                        id: category?.id ?? DateTime.now().millisecondsSinceEpoch,
                        name: nameController.text.trim(),
                        color: selectedHex,
                        iconCode: selectedIconCode,
                      );
                      
                      if (category == null) {
                        provider.addCategory(newCat);
                      } else {
                        provider.updateCategory(newCat);
                      }
                      
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Text(lang == 'so' ? 'Keydi' : 'Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Tr.get('categories', lang),
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => _showCategoryDialog(context),
                    icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 32),
                  )
                ],
              ),
            ),
            Expanded(
              child: Consumer<TaskProvider>(
                builder: (context, provider, child) {
                  if (provider.categories.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.category_outlined, size: 64, color: Colors.grey.withAlpha(100)),
                          const SizedBox(height: 16),
                          Text(lang == 'so' ? 'Ma jiraan qaybo la helay.' : 'No categories found.'),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: provider.categories.length,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemBuilder: (context, index) {
                      final cat = provider.categories[index];
                      final tasksCount = provider.tasks.where((t) => t.categoryId == cat.id).length;
                      final catColor = AppConstants.parseColor(cat.color);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withAlpha(isDark ? 40 : 5), blurRadius: 10, offset: const Offset(0, 4))
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          leading: Container(
                            width: 50, height: 50,
                            decoration: BoxDecoration(
                              color: catColor.withAlpha(30),
                              borderRadius: BorderRadius.circular(12)
                            ),
                            child: Icon(
                              IconData(cat.iconCode, fontFamily: 'MaterialIcons'),
                              color: catColor,
                            ),
                          ),
                          title: Text(cat.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          subtitle: Text('$tasksCount ${lang == 'so' ? 'Hawlo' : 'Tasks'}'),
                          trailing: PopupMenuButton<String>(
                            onSelected: (val) {
                              if (val == 'edit') _showCategoryDialog(context, category: cat);
                              if (val == 'delete') {
                                // Confirm before delete
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text(lang == 'so' ? 'Xaqiiji' : 'Confirm'),
                                    content: Text(lang == 'so' ? 'Ma hubtaa inaad tirtirto qaybtan?' : 'Delete this category?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx), child: Text(Tr.get('cancel', lang))),
                                      TextButton(
                                        onPressed: () {
                                          provider.deleteCategory(cat.id);
                                          Navigator.pop(ctx);
                                        },
                                        child: Text(Tr.get('delete', lang), style: const TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text(Tr.get('edit', lang))])),
                              PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text(Tr.get('delete', lang), style: const TextStyle(color: Colors.red))])),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


