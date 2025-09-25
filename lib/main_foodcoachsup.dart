import 'package:flutter/material.dart';
import 'config/flavor_config.dart';
import 'main.dart' as app;

void main() {
  FlavorConfig(
    flavor: Flavor.foodcoachsup,
    values: FlavorValues(
      appName: 'FoodMaster Pro',
      appId: 'com.logics7.foodmasterpro',
      useRedesignedHome: true, // Используем home_screen_redesign
    ),
  );

  app.main();
}