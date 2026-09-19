import 'food_item_model.dart';

class CartItemModel {
  final FoodItemModel foodItem;
  int quantity;

  CartItemModel({
    required this.foodItem,
    this.quantity = 1,
  });

  double get totalPrice => foodItem.price * quantity;

  Map<String, dynamic> toOrderPayload() {
    return {
      'foodItemId': foodItem.id,
      'quantity': quantity,
    };
  }
}
