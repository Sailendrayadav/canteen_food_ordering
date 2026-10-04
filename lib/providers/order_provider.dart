import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/food_item.dart';
import '../models/order.dart';

class OrderProvider with ChangeNotifier {
  final List<CanteenOrder> _orders = [];

  OrderProvider() {
    _seedInitialOrders();
  }

  List<CanteenOrder> get orders => List.unmodifiable(_orders);

  int get totalOrdersCount => _orders.length;

  CanteenOrder? get latestOrder => _orders.isNotEmpty ? _orders.first : null;

  CanteenOrder? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((o) => o.id == orderId);
    } catch (_) {
      return null;
    }
  }

  // --- Sales & Analytics Getters ---

  double get totalSales {
    return _orders
        .where((o) => o.status != OrderStatus.cancelled)
        .fold(0.0, (sum, o) => sum + o.totalAmount);
  }

  double get todaySales {
    final now = DateTime.now();
    return _orders
        .where((o) =>
            o.status != OrderStatus.cancelled &&
            o.dateTime.year == now.year &&
            o.dateTime.month == now.month &&
            o.dateTime.day == now.day)
        .fold(0.0, (sum, o) => sum + o.totalAmount);
  }

  int get pendingCount => _orders.where((o) => o.status == OrderStatus.pending).length;
  int get confirmedCount => _orders.where((o) => o.status == OrderStatus.confirmed).length;
  int get preparingCount => _orders.where((o) => o.status == OrderStatus.preparing).length;
  int get readyCount => _orders.where((o) => o.status == OrderStatus.ready).length;
  int get completedCount => _orders.where((o) => o.status == OrderStatus.completed).length;

  int get pendingOrdersCount {
    return _orders
        .where((o) =>
            o.status == OrderStatus.pending ||
            o.status == OrderStatus.confirmed ||
            o.status == OrderStatus.preparing)
        .length;
  }

  int get completedOrdersCount {
    return _orders.where((o) => o.status == OrderStatus.completed).length;
  }

  int get readyOrdersCount {
    return _orders.where((o) => o.status == OrderStatus.ready).length;
  }

  int get cancelledOrdersCount {
    return _orders.where((o) => o.status == OrderStatus.cancelled).length;
  }

  List<CanteenOrder> filterByStatus(OrderStatus? status) {
    if (status == null) return orders;
    return _orders.where((o) => o.status == status).toList();
  }

  /// Places a new order and inserts it at the beginning of the list
  CanteenOrder placeOrder({
    required List<CartItem> items,
    required double totalAmount,
    required String customerName,
    required String phoneNumber,
    String pickupOption = 'Counter Pickup',
    String paymentMethod = 'Cash at Canteen',
  }) {
    final randomNum = 1000 + Random().nextInt(9000);
    final orderId = '#ORD-$randomNum';

    final newOrder = CanteenOrder(
      id: orderId,
      items: items.map((e) => CartItem(foodItem: e.foodItem, quantity: e.quantity)).toList(),
      totalAmount: totalAmount,
      dateTime: DateTime.now(),
      status: OrderStatus.pending,
      customerName: customerName,
      phoneNumber: phoneNumber,
      pickupOption: pickupOption,
      paymentMethod: paymentMethod,
      estimatedMinutes: 15,
    );

    _orders.insert(0, newOrder);
    notifyListeners();
    return newOrder;
  }

  /// Explicit status update by Admin
  void updateOrderStatus(String orderId, OrderStatus newStatus) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index].status = newStatus;
      notifyListeners();
    }
  }

  /// Admin Order Control: Confirm Order (Pending -> Confirmed)
  void confirmOrder(String orderId) {
    updateOrderStatus(orderId, OrderStatus.confirmed);
  }

  /// Admin Order Control: Start Preparing (Confirmed -> Preparing)
  void startPreparing(String orderId) {
    updateOrderStatus(orderId, OrderStatus.preparing);
  }

  /// Admin Order Control: Mark Ready (Preparing -> Ready)
  void markReady(String orderId) {
    updateOrderStatus(orderId, OrderStatus.ready);
  }

  /// Admin Order Control: Complete Order (Ready -> Completed)
  void completeOrder(String orderId) {
    updateOrderStatus(orderId, OrderStatus.completed);
  }

  /// Admin Order Control: Cancel Order
  void cancelOrder(String orderId) {
    updateOrderStatus(orderId, OrderStatus.cancelled);
  }

  /// Cycles to the next order status (internal/demo helper)
  void advanceOrderStatus(String orderId) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return;

    final currentOrder = _orders[index];
    OrderStatus nextStatus = currentOrder.status;

    switch (currentOrder.status) {
      case OrderStatus.pending:
        nextStatus = OrderStatus.confirmed;
        break;
      case OrderStatus.confirmed:
        nextStatus = OrderStatus.preparing;
        break;
      case OrderStatus.preparing:
        nextStatus = OrderStatus.ready;
        break;
      case OrderStatus.ready:
        nextStatus = OrderStatus.completed;
        break;
      case OrderStatus.completed:
      case OrderStatus.cancelled:
        return; // Terminal state
    }

    currentOrder.status = nextStatus;
    notifyListeners();
  }

  /// Reset demo orders
  void resetToDemo() {
    _orders.clear();
    _seedInitialOrders();
    notifyListeners();
  }

  void _seedInitialOrders() {
    // Demo order 1 - Pending
    _orders.add(
      CanteenOrder(
        id: '#ORD-5120',
        dateTime: DateTime.now().subtract(const Duration(minutes: 5)),
        status: OrderStatus.pending,
        totalAmount: 90.0,
        customerName: 'Ananya Verma',
        phoneNumber: '+91 98111 22334',
        pickupOption: 'Counter Pickup',
        paymentMethod: 'UPI',
        estimatedMinutes: 15,
        items: [
          CartItem(
            foodItem: const FoodItem(
              id: 'f2',
              name: 'Masala Dosa',
              price: 50.0,
              rating: 4.8,
              category: 'Breakfast',
              imageUrl: 'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?w=400&auto=format&fit=crop&q=75',
              description: 'Crispy fermented rice and lentil crepe stuffed with spiced potato mash.',
            ),
            quantity: 1,
          ),
          CartItem(
            foodItem: const FoodItem(
              id: 'f3',
              name: 'Samosa',
              price: 20.0,
              rating: 4.8,
              category: 'Snacks',
              imageUrl: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=400&auto=format&fit=crop&q=75',
              description: 'Golden crispy crust filled with spiced potatoes.',
            ),
            quantity: 2,
          ),
        ],
      ),
    );

    // Demo order 2 - Preparing
    _orders.add(
      CanteenOrder(
        id: '#ORD-4821',
        dateTime: DateTime.now().subtract(const Duration(minutes: 18)),
        status: OrderStatus.preparing,
        totalAmount: 95.0,
        customerName: 'Bvc Students Group',
        phoneNumber: '+91 8090451729',
        pickupOption: 'Counter Pickup',
        paymentMethod: 'UPI',
        estimatedMinutes: 8,
        items: [
          CartItem(
            foodItem: const FoodItem(
              id: 'f5',
              name: 'Burger',
              price: 70.0,
              rating: 4.7,
              category: 'Fast Food',
              imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&auto=format&fit=crop&q=75',
              description: 'Crispy veggie patty with fresh lettuce and cheese.',
            ),
            quantity: 1,
          ),
          CartItem(
            foodItem: const FoodItem(
              id: 'f19',
              name: 'Coffee',
              price: 25.0,
              rating: 4.8,
              category: 'Beverages',
              imageUrl: 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=400&auto=format&fit=crop&q=75',
              description: 'Hot aromatic South Indian filter coffee.',
            ),
            quantity: 1,
          ),
        ],
      ),
    );

    // Demo order 3 - Ready
    _orders.add(
      CanteenOrder(
        id: '#ORD-3940',
        dateTime: DateTime.now().subtract(const Duration(minutes: 30)),
        status: OrderStatus.ready,
        totalAmount: 110.0,
        customerName: 'Priya Patel',
        phoneNumber: '+91 97234 56789',
        pickupOption: 'Counter Pickup',
        paymentMethod: 'Cash at Canteen',
        estimatedMinutes: 2,
        items: [
          CartItem(
            foodItem: const FoodItem(
              id: 'f8',
              name: 'Veg Biryani',
              price: 100.0,
              rating: 4.9,
              category: 'Main Course',
              imageUrl: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=400&auto=format&fit=crop&q=75',
              description: 'Fragrant basmati rice slow-cooked with garden vegetables.',
            ),
            quantity: 1,
          ),
        ],
      ),
    );

    // Demo order 4 - Completed
    _orders.add(
      CanteenOrder(
        id: '#ORD-3190',
        dateTime: DateTime.now().subtract(const Duration(hours: 3)),
        status: OrderStatus.completed,
        totalAmount: 130.0,
        customerName: 'Bvc Students Group',
        phoneNumber: '+91 8090451729',
        pickupOption: 'Seat Delivery (Table 4)',
        paymentMethod: 'Cash at Canteen',
        estimatedMinutes: 0,
        items: [
          CartItem(
            foodItem: const FoodItem(
              id: 'f6',
              name: 'Pizza',
              price: 120.0,
              rating: 4.8,
              category: 'Fast Food',
              imageUrl: 'https://images.unsplash.com/photo-1604382355076-af4b0eb60143?w=400&auto=format&fit=crop&q=75',
              description: 'Fresh mozzarella cheese pizza.',
            ),
            quantity: 1,
          ),
        ],
      ),
    );
  }
}
