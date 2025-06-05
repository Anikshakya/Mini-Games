import 'package:flutter/material.dart';
import 'package:juju_games/src/app_config/app_theme/app_theme.dart';

class TicTacToeScreen extends StatefulWidget {
  const TicTacToeScreen({super.key});

  @override
  State<TicTacToeScreen> createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> with SingleTickerProviderStateMixin {
  late List<List<String>> board;
  String currentPlayer = 'X';
  String winner = '';
  bool gameOver = false;
  int xWins = 0;
  int oWins = 0;
  int highScore = 0;
  List<Offset>? winningLine;
  late AnimationController _lineAnimationController;
  late Animation<double> _lineAnimation;
  bool showWinnerBanner = false;

  @override
  void initState() {
    super.initState();
    board = List.generate(3, (_) => List.filled(3, ''));
    _lineAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _lineAnimation = CurvedAnimation(
      parent: _lineAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _lineAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final media = MediaQuery.of(context);
    final boardSize = media.size.width * 0.8; // 90% of width

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tic Tac Toe', style: TextStyle(fontSize: 16)
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _resetGame,
            tooltip: 'New Game',
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 60),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildScoreCard('❌ Wins', xWins.toString(), colorScheme.primary),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: gameOver
                            ? winner.isNotEmpty
                                ? colorScheme.primaryContainer
                                : colorScheme.secondaryContainer
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        gameOver
                            ? winner.isNotEmpty
                                ? 'Winner: $winner 🏆'
                                : 'Draw! 🤝'
                            : 'Turn: $currentPlayer 🎮',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: gameOver
                              ? winner.isNotEmpty
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onSecondaryContainer
                              : colorScheme.onSurface,
                        ),
                      ),
                    ),
                    _buildScoreCard('⭕ Wins', oWins.toString(), colorScheme.secondary),
                  ],
                ),
                const SizedBox(height: 50),
                Center(
                  child: SizedBox(
                    width: boardSize,
                    height: boardSize,
                    child: Stack(
                      children: [
                        GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(8),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1,
                            mainAxisSpacing: 3,
                            crossAxisSpacing: 3,
                          ),
                          itemCount: 9,
                          itemBuilder: (context, index) {
                            int row = index ~/ 3;
                            int col = index % 3;
                            bool isCornerTopLeft = (row == 0 && col == 0);
                            bool isCornerTopRight = (row == 0 && col == 2);
                            bool isCornerBottomRight = (row == 2 && col == 2);
                            bool isCornerBottomLeft = (row == 2 && col == 0);

                            return GestureDetector(
                              onTap: () => _handleTap(row, col),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  splashColor: currentPlayer == 'X'
                                      ? colorScheme.primary.withValues(alpha: 0.3)
                                      : colorScheme.secondary.withValues(alpha: 0.3),
                                  highlightColor:
                                      colorScheme.surfaceTint.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.only(
                                    topLeft: isCornerTopLeft
                                        ? const Radius.circular(12)
                                        : Radius.zero,
                                    topRight: isCornerTopRight
                                        ? const Radius.circular(12)
                                        : Radius.zero,
                                    bottomRight: isCornerBottomRight
                                        ? const Radius.circular(12)
                                        : Radius.zero,
                                    bottomLeft: isCornerBottomLeft
                                        ? const Radius.circular(12)
                                        : Radius.zero,
                                  ),
                                  onTap: () => _handleTap(row, col),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: colorScheme.outline.withValues(alpha: 0.2),
                                      ),
                                      color: colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.only(
                                        topLeft: isCornerTopLeft
                                            ? const Radius.circular(12)
                                            : Radius.zero,
                                        topRight: isCornerTopRight
                                            ? const Radius.circular(12)
                                            : Radius.zero,
                                        bottomRight: isCornerBottomRight
                                            ? const Radius.circular(12)
                                            : Radius.zero,
                                        bottomLeft: isCornerBottomLeft
                                            ? const Radius.circular(12)
                                            : Radius.zero,
                                      ),
                                    ),
                                    child: Center(
                                      child: AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 200),
                                        child: Text(
                                          board[row][col],
                                          key: ValueKey<String>(board[row][col]),
                                          style: theme.textTheme.displayMedium?.copyWith(
                                            color: board[row][col] == 'X'
                                                ? colorScheme.primary
                                                : colorScheme.secondary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        if (winningLine != null)
                          AnimatedBuilder(
                            animation: _lineAnimation,
                            builder: (context, child) {
                              return CustomPaint(
                                size: Size(boardSize, boardSize),
                                painter: WinningLinePainter(
                                  winningLine!,
                                  progress: _lineAnimation.value,
                                  color: colorScheme.tertiary,
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                // Winner banner below the board
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(animation),
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: showWinnerBanner
                      ? Column(
                          key: const ValueKey('winner-banner'),
                          children: [
                            const SizedBox(height: 20),
                            Text(
                              winner.isNotEmpty
                                  ? '🎉 $winner Wins!'
                                  : '🤝 It\'s a Draw!',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              icon: const Icon(Icons.replay),
                              label: const Text('Play Again'),
                              onPressed: _resetGame,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(140, 48),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ), 
        ),
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
          color: theme.shadowColor.withValues(alpha: 0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
      border: Border.all(
        color: color.withValues(alpha: 0.15),
        width: 1,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    ),
  );
}



  void _handleTap(int row, int col) {
    if (board[row][col].isEmpty && !gameOver) {
      setState(() {
        board[row][col] = currentPlayer;

        if (checkWinner(row, col)) {
          winner = currentPlayer;
          gameOver = true;
          showWinnerBanner = true;
          if (currentPlayer == 'X') {
            xWins++;
            if (xWins > highScore) {
              highScore = xWins;
            }
          } else {
            oWins++;
            if (oWins > highScore) {
              highScore = oWins;
            }
          }
          _lineAnimationController.forward(from: 0);
        } else if (isBoardFull()) {
          winner = '';
          gameOver = true;
          showWinnerBanner = true;
        } else {
          currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
        }
      });
    }
  }

  bool isBoardFull() {
    for (var row in board) {
      for (var cell in row) {
        if (cell.isEmpty) return false;
      }
    }
    return true;
  }

  bool checkWinner(int row, int col) {
    String player = board[row][col];

    // Check row
    if (board[row].every((cell) => cell == player)) {
      winningLine = [
        Offset(0, row + 0.5),
        Offset(3, row + 0.5),
      ];
      return true;
    }

    // Check column
    if (board.every((r) => r[col] == player)) {
      winningLine = [
        Offset(col + 0.5, 0),
        Offset(col + 0.5, 3),
      ];
      return true;
    }

    // Check diagonal top-left to bottom-right
    if (row == col) {
      if (List.generate(3, (i) => board[i][i]).every((c) => c == player)) {
        winningLine = [
          const Offset(0, 0),
          const Offset(3, 3),
        ];
        return true;
      }
    }

    // Check diagonal top-right to bottom-left
    if (row + col == 2) {
      if (List.generate(3, (i) => board[i][2 - i]).every((c) => c == player)) {
        winningLine = [
          const Offset(3, 0),
          const Offset(0, 3),
        ];
        return true;
      }
    }

    return false;
  }

  void _resetGame() {
    setState(() {
      board = List.generate(3, (_) => List.filled(3, ''));
      currentPlayer = 'X';
      winner = '';
      gameOver = false;
      winningLine = null;
      showWinnerBanner = false;
      _lineAnimationController.reset();
    });
  }
}

class WinningLinePainter extends CustomPainter {
  final List<Offset> points;
  final double progress;
  final Color color;

  WinningLinePainter(this.points,
      {required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final start = Offset(points[0].dx / 3 * size.width,
        points[0].dy / 3 * size.height);
    final end = Offset(points[1].dx / 3 * size.width,
        points[1].dy / 3 * size.height);

    final currentEnd = Offset.lerp(start, end, progress)!;

    canvas.drawLine(start, currentEnd, paint);
  }

  @override
  bool shouldRepaint(covariant WinningLinePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.points != points;
  }
}
