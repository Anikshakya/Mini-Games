import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:juju_games/src/app_config/app_theme/theme_controller.dart';
import 'package:juju_games/src/view/game_list.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var themeCon = Get.put(ThemeController());
    return Scaffold(
      appBar: AppBar(
        title: Text("Juju Mini Games"),
        actions: [
          Obx(() => IconButton(
            icon: Icon(themeCon.isDarkMode.value ? Icons.light_mode : Icons.dark_mode),
            onPressed: themeCon.toggleTheme,
            tooltip: 'Toggle Theme',
          )),
        ],
      ),
      body: GameList(),
    );
  }
}