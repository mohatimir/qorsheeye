class CategoryModel {
  final int id;
  final String name;
  final String color;
  final int iconCode;

  CategoryModel({
    required this.id,
    required this.name,
    required this.color,
    this.iconCode = 0xe148, // Default to folder/category icon code
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      color: json['color'] ?? '#3F51B5',
      iconCode: int.tryParse(json['icon_code'].toString()) ?? 0xe148,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'icon_code': iconCode,
    };
  }
}
