
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:juju_games/src/app_config/app_theme/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DinoJumpScreen extends StatefulWidget {
  const DinoJumpScreen({super.key});

  @override
  _DinoJumpScreenState createState() => _DinoJumpScreenState();
}

class _DinoJumpScreenState extends State<DinoJumpScreen> with SingleTickerProviderStateMixin {
  static const double dinoWidth = 50;
  static const double dinoHeight = 80;
  static const double obstacleWidth = 30;
  static const double obstacleHeight = 50;

  double dinoY = 0.0; // Relative to ground
  double dinoVelocity = 0;
  double gravity = 0.001;
  List<double> obstacles = [];
  Timer? gameLoop;
  Timer? obstacleTimer;
  int score = 0;
  int highScore = 0;
  bool isJumping = false;
  bool gameOver = false;
  Random random = Random();
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    animation = Tween<double>(begin: 0, end: 1).animate(controller)
      ..addListener(() {
        setState(() {});
      });
    startGame();
  }

  void _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = prefs.getInt('dino_high_score') ?? 0;
    });
  }

  void _saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dino_high_score', highScore);
  }

  void startGame() {
    setState(() {
      dinoY = 0.0;
      dinoVelocity = 0;
      obstacles = [];
      score = 0;
      gameOver = false;
      isJumping = false;
      gameLoop?.cancel();
      obstacleTimer?.cancel();
      gameLoop = Timer.periodic(const Duration(milliseconds: 16), (timer) {
        if (!gameOver) {
          updateGame();
        }
      });
      obstacleTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
        if (!gameOver) {
          addObstacle();
        }
      });
    });
  }

  void jump() {
    if (!isJumping && !gameOver) {
      setState(() {
        isJumping = true;
        dinoVelocity = -0.025;
        controller.reset();
        controller.forward();
      });
    }
  }

  void updateGame() {
    setState(() {
      dinoVelocity += gravity;
      dinoY += dinoVelocity;
      if (dinoY > 0) {
        dinoY = 0;
        dinoVelocity = 0;
        isJumping = false;
      }
      obstacles = obstacles.map((obstacle) => obstacle - 0.01).toList();
      obstacles.removeWhere((obstacle) => obstacle < -0.1);
      score++;
      for (var obstacle in obstacles) {
        final dinoRect = Rect.fromLTWH(
          100,
          MediaQuery.of(context).size.height - 100 - dinoHeight + dinoY * 200,
          dinoWidth,
          dinoHeight,
        );
        final obstacleRect = Rect.fromLTWH(
          obstacle * MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height - 100,
          obstacleWidth,
          obstacleHeight,
        );
        if (dinoRect.overlaps(obstacleRect)) {
          gameOver = true;
          if (score > highScore) {
            highScore = score;
            _saveHighScore();
          }
          break;
        }
      }
    });
  }

  void addObstacle() {
    setState(() {
      obstacles.add(1.0);
    });
  }

  @override
  void dispose() {
    gameLoop?.cancel();
    obstacleTimer?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dino Jump 🦖'),
        centerTitle: true,
        actions: [
          Obx(() => IconButton(
                icon: Icon(themeController.isDarkMode.value ? Icons.light_mode : Icons.dark_mode),
                onPressed: themeController.toggleTheme,
                tooltip: 'Toggle Theme',
              )),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.background,
              Theme.of(context).colorScheme.background.withOpacity(0.8),
            ],
          ),
        ),
        child: GestureDetector(
          onTap: jump,
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.grey[400]
                        : Colors.grey[700],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 100,
                bottom: 100 + dinoY * 200,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..rotateZ(isJumping ? animation.value * 0.2 - 0.1 : 0),
                  child: const Icon(Icons.directions_run, size: 50, color: Colors.green),
                ),
              ),
              for (var obstacle in obstacles)
                Positioned(
                  left: obstacle * MediaQuery.of(context).size.width,
                  bottom: 100,
                  child: Container(
                    width: obstacleWidth,
                    height: obstacleHeight,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              Positioned(
                top: 20,
                right: 20,
                child: Text(
                  'Score: $score 🌟',
                  style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge!.color),
                ),
              ),
              Positioned(
                top: 50,
                right: 20,
                child: Text(
                  'High Score: $highScore 🏆',
                  style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge!.color),
                ),
              ),
              if (gameOver)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Game Over 😢',
                          style: GoogleFonts.poppins(
                              fontSize: 40, color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Score: $score 🌟',
                          style: GoogleFonts.poppins(
                              fontSize: 30,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).textTheme.bodyLarge!.color),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text('Play Again'),
                          onPressed: startGame,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
