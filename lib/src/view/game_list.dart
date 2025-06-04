import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:juju_games/src/view/games/dino_jump.dart';
import 'package:juju_games/src/view/games/memory.dart';
import 'package:juju_games/src/view/games/rock_paper_scissors.dart';
import 'package:juju_games/src/view/games/snake.dart';
import 'package:juju_games/src/view/games/space_shooter.dart';
import 'package:juju_games/src/view/games/tic_tac_toe.dart';
import 'package:juju_games/src/widgets/game_list_tile.dart';

import '../app_config/app_theme/theme_controller.dart';

class GameList extends StatelessWidget {
  GameList({super.key});

  final themeController = Get.find<ThemeController>();

  final List<Map<String, dynamic>> gameList = [
    {
      "name": "Dino Jump 🦖",
      "desc": "Jump over obstacles",
      "icon": Icons.directions_run,
      "gradient_color": [Colors.orange[600]!, Colors.orange[400]!],
      "route": () => Get.to(() => const DinoGame()),
    },
    {
      "name": "Tic Tac Toe ❎⭕",
      "desc": "Classic X and O game",
      "icon": Icons.grid_3x3,
      "gradient_color": [Colors.blue[600]!, Colors.blue[400]!],
      "route": () => Get.to(() => const TicTacToeScreen()),
    },
    {
      "name": "Memory Game 🧠",
      "desc": "Test your memory with cards",
      "icon": Icons.memory,
      "gradient_color": [Colors.purple[600]!, Colors.purple[400]!],
      "route": () => Get.to(() => const MemoryGameScreen()),
    },
    {
      "name": "Rock Paper Scissors ✊✋✌️",
      "desc": "Classic hand game",
      "icon": Icons.gesture,
      "gradient_color": [Colors.green[600]!, Colors.green[400]!],
      "route": () => Get.to(() => const RockPaperScissorsScreen()),
    },
    {
      "name": "Snake Game 🐍",
      "desc": "Classic snake game",
      "icon": Icons.settings_ethernet,
      "gradient_color": [Colors.teal[600]!, Colors.teal[400]!],
      "route": () => Get.to(() => const SnakeGameScreen()),
    },
    {
      "name": "Space Shooter 🚀",
      "desc": "Shoot asteroids in space",
      "icon": Icons.rocket,
      "gradient_color": [Colors.indigo[600]!, Colors.indigo[400]!],
      "route": () => Get.to(() => const SpaceShooterScreen()),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final padding = themeController.paddingValue.value;

      return Scaffold(
        body: Padding(
          padding: EdgeInsets.all(padding),
          child: GridView.builder(
            itemCount: gameList.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
              crossAxisSpacing: padding,
              mainAxisSpacing: padding,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final game = gameList[index];
              return GameCard(
                title: game['name'],
                description: game['desc'],
                icon: game['icon'],
                gradientColors: game['gradient_color'],
                onTap: game['route'],
              );
            },
          ),
        ),
      );
    });
  }
}
