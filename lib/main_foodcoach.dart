import 'package:flutter/material.dart';
import 'config/flavor_config.dart';
import 'main.dart' as app;

void main() {
  FlavorConfig(
    flavor: Flavor.foodcoach,
    values: FlavorValues(
      appName: 'FoodCoach',
      appId: 'com.playcus.foodcoach',
      useRedesignedHome: false, // Используем оригинальный home_screen
    ),
  );

  app.main();
}