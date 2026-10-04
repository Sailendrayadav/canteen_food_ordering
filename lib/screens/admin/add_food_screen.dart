import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/food_data.dart';
import '../../models/food_item.dart';
import '../../providers/food_provider.dart';
import '../../theme/app_theme.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prepTimeController = TextEditingController(text: '10-12 mins');
  final _imageUrlController = TextEditingController(
    text: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&auto=format&fit=crop&q=75',
  );
  final _ratingController = TextEditingController(text: '4.5');

  String _selectedCategory = 'Fast Food';
  bool _isVeg = true;
  bool _isAvailable = true;
  bool _isPopular = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _prepTimeController.dispose();
    _imageUrlController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  void _saveFood() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final price = double.tryParse(_priceController.text) ?? 50.0;
    final rating = double.tryParse(_ratingController.text) ?? 4.5;
    final newId = 'f_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999)}';

    final newFood = FoodItem(
      id: newId,
      name: _nameController.text.trim(),
      price: price,
      rating: rating,
      category: _selectedCategory,
      imageUrl: _imageUrlController.text.trim(),
      description: _descriptionController.text.trim(),
      prepTime: _prepTimeController.text.trim(),
      isVeg: _isVeg,
      isAvailable: _isAvailable,
      isPopular: _isPopular,
    );

    Provider.of<FoodProvider>(context, listen: false).addFoodItem(newFood);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${newFood.name}" added to menu successfully!'),
        backgroundColor: AppTheme.secondaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('Add New Food Item'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Info Card
              _buildSectionCard(
                title: 'Basic Information',
                icon: Icons.info_outline_rounded,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Food Name',
                        hintText: 'e.g. Paneer Roll, Coffee, Samosa',
                        prefixIcon: Icon(Icons.restaurant_rounded),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter food name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Price (₹)',
                              hintText: '50',
                              prefixIcon: Icon(Icons.currency_rupee_rounded),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Enter price';
                              }
                              if (double.tryParse(val) == null) {
                                return 'Invalid number';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _ratingController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Rating (0 - 5)',
                              hintText: '4.5',
                              prefixIcon: Icon(Icons.star_rounded, color: Colors.amber),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Enter rating';
                              }
                              final r = double.tryParse(val);
                              if (r == null || r < 0 || r > 5) {
                                return 'Between 0-5';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Category Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(Icons.category_rounded),
                      ),
                      items: FoodData.adminCategories.map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCategory = val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Description & Prep Time Card
              _buildSectionCard(
                title: 'Description & Details',
                icon: Icons.description_outlined,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Briefly describe the food ingredients and taste',
                        alignLabelWithHint: true,
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _prepTimeController,
                      decoration: const InputDecoration(
                        labelText: 'Preparation Time',
                        hintText: 'e.g. 10-15 mins',
                        prefixIcon: Icon(Icons.timer_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Image URL',
                        hintText: 'https://...',
                        prefixIcon: Icon(Icons.image_outlined),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please provide an image URL';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Options Card (Veg/NonVeg, Availability, Popular)
              _buildSectionCard(
                title: 'Status & Tags',
                icon: Icons.tune_rounded,
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Available in Stock', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: const Text('Allow customers to order this item', style: TextStyle(fontSize: 12)),
                      value: _isAvailable,
                      activeThumbColor: AppTheme.secondaryColor,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) => setState(() => _isAvailable = val),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Vegetarian Item', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text(_isVeg ? 'Marked as Vegetarian' : 'Marked as Non-Vegetarian', style: const TextStyle(fontSize: 12)),
                      value: _isVeg,
                      activeThumbColor: AppTheme.vegColor,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) => setState(() => _isVeg = val),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Mark as Popular Item', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: const Text('Highlighted in customer popular carousel', style: TextStyle(fontSize: 12)),
                      value: _isPopular,
                      activeThumbColor: AppTheme.primaryColor,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) => setState(() => _isPopular = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveFood,
                  icon: const Icon(Icons.check_circle_rounded),
                  label: const Text(
                    'Save Food Item',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
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
              Icon(icon, size: 20, color: Colors.indigo.shade700),
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
