// ============================================================================
// FILE: lib/models/food_intake.dart
//
// PURPOSE: Data model for food intake tracking
// ============================================================================

class FoodIntake {
  final String id;
  final DateTime timestamp;
  final String foodId; // ID продукта из каталога
  final String foodName; // Название продукта для отображения
  final double weight; // Вес в граммах/мл
  final int calories; // Калории
  final double waterContent; // Содержание воды в мл
  final int sodium; // Натрий в мг
  final int potassium; // Калий в мг
  final int magnesium; // Магний в мг
  final double sugar; // Сахар в граммах
  final double proteins; // Белки в граммах
  final double carbohydrates; // Углеводы в граммах
  final double fats; // Жиры в граммах
  final bool hasCaffeine; // Содержит кофеин
  final String? emoji; // Эмодзи продукта

  FoodIntake({
    required this.id,
    required this.timestamp,
    required this.foodId,
    required this.foodName,
    required this.weight,
    required this.calories,
    required this.waterContent,
    this.sodium = 0,
    this.potassium = 0,
    this.magnesium = 0,
    this.sugar = 0.0,
    this.proteins = 0.0,
    this.carbohydrates = 0.0,
    this.fats = 0.0,
    this.hasCaffeine = false,
    this.emoji,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'foodId': foodId,
    'foodName': foodName,
    'weight': weight,
    'calories': calories,
    'waterContent': waterContent,
    'sodium': sodium,
    'potassium': potassium,
    'magnesium': magnesium,
    'sugar': sugar,
    'proteins': proteins,
    'carbohydrates': carbohydrates,
    'fats': fats,
    'hasCaffeine': hasCaffeine,
    if (emoji != null) 'emoji': emoji,
  };

  // Create from JSON
  factory FoodIntake.fromJson(Map<String, dynamic> json) => FoodIntake(
    id: json['id'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    foodId: json['foodId'] as String,
    foodName: json['foodName'] as String,
    weight: (json['weight'] as num).toDouble(),
    calories: json['calories'] as int,
    waterContent: (json['waterContent'] as num).toDouble(),
    sodium: json['sodium'] as int? ?? 0,
    potassium: json['potassium'] as int? ?? 0,
    magnesium: json['magnesium'] as int? ?? 0,
    sugar: (json['sugar'] as num?)?.toDouble() ?? 0.0,
    proteins: (json['proteins'] as num?)?.toDouble() ?? 0.0,
    carbohydrates: (json['carbohydrates'] as num?)?.toDouble() ?? 0.0,
    fats: (json['fats'] as num?)?.toDouble() ?? 0.0,
    hasCaffeine: json['hasCaffeine'] as bool? ?? false,
    emoji: json['emoji'] as String?,
  );

  // Copy with modifications
  FoodIntake copyWith({
    String? id,
    DateTime? timestamp,
    String? foodId,
    String? foodName,
    double? weight,
    int? calories,
    double? waterContent,
    int? sodium,
    int? potassium,
    int? magnesium,
    double? sugar,
    double? proteins,
    double? carbohydrates,
    double? fats,
    bool? hasCaffeine,
    String? emoji,
  }) {
    return FoodIntake(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      foodId: foodId ?? this.foodId,
      foodName: foodName ?? this.foodName,
      weight: weight ?? this.weight,
      calories: calories ?? this.calories,
      waterContent: waterContent ?? this.waterContent,
      sodium: sodium ?? this.sodium,
      potassium: potassium ?? this.potassium,
      magnesium: magnesium ?? this.magnesium,
      sugar: sugar ?? this.sugar,
      proteins: proteins ?? this.proteins,
      carbohydrates: carbohydrates ?? this.carbohydrates,
      fats: fats ?? this.fats,
      hasCaffeine: hasCaffeine ?? this.hasCaffeine,
      emoji: emoji ?? this.emoji,
    );
  }

  // Get formatted time string
  String get formattedTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
           '${timestamp.minute.toString().padLeft(2, '0')}';
  }

  // Get formatted weight string
  String getFormattedWeight(String units) {
    if (units == 'imperial') {
      // Convert grams to ounces
      final ounces = weight * 0.035274;
      return '${ounces.toStringAsFixed(1)} oz';
    } else {
      return '${weight.toStringAsFixed(0)} g';
    }
  }

  // Get total electrolytes
  int get totalElectrolytes => sodium + potassium + magnesium;

  // Check if food has high sodium content (>300mg per 100g)
  bool get isHighSodium {
    final sodiumPer100g = (sodium / weight) * 100;
    return sodiumPer100g > 300;
  }

  // Check if food has high water content (>80%)
  bool get isHighWaterContent {
    final waterPercentage = (waterContent / weight) * 100;
    return waterPercentage > 80;
  }

  @override
  String toString() {
    return 'FoodIntake(id: $id, timestamp: $timestamp, foodId: $foodId, '
           'foodName: $foodName, weight: $weight, calories: $calories, '
           'waterContent: $waterContent, sodium: $sodium, potassium: $potassium, '
           'magnesium: $magnesium, sugar: $sugar, proteins: $proteins, '
           'carbohydrates: $carbohydrates, fats: $fats, hasCaffeine: $hasCaffeine)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FoodIntake &&
      other.id == id &&
      other.timestamp == timestamp &&
      other.foodId == foodId &&
      other.foodName == foodName &&
      other.weight == weight &&
      other.calories == calories &&
      other.waterContent == waterContent &&
      other.sodium == sodium &&
      other.potassium == potassium &&
      other.magnesium == magnesium &&
      other.sugar == sugar &&
      other.proteins == proteins &&
      other.carbohydrates == carbohydrates &&
      other.fats == fats &&
      other.hasCaffeine == hasCaffeine &&
      other.emoji == emoji;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      timestamp.hashCode ^
      foodId.hashCode ^
      foodName.hashCode ^
      weight.hashCode ^
      calories.hashCode ^
      waterContent.hashCode ^
      sodium.hashCode ^
      potassium.hashCode ^
      magnesium.hashCode ^
      sugar.hashCode ^
      proteins.hashCode ^
      carbohydrates.hashCode ^
      fats.hashCode ^
      hasCaffeine.hashCode ^
      emoji.hashCode;
  }
}