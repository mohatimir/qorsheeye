import 'package:flutter/material.dart';

class IconHelper {
  // Dhammaan icons-ka la isticmaali karo (waxay la mid yihiin kuwa categories_tab.dart ku jira)
  static const List<IconData> _allIcons = [
    Icons.category,
    Icons.work,
    Icons.person,
    Icons.shopping_cart,
    Icons.fitness_center,
    Icons.book,
    Icons.home,
    Icons.favorite,
    Icons.attach_money,
    Icons.flight,
    Icons.school,
    Icons.computer,
    Icons.restaurant,
    Icons.local_bar,
    Icons.sports_esports,
    Icons.music_note,
    Icons.movie,
    Icons.directions_car,
    Icons.pets,
    Icons.local_hospital,
    Icons.camera_alt,
    Icons.brush,
    Icons.train,
    Icons.business,
    Icons.beach_access,
    Icons.child_care,
    Icons.medical_services,
    Icons.code,
    Icons.gamepad,
    Icons.fastfood,
    Icons.pedal_bike,
    Icons.local_cafe,
    Icons.phone,
    Icons.wb_sunny,
    Icons.star,
    Icons.cake,
    Icons.directions_run,
    Icons.emoji_emotions,
    Icons.shopping_bag,
    Icons.spa,
  ];

  // Map codePoint-ga -> const IconData
  static final Map<int, IconData> _iconMap = {
    for (var icon in _allIcons) icon.codePoint: icon,
  };

  static IconData getIcon(int codePoint) {
    return _iconMap[codePoint] ?? Icons.category;
  }
}
