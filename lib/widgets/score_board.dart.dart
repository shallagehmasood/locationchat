import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/socket_service.dart';

class ScoreBoardWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SocketService>(
      builder: (context, socketService, child) {
        final gameState = socketService.gameState;
        
        return Column(
          children: [
            // امتیازات
            Row(
              children: [
                Expanded(
                  child: _buildScoreCard(
                    '⚫ ${gameState.playerNames['black'] ?? 'سیاه'}',
                    gameState.blackScore,
                    Colors.black87,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildScoreCard(
                    '⚪ ${gameState.playerNames['white'] ?? 'سفید'}',
                    gameState.whiteScore,
                    Colors.grey[100]!,
                    isWhite: true,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // نشانگر نوبت
            _buildTurnIndicator(gameState),
          ],
        );
      },
    );
  }

  Widget _buildScoreCard(String title, int score, Color color, {bool isWhite = false}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isWhite ? Colors.grey[800] : color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isWhite ? Colors.grey : color,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: isWhite ? Colors.black : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            score.toString(),
            style: TextStyle(
              color: isWhite ? Colors.black : Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTurnIndicator(GameState gameState) {
    final isBlackTurn = gameState.turn == 'black';
    final isMyTurn = gameState.role == 'player' && gameState.turn == gameState.playerColor;
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isBlackTurn ? Colors.black87 : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isBlackTurn ? Icons.circle : Icons.circle_outlined,
            color: isBlackTurn ? Colors.white : Colors.black87,
          ),
          SizedBox(width: 8),
          Text(
            isBlackTurn ? '⚫ نوبت: سیاه' : '⚪ نوبت: سفید',
            style: TextStyle(
              color: isBlackTurn ? Colors.white : Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isMyTurn) ...[
            SizedBox(width: 8),
            Icon(
              Icons.emoji_events,
              color: isBlackTurn ? Colors.yellow : Colors.amber,
            ),
          ],
        ],
      ),
    );
  }
}