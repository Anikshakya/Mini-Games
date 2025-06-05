import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SnakeGameScreen extends StatefulWidget {
  const SnakeGameScreen({super.key});

  @override
  State<SnakeGameScreen> createState() => _SnakeGameScreenState();
}

class _SnakeGameScreenState extends State<SnakeGameScreen> {
  static const int gridSize = 20;
  List<Offset> snake = [const Offset(10, 10)];
  Offset food = const Offset(5, 5);
  Offset direction = const Offset(1, 0);
  Timer? timer;
  int score = 0;
  int normalHighScore = 0;
  int hardHighScore = 0;
  bool gameOver = false;
  bool isPaused = false;
  String difficulty = "Normal";

  @override
  void initState() {
    super.initState();
    _loadHighScores();
    startGame();
  }

  void _loadHighScores() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      normalHighScore = prefs.getInt('snake_high_score_normal') ?? 0;
      hardHighScore = prefs.getInt('snake_high_score_hard') ?? 0;
    });
  }

  void _saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    if (difficulty == "Hard") {
      await prefs.setInt('snake_high_score_hard', hardHighScore);
    } else {
      await prefs.setInt('snake_high_score_normal', normalHighScore);
    }
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
      int speed = difficulty == "Hard" ? 100 : 200;
      timer = Timer.periodic(Duration(milliseconds: speed), (timer) {
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
        if (difficulty == "Hard") {
          if (score > hardHighScore) {
            hardHighScore = score;
            _saveHighScore();
          }
        } else {
          if (score > normalHighScore) {
            normalHighScore = score;
            _saveHighScore();
          }
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

  void setDifficulty(String newDifficulty) {
    if (difficulty != newDifficulty) {
      setState(() {
        difficulty = newDifficulty;
        startGame();
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final availableHeight = screenHeight - kToolbarHeight - MediaQuery.of(context).padding.top - 60;
    final cellSize = min(screenWidth, availableHeight) / gridSize;
    final boardSize = cellSize * gridSize;

    final highScore = difficulty == "Hard" ? hardHighScore : normalHighScore;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Snake"),
        centerTitle: false,
        actions: [
          Row(
            children: [
              Text('Score: $score'),
              const SizedBox(width: 10),
              Text('High Score: $highScore'),
              const SizedBox(width: 10),
            ],
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
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
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: boardSize,
                      height: boardSize,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CustomPaint(
                          painter: SnakePainter(
                            snake: snake,
                            food: food,
                            gameOver: gameOver,
                            cellSize: cellSize,
                          ),
                        ),
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
                              color: Colors.black.withValues(alpha: 0.2),
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
                                fontWeight: FontWeight.bold,
                              ),
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
                  ],
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: togglePause,
                      icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
                    ),
                    const SizedBox(width: 4),
                    ChoiceChip(
                      label: const Text("Normal"),
                      selected: difficulty == "Normal",
                      onSelected: (_) => setDifficulty("Normal"),
                    ),
                    const SizedBox(width: 4),
                    ChoiceChip(
                      label: const Text("Hard"),
                      selected: difficulty == "Hard",
                      onSelected: (_) => setDifficulty("Hard"),
                    ),
                  ],
                ),
              ),
            ],
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
  final double cellSize;

  SnakePainter({
    required this.snake,
    required this.food,
    required this.gameOver,
    required this.cellSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final foodPaint = Paint()..color = Colors.red;
    canvas.drawCircle(
      Offset(food.dx * cellSize + cellSize / 2, food.dy * cellSize + cellSize / 2),
      cellSize / 2,
      foodPaint,
    );

    for (int i = 0; i < snake.length; i++) {
      final paint = Paint()
        ..color = i == 0 ? Colors.green[800]! : Colors.green[400]!;
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
        ..color = Colors.black.withValues(alpha: 0.5)
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), overlayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
