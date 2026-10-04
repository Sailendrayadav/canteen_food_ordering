class FoodItem {
  final String id;
  final String name;
  final double price;
  final double rating;
  final String category;
  final String imageUrl;
  final String description;
  final String prepTime;
  final bool isVeg;
  final bool isPopular;
  final bool isAvailable;

  const FoodItem({
    required this.id,
    required this.name,
    required this.price,
    required this.rating,
    required this.category,
    required this.imageUrl,
    required this.description,
    this.prepTime = '10-15 mins',
    this.isVeg = true,
    this.isPopular = false,
    this.isAvailable = true,
  });

  // Formatted price string with rupee symbol
  String get formattedPrice => '₹${price.toStringAsFixed(0)}';

  FoodItem copyWith({
    String? id,
    String? name,
    double? price,
    double? rating,
    String? category,
    String? imageUrl,
    String? description,
    String? prepTime,
    bool? isVeg,
    bool? isPopular,
    bool? isAvailable,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      prepTime: prepTime ?? this.prepTime,
      isVeg: isVeg ?? this.isVeg,
      isPopular: isPopular ?? this.isPopular,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
