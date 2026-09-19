class OrderItemModel {
  final String foodItemId;
  final String name;
  final double price;
  final int quantity;

  OrderItemModel({
    required this.foodItemId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      foodItemId: json['foodItemId'] is Map ? json['foodItemId']['_id'] : (json['foodItemId'] ?? ''),
      name: json['name'] ?? '',
      price: (json['price'] != null) ? (json['price'] as num).toDouble() : 0.0,
      quantity: json['quantity'] ?? 1,
    );
  }
}

class OrderModel {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String restaurantId;
  final String restaurantName;
  final List<OrderItemModel> items;
  final double totalAmount;
  final String deliveryAddress;
  final String paymentType;
  final String paymentStatus;
  final String orderStatus; // Placed, Accepted, Preparing, Ready, Delivered, Cancelled
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.restaurantId,
    required this.restaurantName,
    required this.items,
    required this.totalAmount,
    required this.deliveryAddress,
    required this.paymentType,
    required this.paymentStatus,
    required this.orderStatus,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Parse customer name/phone if populated
    String cId = '';
    String cName = 'Customer';
    String cPhone = '';
    if (json['customerId'] is Map) {
      cId = json['customerId']['_id'] ?? '';
      cName = json['customerId']['name'] ?? 'Customer';
      cPhone = json['customerId']['phone'] ?? '';
    } else {
      cId = json['customerId'] ?? '';
    }

    // Parse restaurant name if populated
    String rId = '';
    String rName = 'Restaurant';
    if (json['restaurantId'] is Map) {
      rId = json['restaurantId']['_id'] ?? '';
      rName = json['restaurantId']['name'] ?? 'Restaurant';
    } else {
      rId = json['restaurantId'] ?? '';
    }

    // Parse items list
    List<OrderItemModel> parsedItems = [];
    if (json['items'] != null) {
      parsedItems = (json['items'] as List)
          .map((item) => OrderItemModel.fromJson(item))
          .toList();
    }

    return OrderModel(
      id: json['_id'] ?? json['id'] ?? '',
      customerId: cId,
      customerName: cName,
      customerPhone: cPhone,
      restaurantId: rId,
      restaurantName: rName,
      items: parsedItems,
      totalAmount: (json['totalAmount'] != null) ? (json['totalAmount'] as num).toDouble() : 0.0,
      deliveryAddress: json['deliveryAddress'] ?? '',
      paymentType: json['paymentType'] ?? 'Cash On Delivery',
      paymentStatus: json['paymentStatus'] ?? 'Pending',
      orderStatus: json['orderStatus'] ?? 'Placed',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
