import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:juju_games/src/app_config/app_theme/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  _MemoryGameScreenState createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  List<String> cardValues = ['🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼'];
  List<String> cards = [];
  List<bool> cardFlips = [];
  int? firstCardIndex;
  int? secondCardIndex;
  int pairsFound = 0;
  bool processing = false;
  int moves = 0;
  int highScore = 0;
  bool gameWon = false;
  Timer? timer;
  int timeLeft = 60;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    initializeGame();
  }

  void _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = prefs.getInt('memory_high_score') ?? 0;
    });
  }

  void _saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('memory_high_score', highScore);
  }

  void initializeGame() {
    setState(() {
      cards = [...cardValues, ...cardValues]..shuffle();
      cardFlips = List.filled(cards.length, false);
      firstCardIndex = null;
      secondCardIndex = null;
      pairsFound = 0;
      processing = false;
      moves = 0;
      gameWon = false;
      timeLeft = 60;
      timer?.cancel();
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          timeLeft--;
          if (timeLeft <= 0 && !gameWon) {
            timer.cancel();
            gameWon = true; // Treat as game over
            if (highScore == 0 || moves < highScore) {
              highScore = moves;
              _saveHighScore();
            }
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Game 🧠'),
        centerTitle: true,
        actions: [
          Obx(() => IconButton(
                icon: Icon(themeController.isDarkMode.value ? Icons.light_mode : Icons.dark_mode),
                onPressed: themeController.toggleTheme,
                tooltip: 'Toggle Theme',
              )),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: initializeGame,
            tooltip: 'New Game',
          ),
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Time Left: $timeLeft s ⏰',
                    style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: timeLeft < 10
                            ? Colors.red
                            : Theme.of(context).textTheme.bodyLarge!.color),
                  ),
                  Text(
                    'Pairs Found: $pairsFound / ${cardValues.length} 🥳',
                    style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge!.color),
                  ),
                  Text(
                    'Moves: $moves 🚶',
                    style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge!.color),
                  ),
                  if (highScore > 0)
                    Text(
                      'Best: $highScore moves 🏆',
                      style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700]),
                    ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => flipCard(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: cardFlips[index]
                              ? [Colors.white, Colors.grey[200]!]
                              : [Colors.blue[700]!, Colors.blue[500]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).dividerColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return ScaleTransition(scale: animation, child: child);
                          },
                          child: Text(
                            key: ValueKey<bool>(cardFlips[index]),
                            cardFlips[index] ? cards[index] : '❓',
                            style: TextStyle(
                              fontSize: 32,
                              color: cardFlips[index]
                                  ? Theme.of(context).textTheme.bodyLarge!.color
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (gameWon || timeLeft <= 0)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
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
                        timeLeft <= 0 ? 'Time’s Up! 😢' : 'Congratulations! 🎉',
                        style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: timeLeft <= 0 ? Colors.red : Colors.green[700]),
                      ),
                      Text(
                        'You won in $moves moves! 🥳',
                        style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodyLarge!.color),
                      ),
                      if (highScore == 0 || moves < highScore)
                        Text(
                          'New best score! 🏆',
                          style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.green[700]),
                        ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Play Again'),
                        onPressed: initializeGame,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void flipCard(int index) {
    if (processing || cardFlips[index] || index == firstCardIndex || timeLeft <= 0) return;

    setState(() {
      cardFlips[index] = true;
      moves++;
    });

    if (firstCardIndex == null) {
      firstCardIndex = index;
    } else {
      secondCardIndex = index;
      processing = true;
      checkForMatch();
    }
  }

  void checkForMatch() {
    if (cards[firstCardIndex!] == cards[secondCardIndex!]) {
      setState(() {
        pairsFound++;
      });
      if (pairsFound == cardValues.length) {
        setState(() {
          gameWon = true;
          timer?.cancel();
          if (highScore == 0 || moves < highScore) {
            highScore = moves;
            _saveHighScore();
          }
        });
      }
      resetSelection();
    } else {
      Future.delayed(const Duration(milliseconds: 1000), () {
        setState(() {
          cardFlips[firstCardIndex!] = false;
          cardFlips[secondCardIndex!] = false;
        });
        resetSelection();
      });
    }
  }

  void resetSelection() {
    setState(() {
      firstCardIndex = null;
      secondCardIndex = null;
      processing = false;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
