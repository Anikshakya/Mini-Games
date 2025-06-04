
import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:juju_games/src/app_config/app_theme/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpaceShooterScreen extends StatefulWidget {
  const SpaceShooterScreen({super.key});

  @override
  _SpaceShooterScreenState createState() => _SpaceShooterScreenState();
}

class _SpaceShooterScreenState extends State<SpaceShooterScreen> {
  static const double playerWidth = 50;
  static const double playerHeight = 50;
  static const double bulletWidth = 10;
  static const double bulletHeight = 20;
  static const double enemyWidth = 40;
  static const double enemyHeight = 40;

  double playerX = 0.5;
  double playerY = 0.9;
  List<Map<String, double>> bullets = [];
  List<Map<String, double>> enemies = [];
  List<Offset> stars = [];
  Timer? gameLoop;
  Timer? enemySpawner;
  Timer? starSpawner;
  int score = 0;
  int highScore = 0;
  int lives = 3;
  bool gameOver = false;
  Random random = Random();

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    _initStars();
    startGame();
  }

  void _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = prefs.getInt('space_shooter_high_score') ?? 0;
    });
  }

  void _saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('space_shooter_high_score', highScore);
  }

  void _initStars() {
    stars = List.generate(50, (index) => Offset(random.nextDouble(), random.nextDouble()));
  }

  void startGame() {
    setState(() {
      playerX = 0.5;
      playerY = 0.9;
      bullets = [];
      enemies = [];
      score = 0;
      lives = 3;
      gameOver = false;
    });

    gameLoop?.cancel();
    enemySpawner?.cancel();
    starSpawner?.cancel();

    gameLoop = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!gameOver) {
        updateGame();
      }
    });

    enemySpawner = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (!gameOver) {
        spawnEnemy();
      }
    });

    starSpawner = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      updateStars();
    });
  }

  void updateStars() {
    setState(() {
      stars = stars.map((star) {
        double newY = star.dy + 0.005;
        if (newY > 1) newY = 0;
        return Offset(star.dx, newY);
      }).toList();
    });
  }

  void spawnEnemy() {
    setState(() {
      enemies.add({'x': random.nextDouble() * 0.9 + 0.05, 'y': 0.0});
    });
  }

  void shoot() {
    if (!gameOver) {
      setState(() {
        bullets.add({'x': playerX, 'y': playerY - 0.05});
      });
    }
  }

  void updateGame() {
    setState(() {
      // Update bullets
      bullets = bullets
          .map((bullet) => {'x': bullet['x']!, 'y': bullet['y']! - 0.02})
          .where((bullet) => bullet['y']! > -0.1)
          .toList();

      // Update enemies
      enemies = enemies
          .map((enemy) => {'x': enemy['x']!, 'y': enemy['y']! + 0.01})
          .where((enemy) => enemy['y']! < 1.2)
          .toList();

      // Check collisions
      List<Map<String, double>> bulletsToRemove = [];
      List<Map<String, double>> enemiesToRemove = [];

      for (var bullet in bullets) {
        for (var enemy in enemies) {
          final bulletRect = Rect.fromLTWH(
            bullet['x']! * MediaQuery.of(context).size.width - bulletWidth / 2,
            bullet['y']! * MediaQuery.of(context).size.height - bulletHeight / 2,
            bulletWidth,
            bulletHeight,
          );
          final enemyRect = Rect.fromLTWH(
            enemy['x']! * MediaQuery.of(context).size.width - enemyWidth / 2,
            enemy['y']! * MediaQuery.of(context).size.height - enemyHeight / 2,
            enemyWidth,
            enemyHeight,
          );

          if (bulletRect.overlaps(enemyRect)) {
            bulletsToRemove.add(bullet);
            enemiesToRemove.add(enemy);
            score += 10;
            if (score > highScore) {
              highScore = score;
              _saveHighScore();
            }
          }
        }
      }

      bullets.removeWhere((bullet) => bulletsToRemove.contains(bullet));
      enemies.removeWhere((enemy) => enemiesToRemove.contains(enemy));

      // Check player-enemy collision
      final playerRect = Rect.fromLTWH(
        playerX * MediaQuery.of(context).size.width - playerWidth / 2,
        playerY * MediaQuery.of(context).size.height - playerHeight / 2,
        playerWidth,
        playerHeight,
      );

      for (var enemy in enemies) {
        final enemyRect = Rect.fromLTWH(
          enemy['x']! * MediaQuery.of(context).size.width - enemyWidth / 2,
          enemy['y']! * MediaQuery.of(context).size.height - enemyHeight / 2,
          enemyWidth,
          enemyHeight,
        );

        if (playerRect.overlaps(enemyRect)) {
          enemies.remove(enemy);
          lives--;
          if (lives <= 0) {
            gameOver = true;
            if (score > highScore) {
              highScore = score;
              _saveHighScore();
            }
          }
          break;
        }
      }
    });
  }

  void movePlayer(double dx) {
    if (!gameOver) {
      setState(() {
        playerX += dx;
        playerX = playerX.clamp(0.1, 0.9);
      });
    }
  }

  @override
  void dispose() {
    gameLoop?.cancel();
    enemySpawner?.cancel();
    starSpawner?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Space Shooter 🚀'),
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Colors.black87],
          ),
        ),
        child: GestureDetector(
          onHorizontalDragUpdate: (details) => movePlayer(details.delta.dx / 300),
          onTap: shoot,
          child: Stack(
            children: [
              CustomPaint(
                size: MediaQuery.of(context).size,
                painter: SpaceShooterPainter(stars: stars, bullets: bullets, enemies: enemies),
              ),
              Positioned(
                left: playerX * MediaQuery.of(context).size.width - playerWidth / 2,
                top: playerY * MediaQuery.of(context).size.height - playerHeight / 2,
                child: const Icon(Icons.rocket, size: 50, color: Colors.blue),
              ),
              Positioned(
                top: 20,
                left: 20,
                child: Text(
                  'Score: $score 🌟',
                  style: GoogleFonts.poppins(
                      color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: Text(
                  'High Score: $highScore 🏆',
                  style: GoogleFonts.poppins(
                      color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
              Positioned(
                top: 50,
                left: 20,
                child: Text(
                  'Lives: $lives ❤️',
                  style: GoogleFonts.poppins(
                      color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
              if (gameOver)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
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
                              color: Colors.red, fontSize: 40, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Score: $score 🌟',
                          style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 30, fontWeight: FontWeight.w600),
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

class SpaceShooterPainter extends CustomPainter {
  final List<Offset> stars;
  final List<Map<String, double>> bullets;
  final List<Map<String, double>> enemies;

  SpaceShooterPainter({required this.stars, required this.bullets, required this.enemies});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw stars
    final starPaint = Paint()..color = Colors.white;
    for (var star in stars) {
      canvas.drawCircle(
        Offset(star.dx * size.width, star.dy * size.height),
        2,
        starPaint,
      );
    }

    // Draw bullets
    final bulletPaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;
    for (var bullet in bullets) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            bullet['x']! * size.width - 5,
            bullet['y']! * size.height - 10,
            10,
            20,
          ),
          const Radius.circular(4),
        ),
        bulletPaint,
      );
    }

    // Draw enemies
    final enemyPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    for (var enemy in enemies) {
      canvas.drawCircle(
        Offset(
          enemy['x']! * size.width,
          enemy['y']! * size.height,
        ),
        20,
        enemyPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
