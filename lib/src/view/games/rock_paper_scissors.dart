import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RockPaperScissorsScreen extends StatefulWidget {
  const RockPaperScissorsScreen({super.key});

  @override
  State<RockPaperScissorsScreen> createState() => _RockPaperScissorsScreenState();
}

class _RockPaperScissorsScreenState extends State<RockPaperScissorsScreen> {
  String playerChoice = '';
  String computerChoice = '';
  String result = '';
  final List<String> options = ['✊', '✋', '✌️'];
  int playerWins = 0;
  int computerWins = 0;
  int highScore = 0;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = prefs.getInt('rps_high_score') ?? 0;
    });
  }

  Future<void> _saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('rps_high_score', highScore);
  }

  void playGame(String choice) {
    if (playerChoice.isNotEmpty) return;

    setState(() {
      playerChoice = choice;
      computerChoice = options[Random().nextInt(options.length)];
      result = determineWinner(playerChoice, computerChoice);

      if (result == 'You Win! 🎉🎊') {
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
    if (player == computer) return 'Draw!';

    if ((player == '✊' && computer == '✌️') ||
        (player == '✋' && computer == '✊') ||
        (player == '✌️' && computer == '✋')) {
      return 'You Win! 🎉🎊';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final winColor = Colors.green[700];
    final loseColor = Colors.red[700];
    final drawColor = Colors.blue[700];

    Color getResultColor() {
      if (result.contains('Win') && !result.contains('Computer')) return winColor ?? Colors.green;
      if (result.contains('Draw')) return drawColor ?? Colors.blue;
      if (result.contains('Computer Wins')) return loseColor ?? Colors.red;
      return textColor;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Rock Paper Scissors ✊✋✌️"),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                'High Score: $highScore',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Result message
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
              child: Text(
                result.isNotEmpty ? result : 'Make your move!',
                key: ValueKey<String>(result),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: getResultColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Choices display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ChoiceDisplay(label: 'Computer ($computerWins Wins)', choice: computerChoice, color: textColor),
                _ChoiceDisplay(label: 'You ($playerWins Wins)', choice: playerChoice, color: textColor),
              ],
            ),
            const SizedBox(height: 52),

            // Buttons for choices
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: options.map((option) {
                final isDisabled = playerChoice.isNotEmpty;
                return ElevatedButton(
                  onPressed: isDisabled ? null : () => playGame(option),
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                    elevation: 4,
                  ),
                  child: Text(
                    option,
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Play Again Button (animated but doesn't shift layout)
            Visibility(
              visible: playerChoice.isNotEmpty,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: playerChoice.isNotEmpty ? 1.0 : 0.0,
                child: FilledButton.icon(
                  icon: const Icon(Icons.replay),
                  label: const Text('Play Again'),
                  onPressed: resetGame,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(140, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

class _ChoiceDisplay extends StatelessWidget {
  final String label;
  final String choice;
  final Color? color;

  const _ChoiceDisplay({
    required this.label,
    required this.choice,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          choice.isNotEmpty ? choice : '❓',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: color),
        ),
      ],
    );
  }
}
