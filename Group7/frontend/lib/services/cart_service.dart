import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';
import '../models/food_item_model.dart';

class CartService extends ChangeNotifier {
  // Singleton pattern for simple global access across screens
  static final CartService instance = CartService._internal();
  CartService._internal();

  String? _restaurantId;
  String? _restaurantName;
  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => _items;
  String? get restaurantId => _restaurantId;
  String? get restaurantName => _restaurantName;

  int get totalItemCount {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  double get subtotal {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  // Add item to cart
  void addItem(FoodItemModel foodItem, String restId, String restName) {
    // If cart has items from another restaurant, reset cart first
    if (_restaurantId != null && _restaurantId != restId) {
      _items.clear();
    }
    _restaurantId = restId;
    _restaurantName = restName;

    // Check if food already exists in cart
    final index = _items.indexWhere((i) => i.foodItem.id == foodItem.id);
    if (index >= 0) {
      _items[index].quantity += 1;
    } else {
      _items.add(CartItemModel(foodItem: foodItem, quantity: 1));
    }
    notifyListeners();
  }

  // Increase item quantity
  void increaseQuantity(String foodItemId) {
    final index = _items.indexWhere((i) => i.foodItem.id == foodItemId);
    if (index >= 0) {
      _items[index].quantity += 1;
      notifyListeners();
    }
  }

  // Decrease item quantity (removes if reaches 0)
  void decreaseQuantity(String foodItemId) {
    final index = _items.indexWhere((i) => i.foodItem.id == foodItemId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity -= 1;
      } else {
        _items.removeAt(index);
        if (_items.isEmpty) {
          _restaurantId = null;
          _restaurantName = null;
        }
      }
      notifyListeners();
    }
  }

  // Remove specific item completely
  void removeItem(String foodItemId) {
    _items.removeWhere((i) => i.foodItem.id == foodItemId);
    if (_items.isEmpty) {
      _restaurantId = null;
      _restaurantName = null;
    }
    notifyListeners();
  }

  // Clear cart after successful checkout
  void clearCart() {
    _items.clear();
    _restaurantId = null;
    _restaurantName = null;
    notifyListeners();
  }
}
