import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:juju_games/src/app_config/app_theme/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RockPaperScissorsScreen extends StatefulWidget {
  const RockPaperScissorsScreen({super.key});

  @override
  _RockPaperScissorsScreenState createState() => _RockPaperScissorsScreenState();
}

class _RockPaperScissorsScreenState extends State<RockPaperScissorsScreen> {
  String playerChoice = '';
  String computerChoice = '';
  String result = '';
  List<String> options = ['✊', '✋', '✌️'];
  int playerWins = 0;
  int computerWins = 0;
  int highScore = 0;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  void _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = prefs.getInt('rps_high_score') ?? 0;
    });
  }

  void _saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('rps_high_score', highScore);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rock Paper Scissors ✊✋✌️'),
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                result.isNotEmpty ? result : 'Make your move! 🎯',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: result.contains('Win')
                      ? Colors.green[700]
                      : result.contains('Draw')
                          ? Colors.blue[700]
                          : Colors.red,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Computer: ${computerChoice.isNotEmpty ? computerChoice : '❓'}',
                style: GoogleFonts.poppins(
                    fontSize: 40,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge!.color),
              ),
              const SizedBox(height: 20),
              Text(
                'You: ${playerChoice.isNotEmpty ? playerChoice : '❓'}',
                style: GoogleFonts.poppins(
                    fontSize: 40,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge!.color),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'You: $playerWins 🏆',
                    style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge!.color),
                  ),
                  Text(
                    'Computer: $computerWins 🤖',
                    style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge!.color),
                  ),
                ],
              ),
              Text(
                'High Score: $highScore 🏅',
                style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge!.color),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: options.map((option) {
                  return ElevatedButton(
                    onPressed: playerChoice.isEmpty ? () => playGame(option) : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: const CircleBorder(),
                      elevation: 4,
                    ),
                    child: Text(
                      option,
                      style: GoogleFonts.poppins(fontSize: 32),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Play Again'),
                onPressed: resetGame,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void playGame(String choice) {
    if (playerChoice.isNotEmpty) return;

    setState(() {
      playerChoice = choice;
      computerChoice = options[Random().nextInt(3)];
      result = determineWinner(playerChoice, computerChoice);
      if (result == 'You Win!') {
        playerWins++;
        if (playerWins > highScore) {
          highScore = playerWins;
          _saveHighScore();
        }
      } else if (result == 'Computer Wins!') {
        computerWins++;
      }
    });
  }

  String determineWinner(String player, String computer) {
    if (player == computer) {
      return 'Draw!';
    }
    if ((player == '✊' && computer == '✌️') ||
        (player == '✋' && computer == '✊') ||
        (player == '✌️' && computer == '✋')) {
      return 'You Win!';
    }
    return 'Computer Wins!';
  }

  void resetGame() {
    setState(() {
      playerChoice = '';
      computerChoice = '';
      result = '';
    });
  }
}