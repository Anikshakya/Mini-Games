import 'package:flutter/material.dart';
import 'package:juju_games/src/app_utils/read_write.dart';

class TicTacToeScreen extends StatefulWidget {
  const TicTacToeScreen({super.key});

  @override
  _TicTacToeScreenState createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen>
    with SingleTickerProviderStateMixin {
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

  @override
  void initState() {
    super.initState();
    board = List.generate(3, (_) => List.filled(3, ''));
    _loadHighScore();
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

  /// Loads stored scores from GetStorage
  void _loadHighScore() {
    setState(() {
      highScore = read<int>('ttt_high_score', defaultValue: 0);
      xWins = read<int>('ttt_x_wins', defaultValue: 0);
      oWins = read<int>('ttt_o_wins', defaultValue: 0);
    });
  }

  /// Saves current scores to GetStorage
  void _saveHighScore() {
    write<int>('ttt_high_score', highScore);
    write<int>('ttt_x_wins', xWins);
    write<int>('ttt_o_wins', oWins);
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
          'Tic Tac Toe',
        ),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildScoreCard('❌ Wins', xWins, colorScheme.primary),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: gameOver
                            ? winner.isNotEmpty
                                ? colorScheme.primaryContainer
                                : colorScheme.secondaryContainer
                            : colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        gameOver
                            ? winner.isNotEmpty
                                ? 'Winner: $winner 🏆'
                                : 'Draw! 🤝'
                            : 'Turn: $currentPlayer 🎮',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: gameOver
                              ? winner.isNotEmpty
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onSecondaryContainer
                              : colorScheme.onSurface,
                        ),
                      ),
                    ),
                    _buildScoreCard('⭕ Wins', oWins, colorScheme.secondary),
                  ],
                ),
                const SizedBox(height: 50),
                Center(
                  child: Container(
                    width: boardSize,
                    height: boardSize,
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
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
                                      ? colorScheme.primary.withOpacity(0.3)
                                      : colorScheme.secondary.withOpacity(0.3),
                                  highlightColor:
                                      colorScheme.surfaceTint.withOpacity(0.1),
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
                                        color: colorScheme.outline.withOpacity(0.2),
                                      ),
                                      color: colorScheme.surfaceVariant,
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
                const SizedBox(height: 32),
                Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _resetGame,
                    icon: const Icon(Icons.refresh),
                    label: Text(
                      'New Game',
                      style: theme.textTheme.labelLarge,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ), 
        ),
      ),
    );
  }

  Widget _buildScoreCard(String title, int value, Color color) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            '$value',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
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
          _saveHighScore();
          _lineAnimationController.forward(from: 0);
        } else if (isBoardFull()) {
          winner = '';
          gameOver = true;
          _saveHighScore();
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
