import 'package:flutter/foundation.dart';
import '../models/food_item.dart';
import '../models/order.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  List<CartItem> get cartList => _items.values.toList();

  int get itemCount {
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  int get uniqueItemCount => _items.length;

  bool get isEmpty => _items.isEmpty;

  double get subtotalAmount {
    return _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  // Mini project packing & service fee (₹10 if cart has items)
  double get packingFee => _items.isEmpty ? 0.0 : 10.0;

  double get totalAmount => subtotalAmount + packingFee;

  bool isInCart(String foodId) => _items.containsKey(foodId);

  int getQuantity(String foodId) => _items[foodId]?.quantity ?? 0;

  void addItem(FoodItem foodItem, [int quantity = 1]) {
    if (quantity <= 0 || !foodItem.isAvailable) return;

    if (_items.containsKey(foodItem.id)) {
      _items.update(
        foodItem.id,
        (existingItem) => CartItem(
          foodItem: existingItem.foodItem,
          quantity: existingItem.quantity + quantity,
        ),
      );
    } else {
      _items.putIfAbsent(
        foodItem.id,
        () => CartItem(foodItem: foodItem, quantity: quantity),
      );
    }
    notifyListeners();
  }

  void incrementQuantity(String foodId) {
    if (_items.containsKey(foodId)) {
      _items.update(
        foodId,
        (item) => CartItem(foodItem: item.foodItem, quantity: item.quantity + 1),
      );
      notifyListeners();
    }
  }

  void decrementQuantity(String foodId) {
    if (!_items.containsKey(foodId)) return;

    if (_items[foodId]!.quantity > 1) {
      _items.update(
        foodId,
        (item) => CartItem(foodItem: item.foodItem, quantity: item.quantity - 1),
      );
    } else {
      _items.remove(foodId);
    }
    notifyListeners();
  }

  void removeItem(String foodId) {
    if (_items.containsKey(foodId)) {
      _items.remove(foodId);
      notifyListeners();
    }
  }

  void updateQuantity(String foodId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(foodId);
    } else if (_items.containsKey(foodId)) {
      _items[foodId]!.quantity = newQuantity;
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
