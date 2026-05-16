class MenuOptionModel {
  final int id;
  final String name;
  final double price;

  const MenuOptionModel({required this.id, required this.name, required this.price});

  factory MenuOptionModel.fromJson(Map<String, dynamic> json) => MenuOptionModel(
        id: json['id'] as int,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
      );
}

class MenuItemModel {
  final int id;
  final String name;
  final double price;
  final List<MenuOptionModel> options;

  const MenuItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.options,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) => MenuItemModel(
        id: json['id'] as int,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        options: (json['options'] as List<dynamic>? ?? [])
            .map((o) => MenuOptionModel.fromJson(o as Map<String, dynamic>))
            .toList(),
      );
}
