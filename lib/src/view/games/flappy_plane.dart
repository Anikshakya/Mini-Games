import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MaterialApp(
    home: FlappyBirdScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class FlappyBirdScreen extends StatefulWidget {
  const FlappyBirdScreen({super.key});

  @override
  State<FlappyBirdScreen> createState() => _FlappyBirdScreenState();
}

class _FlappyBirdScreenState extends State<FlappyBirdScreen> {
  // Game constants
  static const double gravity = 0.002;
  static const double jumpForce = -0.035; // Reduced for less jump height
  static const double pipeWidth = 0.2;
  static const double basePipeGapSize = 0.35; // Base gap size
  static const double birdSize = 0.12;
  static const double pipeSpeed = 0.01;
  static const double pipeSpawnInterval = 1500; // milliseconds
  static const double maxVelocity = 0.1;

  // Game state
  double birdY = 0;
  double birdVelocity = 0;
  List<Pipe> pipes = [];
  Timer? gameTimer;
  Timer? pipeTimer;
  int score = 0;
  int highScore = 0;
  bool gameStarted = false;
  bool gameOver = false;
  bool isPaused = false;

  @override
  void initState() {
    super.initState();
    loadHighScore();
  }

  Future<void> loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = prefs.getInt('flappyHighScore') ?? 0;
    });
  }

  Future<void> saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('flappyHighScore', highScore);
  }

  void startGame() {
    setState(() {
      gameStarted = true;
      gameOver = false;
      isPaused = false;
      score = 0;
      birdY = 0;
      birdVelocity = 0;
      pipes.clear();
      pipes.add(Pipe(
        x: 1.5,
        topHeight: 0.5,
        gapY: 0.0,
        gapSize: basePipeGapSize,
        passed: false,
      ));
    });

    gameTimer?.cancel();
    pipeTimer?.cancel();

    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!gameOver && !isPaused) {
        updateGame();
      }
    });

    pipeTimer = Timer.periodic(Duration(milliseconds: pipeSpawnInterval.toInt()), (_) {
      if (!gameOver && !isPaused) {
        addPipe();
      }
    });
  }

  void updateGame() {
    setState(() {
      birdVelocity = (birdVelocity + gravity).clamp(-maxVelocity, maxVelocity);
      birdY += birdVelocity;

      pipes = pipes
          .map((pipe) => Pipe(
                x: pipe.x - pipeSpeed,
                topHeight: pipe.topHeight,
                gapY: pipe.gapY,
                gapSize: pipe.gapSize,
                passed: pipe.passed,
              ))
          .where((pipe) => pipe.x > -pipeWidth)
          .toList();

      for (var pipe in pipes) {
        if (!pipe.passed && pipe.x + pipeWidth / 2 < 0) {
          pipe.passed = true;
          score++;
          if (score > highScore) {
            highScore = score;
            saveHighScore();
          }
        }
      }

      if (birdY > 1 - birdSize / 2 || birdY < -1 + birdSize / 2) {
        endGame();
        return;
      }

      for (final pipe in pipes) {
        if (checkCollision(pipe)) {
          endGame();
          return;
        }
      }
    });
  }

  bool checkCollision(Pipe pipe) {
    final birdWidth = birdSize;
    final birdHeight = birdSize;
    final birdLeft = -birdWidth / 2;
    final birdRight = birdWidth / 2;
    final birdTop = birdY - birdHeight / 2;
    final birdBottom = birdY + birdHeight / 2;

    final pipeLeft = (pipe.x * 2 - 1) - pipeWidth / 2;
    final pipeRight = (pipe.x * 2 - 1) + pipeWidth / 2;

    if (birdRight > pipeLeft && birdLeft < pipeRight) {
      final gapTop = -1 + 2 * pipe.topHeight;
      final gapBottom = gapTop + 2 * pipe.gapSize;
      if (birdBottom <= gapTop || birdTop >= gapBottom) {
        return true;
      }
      return false;
    }
    return false;
  }

  void addPipe() {
    final topHeight = 0.02 + (0.48 * Random().nextDouble());
    final gapSize = 0.1 + (0.4 * Random().nextDouble());
    final gapY = topHeight - 1 + gapSize / 2;
    final bottomHeight = 1 - topHeight - gapSize;

    if (topHeight < 0.2 || topHeight > 0.8 || bottomHeight < 0.2) {
      return;
    }
    setState(() {
      pipes.add(Pipe(
        x: 1.5,
        topHeight: topHeight,
        gapY: gapY,
        gapSize:  gapSize,
        passed: false,
      ));
    });
  }

  void jump() {
    if (!gameStarted) {
      startGame();
    } else if (gameOver) {
      startGame();
    } else if (!isPaused) {
      setState(() {
        birdVelocity = jumpForce;
      });
    }
  }

  void togglePause() {
    setState(() {
      isPaused = !isPaused;
    });
  }

  void endGame() {
    gameOver = true;
    gameTimer?.cancel();
    pipeTimer?.cancel();
    showGameOverDialog();
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Game Over'),
        content: Text('Your score: $score\nHigh score: $highScore'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              startGame();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    pipeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        if (gameStarted && !gameOver) {
          togglePause();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.blue.shade200,
        body: GestureDetector(
          onTap: jump,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.blue.shade400,
                      Colors.blue.shade200,
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                child: CustomPaint(
                  painter: CloudPainter(),
                ),
              ),
              ...pipes.map((pipe) {
                return Stack(
                  children: [
                    Align(
                      alignment: Alignment(pipe.x * 2 - 1, -1),
                      child: Container(
                        width: MediaQuery.of(context).size.width * pipeWidth,
                        height: MediaQuery.of(context).size.height * pipe.topHeight,
                        decoration: BoxDecoration(
                          color: Colors.green.shade800,
                          border: Border.all(color: Colors.green.shade900, width: 2),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                        child: CustomPaint(
                          painter: PipePainter(isTop: true),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment(pipe.x * 2 - 1, 1),
                      child: Container(
                        width: MediaQuery.of(context).size.width * pipeWidth,
                        height: MediaQuery.of(context).size.height * (1 - pipe.topHeight - pipe.gapSize),
                        decoration: BoxDecoration(
                          color: Colors.green.shade800,
                          border: Border.all(color: Colors.green.shade900, width: 2),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                        child: CustomPaint(
                          painter: PipePainter(isTop: false),
                        ),
                      ),
                    ),
                  ],
                );
              }),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 100,
                  color: Colors.green.shade700,
                  child: CustomPaint(
                    painter: GroundPainter(),
                  ),
                ),
              ),
              Align(
                alignment: Alignment(0, birdY.clamp(-1.0, 1.0)),
                child: Transform.rotate(
                  angle: birdVelocity * 5,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.yellow,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.arrow_forward_ios, color: Color.fromARGB(255, 212, 161, 83)),
                  ),
                ),
              ),
              Positioned(
                top: 50,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Text(
                      'High Score: $highScore',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 5,
                            color: Colors.black,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Score: $score',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 5,
                            color: Colors.black,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (gameStarted && !gameOver)
                Positioned(
                  top: 30,
                  right: 20,
                  child: IconButton(
                    icon: Icon(
                      isPaused ? Icons.play_arrow : Icons.pause,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: togglePause,
                  ),
                ),
              if (!gameStarted && !gameOver)
                Positioned.fill(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Flappy Bird',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: 5,
                                color: Colors.black,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Tap to start',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            shadows: [
                              Shadow(
                                blurRadius: 5,
                                color: Colors.black,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (isPaused && !gameOver)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: const Center(
                      child: Text(
                        'Paused',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              if (gameOver)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Game Over',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Score: $score',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Tap to restart',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
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

class Pipe {
  final double x;
  final double topHeight;
  final double gapY;
  final double gapSize;
  bool passed;

  Pipe({
    required this.x,
    required this.topHeight,
    required this.gapY,
    required this.gapSize,
    required this.passed,
  });
}

class CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.7);
    final random = Random(42);

    for (int i = 0; i < 10; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height * 0.5;
      final radius = 20 + random.nextDouble() * 30;

      canvas.drawCircle(Offset(x, y), radius, paint);
      canvas.drawCircle(Offset(x + radius * 0.7, y), radius * 0.8, paint);
      canvas.drawCircle(Offset(x - radius * 0.7, y), radius * 0.8, paint);
      canvas.drawCircle(Offset(x, y - radius * 0.5), radius * 0.7, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.green.shade600;
    final path = Path();
    final random = Random(42);

    path.moveTo(0, size.height * 0.5);

    for (double x = 0; x < size.width; x += 5) {
      final y = size.height * 0.5 + random.nextDouble() * 10;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PipePainter extends CustomPainter {
  final bool isTop;

  PipePainter({required this.isTop});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.green.shade600;
    final borderPaint = Paint()
      ..color = Colors.green.shade900
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), borderPaint);

    if (isTop) {
      canvas.drawRect(Rect.fromLTWH(0, size.height - 20, size.width, 20), paint);
      canvas.drawRect(Rect.fromLTWH(0, size.height - 20, size.width, 20), borderPaint);
    } else {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, 20), paint);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, 20), borderPaint);
    }

    final detailPaint = Paint()..color = Colors.green.shade700;
    for (double y = isTop ? 0 : 20; y < size.height - (isTop ? 20 : 0); y += 30) {
      canvas.drawRect(
        Rect.fromLTWH(5, y, size.width - 10, 15),
        detailPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}