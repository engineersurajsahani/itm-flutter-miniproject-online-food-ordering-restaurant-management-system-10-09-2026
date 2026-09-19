class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // 'customer', 'restaurant', 'admin'
  final String phone;
  final String address;
  final String? restaurantId;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone = '',
    this.address = '',
    this.restaurantId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Check if restaurantId is a populated object or string ID
    String? restId;
    if (json['restaurantId'] is Map) {
      restId = json['restaurantId']['_id'];
    } else if (json['restaurantId'] is String) {
      restId = json['restaurantId'];
    }

    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'customer',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      restaurantId: restId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'address': address,
      'restaurantId': restaurantId,
    };
  }
}
