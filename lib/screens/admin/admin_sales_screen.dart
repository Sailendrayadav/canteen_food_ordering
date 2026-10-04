import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/admin_stat_card.dart';

class AdminSalesScreen extends StatelessWidget {
  const AdminSalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final orders = orderProvider.orders;

    // Payment calculations
    final upiOrders = orders.where((o) => o.paymentMethod == 'UPI' && o.status != OrderStatus.cancelled);
    final cashOrders = orders.where((o) => o.paymentMethod == 'Cash at Canteen' && o.status != OrderStatus.cancelled);

    final upiSales = upiOrders.fold(0.0, (sum, o) => sum + o.totalAmount);
    final cashSales = cashOrders.fold(0.0, (sum, o) => sum + o.totalAmount);

    final totalCount = orders.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('Sales & Revenue Summary'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Highlights Grid (Today's Sales, Total Sales, Orders, Completed)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.35,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                AdminStatCard(
                  title: "Today's Sales",
                  value: '₹${orderProvider.todaySales.toStringAsFixed(0)}',
                  icon: Icons.today_rounded,
                  color: Colors.green.shade800,
                  subtitle: 'Live today',
                ),
                AdminStatCard(
                  title: 'Total Sales',
                  value: '₹${orderProvider.totalSales.toStringAsFixed(0)}',
                  icon: Icons.account_balance_wallet_rounded,
                  color: Colors.indigo.shade800,
                  subtitle: 'All time',
                ),
                AdminStatCard(
                  title: 'Number of Orders',
                  value: '$totalCount',
                  icon: Icons.receipt_long_rounded,
                  color: Colors.blue.shade700,
                  subtitle: 'Total orders placed',
                ),
                AdminStatCard(
                  title: 'Completed Orders',
                  value: '${orderProvider.completedOrdersCount}',
                  icon: Icons.check_circle_rounded,
                  color: Colors.teal.shade700,
                  subtitle: 'Successfully served',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Payment Methods Summary Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.pie_chart_rounded, size: 20, color: Colors.indigo),
                      SizedBox(width: 8),
                      Text(
                        'Revenue by Payment Mode',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildPaymentBar(
                    label: 'UPI / Online QR',
                    amount: upiSales,
                    total: orderProvider.totalSales,
                    orderCount: upiOrders.length,
                    color: Colors.deepPurple,
                    icon: Icons.qr_code_rounded,
                  ),
                  const SizedBox(height: 14),
                  _buildPaymentBar(
                    label: 'Cash at Counter',
                    amount: cashSales,
                    total: orderProvider.totalSales,
                    orderCount: cashOrders.length,
                    color: AppTheme.secondaryColor,
                    icon: Icons.payments_rounded,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Order Status Pipeline Summary Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.insights_rounded, size: 20, color: Colors.indigo),
                      SizedBox(width: 8),
                      Text(
                        'Order Status Pipeline',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildPipelineRow(
                    status: OrderStatus.pending,
                    count: orders.where((o) => o.status == OrderStatus.pending).length,
                    total: totalCount,
                  ),
                  const SizedBox(height: 10),
                  _buildPipelineRow(
                    status: OrderStatus.confirmed,
                    count: orders.where((o) => o.status == OrderStatus.confirmed).length,
                    total: totalCount,
                  ),
                  const SizedBox(height: 10),
                  _buildPipelineRow(
                    status: OrderStatus.preparing,
                    count: orders.where((o) => o.status == OrderStatus.preparing).length,
                    total: totalCount,
                  ),
                  const SizedBox(height: 10),
                  _buildPipelineRow(
                    status: OrderStatus.ready,
                    count: orders.where((o) => o.status == OrderStatus.ready).length,
                    total: totalCount,
                  ),
                  const SizedBox(height: 10),
                  _buildPipelineRow(
                    status: OrderStatus.completed,
                    count: orderProvider.completedOrdersCount,
                    total: totalCount,
                  ),
                  const SizedBox(height: 10),
                  _buildPipelineRow(
                    status: OrderStatus.cancelled,
                    count: orderProvider.cancelledOrdersCount,
                    total: totalCount,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentBar({
    required String label,
    required double amount,
    required double total,
    required int orderCount,
    required Color color,
    required IconData icon,
  }) {
    final percentage = total > 0 ? (amount / total) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ],
            ),
            Text(
              '₹${amount.toStringAsFixed(0)} ($orderCount orders)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: const Color(0xFFEEEEEE),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildPipelineRow({
    required OrderStatus status,
    required int count,
    required int total,
  }) {
    final progress = total > 0 ? (count / total) : 0.0;

    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            status.displayName,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFEEEEEE),
              valueColor: AlwaysStoppedAnimation<Color>(status.statusColor),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 30,
          child: Text(
            '$count',
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
