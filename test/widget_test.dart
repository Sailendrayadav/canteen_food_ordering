import 'package:flutter_test/flutter_test.dart';
import 'package:canteen_food_ordering/models/food_item.dart';
import 'package:canteen_food_ordering/models/order.dart';
import 'package:canteen_food_ordering/providers/admin_provider.dart';
import 'package:canteen_food_ordering/providers/cart_provider.dart';
import 'package:canteen_food_ordering/providers/food_provider.dart';
import 'package:canteen_food_ordering/providers/order_provider.dart';

void main() {
  group('Canteen Food Ordering & Admin Portal Unit Tests', () {
    test('CartProvider calculates subtotal and total correctly', () {
      final cart = CartProvider();

      expect(cart.isEmpty, isTrue);
      expect(cart.totalAmount, 0.0);

      const food1 = FoodItem(
        id: 'f1',
        name: 'Masala Dosa',
        price: 50.0,
        rating: 4.8,
        category: 'Breakfast',
        imageUrl: '',
        description: 'Test Dosa',
      );

      const food2 = FoodItem(
        id: 'f20',
        name: 'Tea',
        price: 15.0,
        rating: 4.9,
        category: 'Beverages',
        imageUrl: '',
        description: 'Test Tea',
      );

      // Add items
      cart.addItem(food1, 2); // 2 x 50 = 100
      cart.addItem(food2, 1); // 1 x 15 = 15

      expect(cart.itemCount, 3);
      expect(cart.subtotalAmount, 115.0);
      expect(cart.packingFee, 10.0);
      expect(cart.totalAmount, 125.0);

      // Increment Tea
      cart.incrementQuantity('f20'); // 2 x 15 = 30
      expect(cart.subtotalAmount, 130.0);

      // Decrement Dosa
      cart.decrementQuantity('f1'); // 1 x 50 = 50
      expect(cart.subtotalAmount, 80.0);

      // Clear cart
      cart.clearCart();
      expect(cart.isEmpty, isTrue);
      expect(cart.totalAmount, 0.0);
    });

    test('OrderProvider places and advances order statuses in pipeline', () {
      final orderProvider = OrderProvider();
      final initialCount = orderProvider.totalOrdersCount;

      final placedOrder = orderProvider.placeOrder(
        items: [],
        totalAmount: 120.0,
        customerName: 'Rahul',
        phoneNumber: '9876543210',
        pickupOption: 'Counter Pickup',
        paymentMethod: 'Cash at Canteen',
      );

      expect(orderProvider.totalOrdersCount, initialCount + 1);
      expect(placedOrder.id, startsWith('#ORD-'));
      expect(placedOrder.status, OrderStatus.pending);

      // Admin Confirms Order
      orderProvider.confirmOrder(placedOrder.id);
      expect(orderProvider.getOrderById(placedOrder.id)?.status, OrderStatus.confirmed);

      // Admin Starts Preparing
      orderProvider.startPreparing(placedOrder.id);
      expect(orderProvider.getOrderById(placedOrder.id)?.status, OrderStatus.preparing);

      // Admin Marks Ready
      orderProvider.markReady(placedOrder.id);
      expect(orderProvider.getOrderById(placedOrder.id)?.status, OrderStatus.ready);

      // Admin Completes Order
      orderProvider.completeOrder(placedOrder.id);
      expect(orderProvider.getOrderById(placedOrder.id)?.status, OrderStatus.completed);

      // Admin Cancels Order test
      final order2 = orderProvider.placeOrder(
        items: [],
        totalAmount: 50.0,
        customerName: 'Bvc Students Group',
        phoneNumber: '8090451729',
      );
      orderProvider.cancelOrder(order2.id);
      expect(orderProvider.getOrderById(order2.id)?.status, OrderStatus.cancelled);
    });

    test('FoodProvider manages 25 foods and toggles availability', () {
      final foodProvider = FoodProvider();
      expect(foodProvider.totalFoodCount, 25);
      expect(foodProvider.availableFoodCount, 25);

      final firstItem = foodProvider.allItems.first;
      foodProvider.toggleAvailability(firstItem.id);

      expect(foodProvider.findById(firstItem.id)?.isAvailable, isFalse);
      expect(foodProvider.availableFoodCount, 24);

      // Restore
      foodProvider.toggleAvailability(firstItem.id);
      expect(foodProvider.findById(firstItem.id)?.isAvailable, isTrue);
    });

    test('AdminProvider validates credentials correctly', () {
      final adminProvider = AdminProvider();
      expect(adminProvider.isAuthenticated, isFalse);

      // Failed login
      final failed = adminProvider.login('wrong@email.com', 'badpass');
      expect(failed, isFalse);
      expect(adminProvider.isAuthenticated, isFalse);

      // Successful login
      final success = adminProvider.login('Bvcgroup.com', 'admin123');
      expect(success, isTrue);
      expect(adminProvider.isAuthenticated, isTrue);
      expect(adminProvider.currentAdmin?.email, 'Bvcgroup.com');
      expect(adminProvider.currentAdmin?.name, 'Bvc Students Group');
      expect(adminProvider.currentAdmin?.studentId, '24221A05G5');
      expect(adminProvider.currentAdmin?.phoneNumber, '8090451729');

      // Logout
      adminProvider.logout();
      expect(adminProvider.isAuthenticated, isFalse);
    });
  });
}
