enum Flavor {
  foodcoach,
  foodcoachsup,
}

class FlavorValues {
  final String appName;
  final String appId;
  final bool useRedesignedHome;

  FlavorValues({
    required this.appName,
    required this.appId,
    required this.useRedesignedHome,
  });
}

class FlavorConfig {
  final Flavor flavor;
  final FlavorValues values;

  static FlavorConfig? _instance;

  factory FlavorConfig({
    required Flavor flavor,
    required FlavorValues values,
  }) {
    _instance ??= FlavorConfig._internal(flavor, values);
    return _instance!;
  }

  FlavorConfig._internal(this.flavor, this.values);

  static FlavorConfig get instance => _instance!;

  static bool get isFoodCoach => _instance?.flavor == Flavor.foodcoach;
  static bool get isFoodCoachSup => _instance?.flavor == Flavor.foodcoachsup;

  static bool get useRedesignedHome => _instance?.values.useRedesignedHome ?? false;
}