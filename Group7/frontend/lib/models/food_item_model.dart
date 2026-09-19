class FoodItemModel {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final double price;
  final String category;
  final bool isVeg;
  final bool isAvailable;
  final String imageUrl;

  FoodItemModel({
    required this.id,
    required this.restaurantId,
    required this.name,
    this.description = '',
    required this.price,
    this.category = 'Main Course',
    this.isVeg = true,
    this.isAvailable = true,
    this.imageUrl = '',
  });

  factory FoodItemModel.fromJson(Map<String, dynamic> json) {
    return FoodItemModel(
      id: json['_id'] ?? json['id'] ?? '',
      restaurantId: json['restaurantId'] is Map ? json['restaurantId']['_id'] : (json['restaurantId'] ?? ''),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] != null) ? (json['price'] as num).toDouble() : 0.0,
      category: json['category'] ?? 'Main Course',
      isVeg: json['isVeg'] ?? true,
      isAvailable: json['isAvailable'] ?? true,
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'restaurantId': restaurantId,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'isVeg': isVeg,
      'isAvailable': isAvailable,
      'imageUrl': imageUrl,
    };
  }
}
