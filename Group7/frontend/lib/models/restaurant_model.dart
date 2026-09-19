class RestaurantModel {
  final String id;
  final String name;
  final String description;
  final String cuisineType;
  final String address;
  final String phone;
  final String imageUrl;
  final bool isOpen;
  final String? ownerId;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.description,
    required this.cuisineType,
    required this.address,
    required this.phone,
    required this.imageUrl,
    this.isOpen = true,
    this.ownerId,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      cuisineType: json['cuisineType'] ?? 'Multi-Cuisine',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      imageUrl: json['imageUrl'] ?? 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=600',
      isOpen: json['isOpen'] ?? true,
      ownerId: json['ownerId'] is Map ? json['ownerId']['_id'] : json['ownerId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'cuisineType': cuisineType,
      'address': address,
      'phone': phone,
      'imageUrl': imageUrl,
      'isOpen': isOpen,
      'ownerId': ownerId,
    };
  }
}
