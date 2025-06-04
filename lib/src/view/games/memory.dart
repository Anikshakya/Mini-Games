import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:juju_games/src/app_config/app_theme/app_theme.dart';
import 'package:juju_games/src/app_utils/read_write.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  _MemoryGameScreenState createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> with TickerProviderStateMixin {
  List<String> cardValues = ['🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼'];
  List<String> cards = [];
  List<bool> cardFlips = [];
  int? firstCardIndex;
  int? secondCardIndex;
  int pairsFound = 0;
  bool processing = false;
  int moves = 0;
  int highScoreMoves = 0;
  int highScoreTime = 0;
  bool gameWon = false;
  Timer? timer;
  int timeLeft = 60;
  AnimationController? _flipAnimationController;
  Animation<double>? _flipAnimation;
  AnimationController? _winAnimationController;
  Animation<double>? _winScaleAnimation;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _loadHighScores();
    _initializeAnimations();
    initializeGame();
  }

  void _initializeAnimations() {
    _flipAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flipAnimation = CurvedAnimation(
      parent: _flipAnimationController!,
      curve: Curves.easeInOutCubic,
    );
    _winAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _winScaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _winAnimationController!, curve: Curves.elasticOut),
    );
    _confettiController = ConfettiController(duration: const Duration(seconds: 4));
  }

  @override
  void dispose() {
    timer?.cancel();
    _flipAnimationController?.dispose();
    _winAnimationController?.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _loadHighScores() async {
    setState(() {
      highScoreMoves = read('memory_high_score_moves') ?? 0;
      highScoreTime = read('memory_high_score_time') ?? 0;
    });
  }

  void _saveHighScores() async {
    write('memory_high_score_moves', highScoreMoves);
    write('memory_high_score_time', highScoreTime);
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
      _winAnimationController?.reset();
      _confettiController.stop();
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          timeLeft--;
          if (timeLeft <= 0 && !gameWon) {
            timer.cancel();
            gameWon = true;
            _saveHighScores();
            _showGameOverDialog();
          }
        });
      });
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return ScaleTransition(
          scale: _winScaleAnimation ?? AlwaysStoppedAnimation(1.0),
          child: AlertDialog(
            backgroundColor: theme.colorScheme.surfaceContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            contentPadding: const EdgeInsets.all(24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeLeft <= 0 ? 'Time’s Up! 😢' : 'Victory! 🎉',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: timeLeft <= 0 ? theme.colorScheme.error : Colors.green[600],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Completed in $moves moves',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Time Left: $timeLeft s',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (highScoreMoves > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      'Best Moves: $highScoreMoves 🏆',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[600],
                      ),
                    ),
                  ),
                if (highScoreTime > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Best Time Left: $highScoreTime s 🏆',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[600],
                      ),
                    ),
                  ),
                if ((highScoreMoves == 0 || moves < highScoreMoves) || (highScoreTime == 0 || timeLeft > highScoreTime))
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      'New Best Score! 🏆',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[600],
                      ),
                    ),
                  ),
              ],
            ),
            actions: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundColor: theme.colorScheme.onPrimaryContainer,
                  elevation: 3,
                ),
                icon: const Icon(Icons.refresh, size: 22),
                label: Text(
                  'Play Again',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  initializeGame();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    final boardSize = media.size.width * 0.98;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Memory Match 🧠',
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: initializeGame,
            tooltip: 'New Game',
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildScoreCard('Time ⏰', '$timeLeft s', timeLeft < 10 ? theme.colorScheme.error : theme.colorScheme.primary),
                        _buildScoreCard('Pairs 🎴', '$pairsFound/${cardValues.length}', theme.colorScheme.secondary),
                        _buildScoreCard('Moves 🚶', '$moves', theme.colorScheme.primary),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: boardSize,
                      height: boardSize,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 1,
                          mainAxisSpacing: 2,
                          crossAxisSpacing: 2,
                        ),
                        itemCount: cards.length,
                        itemBuilder: (context, index) {
                          bool isCornerTopLeft = (index == 0);
                          bool isCornerTopRight = (index == 3);
                          bool isCornerBottomRight = (index == 15);
                          bool isCornerBottomLeft = (index == 12);
    
                          return GestureDetector(
                            onTap: () => flipCard(index),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                splashColor: theme.colorScheme.primary.withOpacity(0.3),
                                highlightColor: theme.colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.only(
                                  topLeft: isCornerTopLeft ? const Radius.circular(12) : Radius.zero,
                                  topRight: isCornerTopRight ? const Radius.circular(12) : Radius.zero,
                                  bottomRight: isCornerBottomRight ? const Radius.circular(12) : Radius.zero,
                                  bottomLeft: isCornerBottomLeft ? const Radius.circular(12) : Radius.zero,
                                ),
                                onTap: () => flipCard(index),
                                child: AnimatedBuilder(
                                  animation: _flipAnimation ?? AlwaysStoppedAnimation(1.0),
                                  builder: (context, child) {
                                    return AnimatedContainer(
                                      duration: const Duration(milliseconds: 400),
                                      curve: Curves.easeInOut,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: cardFlips[index]
                                              ? [theme.colorScheme.surface, theme.colorScheme.surfaceContainer]
                                              : [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.85)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.4)),
                                        borderRadius: BorderRadius.only(
                                          topLeft: isCornerTopLeft ? const Radius.circular(12) : Radius.zero,
                                          topRight: isCornerTopRight ? const Radius.circular(12) : Radius.zero,
                                          bottomRight: isCornerBottomRight ? const Radius.circular(12) : Radius.zero,
                                          bottomLeft: isCornerBottomLeft ? const Radius.circular(12) : Radius.zero,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: theme.colorScheme.shadow.withOpacity(0.15),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: AnimatedSwitcher(
                                          duration: const Duration(milliseconds: 400),
                                          transitionBuilder: (Widget child, Animation<double> animation) {
                                            return RotationTransition(
                                              turns: Tween<double>(begin: 0.0, end: 1.0).animate(animation),
                                              child: ScaleTransition(scale: animation, child: child),
                                            );
                                          },
                                          child: Text(
                                            key: ValueKey<bool>(cardFlips[index]),
                                            cardFlips[index] ? cards[index] : '❓',
                                            style: GoogleFonts.poppins(
                                              fontSize: 40,
                                              fontWeight: FontWeight.w600,
                                              color: cardFlips[index] ? theme.colorScheme.onSurface : theme.colorScheme.onPrimary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
          if (gameWon && timeLeft > 0)
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: pi / 2,
                emissionFrequency: 0.03,
                numberOfParticles: 25,
                maxBlastForce: 120,
                minBlastForce: 30,
                gravity: 0.25,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                  Colors.green[600]!,
                  Colors.yellow[600]!,
                  Colors.purple[400]!,
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(String title, String value, Color color) {
  final theme = Theme.of(context);
  final radius = AppTheme.defaultRadius;
  final padding = AppTheme.defaultPadding;

  return Container(
    padding: EdgeInsets.symmetric(horizontal: padding / 2, vertical: padding / 2.5),
    decoration: BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: theme.shadowColor.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
      border: Border.all(
        color: color.withOpacity(0.15),
        width: 1,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$value',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    ),
  );
}


  void flipCard(int index) {
    if (processing || cardFlips[index] || index == firstCardIndex || timeLeft <= 0) return;

    setState(() {
      cardFlips[index] = true;
      _flipAnimationController?.forward(from: 0);
    });

    if (firstCardIndex == null) {
      firstCardIndex = index;
    } else {
      secondCardIndex = index;
      processing = true;
      setState(() {
        moves++;
      });
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
          if (highScoreMoves == 0 || moves < highScoreMoves) {
            highScoreMoves = moves;
          }
          if (highScoreTime == 0 || timeLeft > highScoreTime) {
            highScoreTime = timeLeft;
          }
          _saveHighScores();
          _winAnimationController?.forward();
          _confettiController.play();
          _showGameOverDialog();
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
      _flipAnimationController?.reset();
    });
  }
}