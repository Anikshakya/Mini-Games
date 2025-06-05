import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RockPaperScissorsScreen extends StatefulWidget {
  const RockPaperScissorsScreen({super.key});

  @override
  State<RockPaperScissorsScreen> createState() => _RockPaperScissorsScreenState();
}

class _RockPaperScissorsScreenState extends State<RockPaperScissorsScreen>
    with SingleTickerProviderStateMixin {
  String playerChoice = '';
  String computerChoice = '';
  String result = '';
  String readyMessage = '';
  final List<String> options = ['✊', '✋', '✌️'];
  int playerWins = 0;
  int computerWins = 0;
  int highScore = 0;

  late AnimationController _controller;
  late Animation<double> _animation;

  bool showResult = false;
  Timer? _readyTimer;

  @override
  void initState() {
    super.initState();
    _loadHighScore();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 300), () {
          setState(() {
            showResult = true;
          });
          if (result.contains('You Win')) {
            playerWins++;
            if (playerWins > highScore) {
              highScore = playerWins;
              _saveHighScore();
            }
          } else if (result.contains('Computer Wins')) {
            computerWins++;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _readyTimer?.cancel();
    super.dispose();
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

    _readyTimer?.cancel();

    final computer = options[Random().nextInt(options.length)];
    setState(() {
      playerChoice = choice;
      computerChoice = computer;
      result = determineWinner(choice, computer);
      showResult = false;
      readyMessage = '';
    });

    List<String> readyWords = ["Rock", "Paper", "Sissors", "Shoot!!"];
    int index = 0;
    _readyTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (index < readyWords.length) {
        setState(() {
          readyMessage = readyWords[index];
        });
        index++;
      } else {
        timer.cancel();
        setState(() {
          readyMessage = '';
        });
        _controller.forward(from: 0);
      }
    });
  }

  String determineWinner(String player, String computer) {
    if (player == computer) return 'Draw! 🤝';

    if ((player == '✊' && computer == '✌️') ||
        (player == '✋' && computer == '✊') ||
        (player == '✌️' && computer == '✋')) {
      return 'You Win! 🎉🎊';
    }
    return 'Computer Wins! 💻👑';
  }

  void resetGame() {
    _readyTimer?.cancel();
    setState(() {
      playerChoice = '';
      computerChoice = '';
      result = '';
      readyMessage = '';
      showResult = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;

    Color getResultColor() {
      if (result.contains('You Win')) return Colors.green;
      if (result.contains('Draw')) return Colors.blue;
      if (result.contains('Computer Wins')) return Colors.red;
      return textColor;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Rock Paper Scissors ✊✋✌️", style: TextStyle(fontSize: 16)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(child: Text('High Score: $highScore')),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                readyMessage.isNotEmpty
                    ? readyMessage
                    : (showResult ? result : 'Get Ready...'),
                key: ValueKey<String>(readyMessage + result + showResult.toString()),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: getResultColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (playerChoice.isNotEmpty && computerChoice.isNotEmpty)
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, _) {
                        double slide = (1 - _animation.value) * 100;
                        if (_readyTimer!.isActive != true ) {
                          // During animation - show both moving toward center
                          return Stack(
                            children: [
                              Positioned(
                                left: MediaQuery.of(context).size.width / 2 - 100 - slide,
                                child: Text(
                                  computerChoice,
                                  style: const TextStyle(fontSize: 48),
                                ),
                              ),
                              Positioned(
                                right: MediaQuery.of(context).size.width / 2 - 100 - slide,
                                child: Text(
                                  playerChoice,
                                  style: const TextStyle(fontSize: 48),
                                ),
                              ),
                            ],
                          );
                        } else {
                          return const SizedBox();
                        }
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ChoiceDisplay(
                  label: 'Computer ($computerWins Wins)',
                  choice: computerChoice,
                  color: textColor,
                ),
                _ChoiceDisplay(
                  label: 'You ($playerWins Wins)',
                  choice: playerChoice,
                  color: textColor,
                ),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: options.map((option) {
                final isSelected = option == playerChoice;

                return ElevatedButton(
                  onPressed: playerChoice.isEmpty ? () => playGame(option) : null,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                    elevation: isSelected ? 8 : 4,
                    backgroundColor: isSelected ? Colors.amber : null,
                    side: isSelected ? const BorderSide(color: Colors.orange, width: 3) : null,
                  ),
                  child: Text(
                    option,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.black : null,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}