import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../theme/app_theme.dart';
import 'order_success_screen.dart';
import 'order_tracking_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Bvc Students Group');
  final _phoneController = TextEditingController(text: '8090451729');
  final _noteController = TextEditingController();

  String _pickupOption = 'Counter Pickup';
  String _paymentMethod = 'Cash at Canteen';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _confirmOrder() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    if (cartProvider.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty!')),
      );
      return;
    }

    final newOrder = orderProvider.placeOrder(
      items: cartProvider.cartList,
      totalAmount: cartProvider.totalAmount,
      customerName: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      pickupOption: _pickupOption,
      paymentMethod: _paymentMethod,
    );

    // Clear cart after placing order
    cartProvider.clearCart();

    // Show clean success notification (no undo)
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 20),
                SizedBox(width: 8),
                Text(
                  'Order Placed Successfully',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Order ID: ${newOrder.id}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const Text(
              'Your order has been sent to the canteen.',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF2E384D),
        action: SnackBarAction(
          label: 'View Order',
          textColor: Colors.amberAccent,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => OrderTrackingScreen(orderId: newOrder.id),
              ),
            );
          },
        ),
      ),
    );

    // Navigate to order confirmation
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => OrderSuccessScreen(order: newOrder),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Order Summary Card
                _buildCardSection(
                  title: 'Order Summary (${cart.itemCount} items)',
                  icon: Icons.receipt_long_rounded,
                  child: Column(
                    children: [
                      ...cart.cartList.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.quantity}x ${item.foodItem.name}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Text(
                                '₹${item.totalPrice.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                          Text('₹${cart.subtotalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Packaging Fee', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                          Text('₹10', style: TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total to Pay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(
                            '₹${cart.totalAmount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Student / Customer Details
                _buildCardSection(
                  title: 'Student / Customer Details',
                  icon: Icons.person_rounded,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          hintText: 'Enter student or staff name',
                          prefixIcon: Icon(Icons.badge_outlined, color: AppTheme.primaryColor),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Mobile Number',
                          hintText: '10-digit mobile number',
                          prefixIcon: Icon(Icons.phone_outlined, color: AppTheme.primaryColor),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().length < 10) {
                            return 'Please enter a valid 10-digit phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _noteController,
                        decoration: const InputDecoration(
                          labelText: 'Special Note / Instruction (Optional)',
                          hintText: 'e.g. Extra spicy, less sugar, table #4',
                          prefixIcon: Icon(Icons.note_alt_outlined, color: AppTheme.primaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Pickup Option
                _buildCardSection(
                  title: 'Pickup & Delivery Option',
                  icon: Icons.storefront_rounded,
                  child: Column(
                    children: [
                      _buildSelectableTile(
                        title: 'Counter Self-Pickup',
                        subtitle: 'Collect directly from Counter 1 when ready',
                        isSelected: _pickupOption == 'Counter Pickup',
                        icon: Icons.storefront_outlined,
                        onTap: () => setState(() => _pickupOption = 'Counter Pickup'),
                      ),
                      const SizedBox(height: 8),
                      _buildSelectableTile(
                        title: 'Dining Table Delivery',
                        subtitle: 'Delivered to your canteen table (specify in notes)',
                        isSelected: _pickupOption == 'Dining Table Delivery',
                        icon: Icons.table_restaurant_outlined,
                        onTap: () => setState(() => _pickupOption = 'Dining Table Delivery'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Payment Method
                _buildCardSection(
                  title: 'Payment Method',
                  icon: Icons.payment_rounded,
                  child: Column(
                    children: [
                      _buildSelectableTile(
                        title: 'Cash at Canteen',
                        subtitle: 'Pay with cash at counter while picking up',
                        isSelected: _paymentMethod == 'Cash at Canteen',
                        icon: Icons.money_rounded,
                        accentColor: AppTheme.secondaryColor,
                        onTap: () => setState(() => _paymentMethod = 'Cash at Canteen'),
                      ),
                      const SizedBox(height: 8),
                      _buildSelectableTile(
                        title: 'UPI / QR Pay (Simulated)',
                        subtitle: 'Google Pay, PhonePe, Paytm, or BHIM',
                        isSelected: _paymentMethod == 'UPI',
                        icon: Icons.qr_code_scanner_rounded,
                        onTap: () => setState(() => _paymentMethod = 'UPI'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Confirm Order Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _confirmOrder,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Confirm Order (₹${cart.totalAmount.toStringAsFixed(0)})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectableTile({
    required String title,
    required String subtitle,
    required bool isSelected,
    required IconData icon,
    required VoidCallback onTap,
    Color? accentColor,
  }) {
    final activeColor = accentColor ?? AppTheme.primaryColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFE0E0E0),
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? activeColor : AppTheme.textSecondary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: isSelected ? activeColor : const Color(0xFFBDBDBD),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
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
            children: [
              Icon(icon, size: 20, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
