class RestaurantModel {
  final int id;
  final String name;
  final String location;

  const RestaurantModel({required this.id, required this.name, required this.location});

  factory RestaurantModel.fromJson(Map<String, dynamic> json) => RestaurantModel(
        id: json['id'] as int,
        name: json['name'] as String,
        location: json['location'] as String,
      );
}
