import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:juju_games/src/app_config/app_theme/app_theme.dart';
import 'package:juju_games/src/app_config/app_theme/theme_controller.dart';
import 'package:juju_games/src/view/home_page.dart';

class JujuGames extends StatelessWidget {
  const JujuGames({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.put(ThemeController());

    return Obx(() {
      return GetMaterialApp(
        title: 'Juju Games',
        debugShowCheckedModeBanner: false,
        themeMode: themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        home: const HomePage(),
      );
    });
  }
}