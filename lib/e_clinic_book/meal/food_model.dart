class FoodItem {
  final String? id;
  final String name;
  final String type; // dry, wet, raw, homemade, etc.
  final String? brand;
  final double? caloriesPerServing;
  final double? servingSize; // in grams
  final String? nutritionalInfo;
  final bool isFavorite;

  FoodItem({
    this.id,
    required this.name,
    required this.type,
    this.brand,
    this.caloriesPerServing,
    this.servingSize,
    this.nutritionalInfo,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'brand': brand,
      'caloriesPerServing': caloriesPerServing,
      'servingSize': servingSize,
      'nutritionalInfo': nutritionalInfo,
      'isFavorite': isFavorite,
    };
  }

  factory FoodItem.fromMap(String id, Map<String, dynamic> map) {
    return FoodItem(
      id: id,
      name: map['name'] as String,
      type: map['type'] as String,
      brand: map['brand'] as String?,
      caloriesPerServing: map['caloriesPerServing']?.toDouble(),
      servingSize: map['servingSize']?.toDouble(),
      nutritionalInfo: map['nutritionalInfo'] as String?,
      isFavorite: map['isFavorite'] as bool? ?? false,
    );
  }

  FoodItem copyWith({required bool isFavorite}) {
    return FoodItem(
      id: id,
      name: name,
      type: type,
      brand: brand,
      caloriesPerServing: caloriesPerServing,
      servingSize: servingSize,
      nutritionalInfo: nutritionalInfo,
      isFavorite: isFavorite,
    );
  }
}
