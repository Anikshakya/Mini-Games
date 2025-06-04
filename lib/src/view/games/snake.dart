import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:juju_games/src/app_config/app_theme/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SnakeGameScreen extends StatefulWidget {
  const SnakeGameScreen({super.key});

  @override
  _SnakeGameScreenState createState() => _SnakeGameScreenState();
}

class _SnakeGameScreenState extends State<SnakeGameScreen> {
  static const int gridSize = 20;
  static const int cellSize = 20;
  List<Offset> snake = [const Offset(10, 10)];
  Offset food = const Offset(5, 5);
  Offset direction = const Offset(1, 0);
  Timer? timer;
  int score = 0;
  int highScore = 0;
  bool gameOver = false;
  bool isPaused = false;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    startGame();
  }

  void _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = prefs.getInt('snake_high_score') ?? 0;
    });
  }

  void _saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('snake_high_score', highScore);
  }

  void startGame() {
    setState(() {
      snake = [const Offset(10, 10)];
      direction = const Offset(1, 0);
      score = 0;
      gameOver = false;
      isPaused = false;
      generateFood();
      timer?.cancel();
      timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
        if (!isPaused && !gameOver) {
          moveSnake();
        }
      });
    });
  }

  void generateFood() {
    final random = Random();
    food = Offset(
      random.nextInt(gridSize).toDouble(),
      random.nextInt(gridSize).toDouble(),
    );
    while (snake.contains(food)) {
      food = Offset(
        random.nextInt(gridSize).toDouble(),
        random.nextInt(gridSize).toDouble(),
      );
    }
  }

  void moveSnake() {
    if (gameOver) return;

    setState(() {
      final newHead = Offset(
        (snake.first.dx + direction.dx) % gridSize,
        (snake.first.dy + direction.dy) % gridSize,
      );

      if (snake.contains(newHead)) {
        gameOver = true;
        if (score > highScore) {
          highScore = score;
          _saveHighScore();
        }
        return;
      }

      snake.insert(0, newHead);

      if (newHead == food) {
        score += 10;
        generateFood();
      } else {
        snake.removeLast();
      }
    });
  }

  void changeDirection(Offset newDirection) {
    if (direction.dx != -newDirection.dx || direction.dy != -newDirection.dy) {
      setState(() {
        direction = newDirection;
      });
    }
  }

  void togglePause() {
    setState(() {
      isPaused = !isPaused;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Snake Game 🐍'),
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
          onVerticalDragUpdate: (details) {
            if (details.delta.dy > 0) {
              changeDirection(const Offset(0, 1));
            } else if (details.delta.dy < 0) {
              changeDirection(const Offset(0, -1));
            }
          },
          onHorizontalDragUpdate: (details) {
            if (details.delta.dx > 0) {
              changeDirection(const Offset(1, 0));
            } else if (details.delta.dx < 0) {
              changeDirection(const Offset(-1, 0));
            }
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('Score: $score 🌟',
                        style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodyLarge!.color)),
                    Text('High Score: $highScore 🏆',
                        style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodyLarge!.color)),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: gridSize * cellSize.toDouble(),
                  height: gridSize * cellSize.toDouble(),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CustomPaint(
                    painter: SnakePainter(snake: snake, food: food, gameOver: gameOver),
                  ),
                ),
                const SizedBox(height: 20),
                if (gameOver)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Game Over! 😢',
                          style: GoogleFonts.poppins(
                              fontSize: 28,
                              color: Colors.red,
                              fontWeight: FontWeight.bold),
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
                if (!gameOver)
                  ElevatedButton.icon(
                    icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
                    label: Text(isPaused ? 'Resume' : 'Pause'),
                    onPressed: togglePause,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SnakePainter extends CustomPainter {
  final List<Offset> snake;
  final Offset food;
  final bool gameOver;

  SnakePainter({required this.snake, required this.food, required this.gameOver});

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / 20;

    final foodPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(food.dx * cellSize + cellSize / 2, food.dy * cellSize + cellSize / 2),
      cellSize / 2,
      foodPaint,
    );

    for (int i = 0; i < snake.length; i++) {
      final paint = Paint()
        ..color = i == 0 ? Colors.green[800]! : Colors.green[400]!
        ..style = PaintingStyle.fill;
      canvas.drawRect(
        Rect.fromLTWH(
          snake[i].dx * cellSize,
          snake[i].dy * cellSize,
          cellSize,
          cellSize,
        ),
        paint,
      );
    }

    if (gameOver) {
      final overlayPaint = Paint()
        ..color = Colors.black.withOpacity(0.5)
        ..style = PaintingStyle.fill;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        overlayPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
