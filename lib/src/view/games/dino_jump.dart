import 'dart:math';
import 'package:flutter/material.dart';
import 'package:juju_games/src/app_utils/read_write.dart';

class DinoGame extends StatefulWidget {
  const DinoGame({Key? key}) : super(key: key);

  @override
  State<DinoGame> createState() => _DinoGameState();
}

class _DinoGameState extends State<DinoGame> with SingleTickerProviderStateMixin {
  double dinoY = 0;
  double dinoVelocity = 0;
  double initialGameSpeed = 5;
  double gameSpeed = 5;
  double obstacleX = 300;
  double cloudX = 300;
  double score = 0;
  double highScore = 0;
  bool isJumping = false;
  bool isGameOver = false;
  double dayNightCycle = 0;
  double obstacleWidth = 30;
  double obstacleHeight = 50;
  final Random random = Random();

  late double screenWidth;
  late double screenHeight;
  late double groundHeight;

  final double dinoWidth = 50;
  final double dinoHeight = 50;

  double cloudTop = 100;
  double cloudSize = 50;

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_update);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHighScore();
      _startGame();
    });
  }

  void _loadHighScore() {
    final saved = read("high_score");
    if (saved != "") {
      setState(() {
        highScore = double.tryParse(saved.toString()) ?? 0;
      });
    }
  }

  void _saveHighScore() {
    write("high_score", highScore.toStringAsFixed(1));
  }

  void _startGame() {
    _controller.stop();
    setState(() {
      dinoY = 0;
      dinoVelocity = 0;
      gameSpeed = initialGameSpeed;
      obstacleX = screenWidth + random.nextDouble() * 200;
      cloudX = screenWidth + random.nextDouble() * 300;
      cloudTop = 100 + random.nextDouble() * 100;
      cloudSize = 40 + random.nextDouble() * 30;
      score = 0;
      dayNightCycle = 0;
      isJumping = false;
      isGameOver = false;
    });
    _controller.reset();
    _controller.repeat();
  }

  void _jump() {
    if (!isJumping && !isGameOver) {
      setState(() {
        dinoVelocity = -18;
        isJumping = true;
      });
    } else if (isGameOver) {
      _startGame();
    }
  }

  void _update() {
    if (isGameOver) {
      _controller.stop();
      return;
    }

    setState(() {
      dinoY += dinoVelocity;
      dinoVelocity += 0.8;

      if (dinoY > 0) {
        dinoY = 0;
        dinoVelocity = 0;
        isJumping = false;
      }

      obstacleX -= gameSpeed;
      if (obstacleX < -obstacleWidth) {
        obstacleX = screenWidth + random.nextDouble() * 200;
        obstacleHeight = 30 + random.nextDouble() * 40;
      }

      cloudX -= gameSpeed * 0.5;
      if (cloudX < -cloudSize) {
        cloudX = screenWidth + random.nextDouble() * 500;
        cloudTop = 100 + random.nextDouble() * 100;
        cloudSize = 40 + random.nextDouble() * 30;
      }

      bool obstacleInRange = obstacleX < dinoWidth + 50 && obstacleX + obstacleWidth > 50;
      bool dinoOnGround = dinoY >= -10;
      if (obstacleInRange && dinoOnGround) {
        isGameOver = true;
        highScore = max(highScore, score);
        _saveHighScore();
        _controller.stop();
      }

      score += 0.1;
      gameSpeed = initialGameSpeed + (score / 500);
      dayNightCycle = (dayNightCycle + 0.0005) % 1;
    });
  }

  Color _getSkyColor() {
    if (dayNightCycle < 0.5) {
      return Color.lerp(Colors.lightBlue, Colors.indigo, dayNightCycle * 2)!;
    } else {
      return Color.lerp(Colors.indigo, Colors.lightBlue, (dayNightCycle - 0.5) * 2)!;
    }
  }

  Color _getGroundColor() {
    if (dayNightCycle < 0.5) {
      return Color.lerp(Colors.green, Colors.green[800]!, dayNightCycle * 2)!;
    } else {
      return Color.lerp(Colors.green[800]!, Colors.green, (dayNightCycle - 0.5) * 2)!;
    }
  }

  Widget _buildGameOverDialog() {
    return Dialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.close, size: 60, color: Colors.red),
            const SizedBox(height: 24),
            const Text('Game Over',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            Text('Your Score: ${score.toInt()}',
                style: const TextStyle(fontSize: 20, color: Colors.white70)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startGame();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Restart', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    screenWidth = mediaQuery.size.width;
    screenHeight = mediaQuery.size.height;
    groundHeight = screenHeight * 0.7;

    if (isGameOver) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => _buildGameOverDialog(),
        );
      });
    }

    return Scaffold(
      backgroundColor: _getSkyColor(),
      appBar: AppBar(
        title: Text("Dino Jump"),
        centerTitle: false,
        actions: [
          Row(
            children: [
              Text(
                'Score: ${score.toInt()}',
                style: TextStyle(
                ),
              ),
              SizedBox(width: 10,),
              Text(
                'High Score: ${highScore.toInt()}',
                style: TextStyle(
                ),
              ),
              SizedBox(width: 10,),
            ],
          )
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _jump,
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              child: Container(
                width: screenWidth,
                height: screenHeight - groundHeight,
                color: _getGroundColor(),
              ),
            ),
            Positioned(
              left: cloudX,
              top: cloudTop,
              child: Container(
                width: cloudSize,
                height: cloudSize,
                decoration: BoxDecoration(
                  color: Color.lerp(Colors.white, Colors.grey[800]!, dayNightCycle),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: 50,
              bottom: screenHeight - groundHeight - 10,
              child: Transform.translate(
                offset: Offset(0, dinoY),
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..scale(-1.0, 1.0),
                  child: const Text('🦖', style: TextStyle(fontSize: 45)),
                ),
              ),
            ),
            Positioned(
              left: obstacleX,
              bottom: screenHeight - groundHeight,
              child: Container(
                width: obstacleWidth,
                height: obstacleHeight,
                decoration: BoxDecoration(
                  color: Color.lerp(Colors.brown, Colors.brown[900]!, dayNightCycle),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
