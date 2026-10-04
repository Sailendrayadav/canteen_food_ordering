import 'package:flutter/material.dart';
import 'food_item.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  completed,
  cancelled;

  // Compatibility alias
  static const OrderStatus placed = OrderStatus.pending;

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing Food';
      case OrderStatus.ready:
        return 'Ready for Pickup';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get statusColor {
    switch (this) {
      case OrderStatus.pending:
        return const Color(0xFF1976D2); // Blue
      case OrderStatus.confirmed:
        return const Color(0xFF0288D1); // Light Blue / Cyan
      case OrderStatus.preparing:
        return const Color(0xFFF57C00); // Orange
      case OrderStatus.ready:
        return const Color(0xFF388E3C); // Green
      case OrderStatus.completed:
        return const Color(0xFF455A64); // Blue Grey
      case OrderStatus.cancelled:
        return const Color(0xFFD32F2F); // Red
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.pending:
        return Icons.hourglass_top_rounded;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline_rounded;
      case OrderStatus.preparing:
        return Icons.soup_kitchen_rounded;
      case OrderStatus.ready:
        return Icons.check_circle_rounded;
      case OrderStatus.completed:
        return Icons.task_alt_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }

  int get stepIndex {
    switch (this) {
      case OrderStatus.pending:
        return 0;
      case OrderStatus.confirmed:
        return 1;
      case OrderStatus.preparing:
        return 2;
      case OrderStatus.ready:
        return 3;
      case OrderStatus.completed:
        return 4;
      case OrderStatus.cancelled:
        return -1;
    }
  }
}

class CartItem {
  final FoodItem foodItem;
  int quantity;

  CartItem({
    required this.foodItem,
    this.quantity = 1,
  });

  double get totalPrice => foodItem.price * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      foodItem: foodItem,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CanteenOrder {
  final String id;
  final List<CartItem> items;
  final double totalAmount;
  final DateTime dateTime;
  OrderStatus status;
  final String customerName;
  final String phoneNumber;
  final String pickupOption;
  final String paymentMethod;
  final int estimatedMinutes;

  CanteenOrder({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.dateTime,
    this.status = OrderStatus.pending,
    required this.customerName,
    required this.phoneNumber,
    this.pickupOption = 'Counter Pickup',
    this.paymentMethod = 'Cash at Canteen',
    this.estimatedMinutes = 15,
  });

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);
}
