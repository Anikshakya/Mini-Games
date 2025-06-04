// theme_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:juju_games/src/app_utils/read_write.dart';

class ThemeController extends GetxController {
  var seedColor = Colors.deepPurple.obs;
  var isDarkMode = true.obs;
  var borderRadius = 50.0.obs;
  var paddingValue = 16.0.obs;

  final List<MaterialColor> colorOptions = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.blueGrey,
  ];

  @override
  void onInit() {
    super.onInit();

    // Load from storage
    isDarkMode.value = read('isDarkMode') ?? true;

    final dynamic colorIndex = read('seedColorIndex') ?? 3;
    if (colorIndex != null && colorIndex < colorOptions.length) {
      seedColor.value = colorOptions[colorIndex];
    }

    borderRadius.value = read('borderRadius') ?? 8.0;
    paddingValue.value = read('paddingValue') ?? 16.0;
  }

  void changeSeedColor(MaterialColor newColor) {
    seedColor.value = newColor;
    final index = colorOptions.indexOf(newColor);
    write('seedColorIndex', index);
  }

  void toggleTheme() {
    isDarkMode.toggle();
    write('isDarkMode', isDarkMode.value);
  }

  void updateBorderRadius(double value) {
    borderRadius.value = value;
    write('borderRadius', value);
  }

  void updatePadding(double value) {
    paddingValue.value = value;
    write('paddingValue', value);
  }
}