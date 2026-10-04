import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/order_card.dart';
import '../customer/order_tracking_screen.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  OrderStatus? _selectedStatusFilter;

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final orders = orderProvider.filterByStatus(_selectedStatusFilter);

    final statusFilters = [
      {'label': 'All (${orderProvider.totalOrdersCount})', 'value': null},
      {'label': 'New (${orderProvider.pendingCount})', 'value': OrderStatus.pending},
      {'label': 'Confirmed (${orderProvider.confirmedCount})', 'value': OrderStatus.confirmed},
      {'label': 'Preparing (${orderProvider.preparingCount})', 'value': OrderStatus.preparing},
      {'label': 'Ready (${orderProvider.readyCount})', 'value': OrderStatus.ready},
      {'label': 'Completed (${orderProvider.completedCount})', 'value': OrderStatus.completed},
      {'label': 'Cancelled (${orderProvider.cancelledOrdersCount})', 'value': OrderStatus.cancelled},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('Order Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset Orders to Demo',
            onPressed: () {
              orderProvider.resetToDemo();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Orders reset to demo list!')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Horizontal Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: statusFilters.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final item = statusFilters[index];
                  final filterVal = item['value'] as OrderStatus?;
                  final isSelected = _selectedStatusFilter == filterVal;

                  return FilterChip(
                    label: Text(
                      item['label'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : AppTheme.textPrimary,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: Colors.indigo.shade800,
                    backgroundColor: const Color(0xFFF1F3F5),
                    checkmarkColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    side: BorderSide.none,
                    onSelected: (_) {
                      setState(() {
                        _selectedStatusFilter = filterVal;
                      });
                    },
                  );
                },
              ),
            ),
          ),

          // Orders Count Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${orders.length} Orders Listed',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Text(
                  'Select status to update customer view',
                  style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),

          // Orders List
          Expanded(
            child: orders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.receipt_long_outlined, size: 54, color: AppTheme.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          _selectedStatusFilter == null
                              ? 'No orders yet'
                              : _selectedStatusFilter == OrderStatus.pending
                                  ? 'No new orders waiting'
                                  : 'No orders with status "${_selectedStatusFilter!.displayName}"',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return OrderCard(
                        order: order,
                        isAdmin: true,
                        onStatusChanged: (newStatus) {
                          orderProvider.updateOrderStatus(order.id, newStatus);
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Order ${order.id} status changed to ${newStatus.displayName}'),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => OrderTrackingScreen(orderId: order.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
