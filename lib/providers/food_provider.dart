import 'package:flutter/foundation.dart';
import '../data/food_data.dart';
import '../models/food_item.dart';

class FoodProvider with ChangeNotifier {
  final List<FoodItem> _items = [];
  final List<String> _categories = List.from(FoodData.categories);

  FoodProvider() {
    _items.addAll(FoodData.initialFoodItems);
  }

  // All items (for admin)
  List<FoodItem> get allItems => List.unmodifiable(_items);

  // Available items (for customer)
  List<FoodItem> get availableItems =>
      _items.where((item) => item.isAvailable).toList();

  // Popular items
  List<FoodItem> get popularItems =>
      _items.where((item) => item.isPopular && item.isAvailable).toList();

  List<String> get categories => List.unmodifiable(_categories);

  int get totalFoodCount => _items.length;
  int get availableFoodCount => _items.where((i) => i.isAvailable).length;

  FoodItem? findById(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  List<FoodItem> getItemsByCategory(String category, {bool customerOnly = true}) {
    final source = customerOnly ? availableItems : _items;
    if (category == 'All') {
      return source;
    }
    return source.where((item) => item.category == category).toList();
  }

  List<FoodItem> searchItems(String query, {bool customerOnly = true}) {
    final source = customerOnly ? availableItems : _items;
    if (query.trim().isEmpty) return source;
    final lower = query.toLowerCase().trim();
    return source.where((item) {
      return item.name.toLowerCase().contains(lower) ||
          item.category.toLowerCase().contains(lower) ||
          item.description.toLowerCase().contains(lower);
    }).toList();
  }

  void addFoodItem(FoodItem item) {
    _items.add(item);
    notifyListeners();
  }

  void updateFoodItem(FoodItem updatedItem) {
    final index = _items.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _items[index] = updatedItem;
      notifyListeners();
    }
  }

  void deleteFoodItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void toggleAvailability(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      final current = _items[index];
      _items[index] = current.copyWith(isAvailable: !current.isAvailable);
      notifyListeners();
    }
  }

  void resetToDefault() {
    _items.clear();
    _items.addAll(FoodData.initialFoodItems);
    notifyListeners();
  }
}
