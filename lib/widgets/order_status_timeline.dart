import 'package:flutter/material.dart';
import '../models/order.dart';
import '../theme/app_theme.dart';

class OrderStatusTimeline extends StatelessWidget {
  final OrderStatus currentStatus;

  const OrderStatusTimeline({
    super.key,
    required this.currentStatus,
  });

  static const List<Map<String, dynamic>> _steps = [
    {
      'status': OrderStatus.pending,
      'title': 'Order Placed',
      'subtitle': 'Order placed & awaiting confirmation',
      'icon': Icons.receipt_long_rounded,
    },
    {
      'status': OrderStatus.confirmed,
      'title': 'Confirmed',
      'subtitle': 'Order confirmed by canteen kitchen',
      'icon': Icons.check_circle_outline_rounded,
    },
    {
      'status': OrderStatus.preparing,
      'title': 'Preparing',
      'subtitle': 'Kitchen is preparing your food',
      'icon': Icons.soup_kitchen_rounded,
    },
    {
      'status': OrderStatus.ready,
      'title': 'Ready',
      'subtitle': 'Ready for counter pickup',
      'icon': Icons.check_circle_rounded,
    },
    {
      'status': OrderStatus.completed,
      'title': 'Completed',
      'subtitle': 'Order completed. Enjoy your meal!',
      'icon': Icons.celebration_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final currentIdx = currentStatus.stepIndex;
    final isCancelled = currentStatus == OrderStatus.cancelled;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Order Status (Read-Only)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: currentStatus.statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  currentStatus.displayName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: currentStatus.statusColor,
                  ),
                ),
              ),
            ],
          ),
          if (isCancelled) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.cancel_rounded, color: Colors.red.shade700, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'This order has been cancelled by the canteen administration.',
                      style: TextStyle(fontSize: 12, color: Colors.red.shade800, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _steps.length,
            itemBuilder: (context, index) {
              final step = _steps[index];
              final isPassed = index < currentIdx;
              final isCurrent = index == currentIdx;
              final isFuture = index > currentIdx;
              final isLast = index == _steps.length - 1;

              final Color activeColor = isPassed
                  ? AppTheme.secondaryColor
                  : isCurrent
                      ? AppTheme.primaryColor
                      : const Color(0xFFEEEEEE);

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon + Line
                  Column(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: activeColor,
                          shape: BoxShape.circle,
                          boxShadow: isCurrent
                              ? [
                                  BoxShadow(
                                    color: AppTheme.primaryColor.withValues(alpha: 0.35),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : [],
                        ),
                        child: Icon(
                          isPassed ? Icons.check : step['icon'] as IconData,
                          size: 18,
                          color: isPassed || isCurrent ? Colors.white : Colors.grey.shade500,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 3,
                          height: 32,
                          color: isPassed ? AppTheme.secondaryColor : const Color(0xFFE0E0E0),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),

                  // Text Info
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                step['title'] as String,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                                  color: isFuture ? AppTheme.textMuted : AppTheme.textPrimary,
                                ),
                              ),
                              if (isCurrent) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'CURRENT',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            step['subtitle'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              color: isFuture ? AppTheme.textMuted : AppTheme.textSecondary,
                            ),
                          ),
                          if (!isLast) const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
