
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:juju_games/src/app_config/app_theme/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TicTacToeScreen extends StatefulWidget {
  const TicTacToeScreen({super.key});

  @override
  _TicTacToeScreenState createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  List<List<String>> board = List.generate(3, (_) => List.filled(3, ''));
  String currentPlayer = 'X';
  String winner = '';
  bool gameOver = false;
  int xWins = 0;
  int oWins = 0;
  int highScore = 0;
  List<Offset>? winningLine;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  void _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = prefs.getInt('ttt_high_score') ?? 0;
      xWins = prefs.getInt('ttt_x_wins') ?? 0;
      oWins = prefs.getInt('ttt_o_wins') ?? 0;
    });
  }

  void _saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('ttt_high_score', highScore);
    await prefs.setInt('ttt_x_wins', xWins);
    await prefs.setInt('ttt_o_wins', oWins);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic Tac Toe ❎⭕'),
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
                gameOver
                    ? winner.isNotEmpty
                        ? 'Winner: $winner 🏆'
                        : 'Draw! 🤝'
                    : 'Current Player: $currentPlayer 🎮',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: gameOver && winner.isNotEmpty
                      ? Colors.green[700]
                      : Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'X Wins: $xWins ❎',
                    style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge!.color),
                  ),
                  Text(
                    'O Wins: $oWins ⭕',
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
              const SizedBox(height: 20),
              Container(
                width: 300,
                height: 300,
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
                child: Stack(
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: 9,
                      itemBuilder: (context, index) {
                        int row = index ~/ 3;
                        int col = index % 3;
                        return GestureDetector(
                          onTap: () {
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
                                } else if (isBoardFull()) {
                                  gameOver = true;
                                } else {
                                  currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
                                }
                              });
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Theme.of(context).dividerColor),
                              color: Colors.blue[100],
                              gradient: LinearGradient(
                                colors: [Colors.blue[100]!, Colors.blue[50]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                board[row][col],
                                style: GoogleFonts.poppins(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[900]),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    if (winningLine != null)
                      CustomPaint(
                        size: const Size(300, 300),
                        painter: WinningLinePainter(winningLine!),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Reset Game'),
                onPressed: () {
                  setState(() {
                    board = List.generate(3, (_) => List.filled(3, ''));
                    currentPlayer = 'X';
                    winner = '';
                    gameOver = false;
                    winningLine = null;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool checkWinner(int row, int col) {
    // Check row
    if (board[row][0] == currentPlayer &&
        board[row][1] == currentPlayer &&
        board[row][2] == currentPlayer) {
      winningLine = [
        Offset(0, row * 100.0 + 50),
        Offset(300, row * 100.0 + 50),
      ];
      return true;
    }

    // Check column
    if (board[0][col] == currentPlayer &&
        board[1][col] == currentPlayer &&
        board[2][col] == currentPlayer) {
      winningLine = [
        Offset(col * 100.0 + 50, 0),
        Offset(col * 100.0 + 50, 300),
      ];
      return true;
    }

    // Check main diagonal
    if (row == col &&
        board[0][0] == currentPlayer &&
        board[1][1] == currentPlayer &&
        board[2][2] == currentPlayer) {
      winningLine = [const Offset(0, 0), const Offset(300, 300)];
      return true;
    }

    // Check anti-diagonal
    if (row + col == 2 &&
        board[0][2] == currentPlayer &&
        board[1][1] == currentPlayer &&
        board[2][0] == currentPlayer) {
      winningLine = [const Offset(300, 0), const Offset(0, 300)];
      return true;
    }

    return false;
  }

  bool isBoardFull() {
    for (var row in board) {
      for (var cell in row) {
        if (cell.isEmpty) return false;
      }
    }
    return true;
  }
}

class WinningLinePainter extends CustomPainter {
  final List<Offset> winningLine;

  WinningLinePainter(this.winningLine);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(winningLine[0], winningLine[1], paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}