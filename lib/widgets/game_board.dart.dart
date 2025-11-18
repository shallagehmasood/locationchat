import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/socket_service.dart';

class GameBoardWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SocketService>(
      builder: (context, socketService, child) {
        final gameState = socketService.gameState;
        
        return AspectRatio(
          aspectRatio: 1,
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF27ae60),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Color(0xFF2c3e50), width: 3),
            ),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
              ),
              itemCount: 36,
              itemBuilder: (context, index) {
                return _buildCell(context, index, gameState, socketService);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildCell(BuildContext context, int index, GameState gameState, SocketService socketService) {
    final cellColor = gameState.board[index];
    final isClickable = _isCellClickable(index, gameState, socketService);
    
    return GestureDetector(
      onTap: isClickable ? () => socketService.makeMove(index) : null,
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF2ecc71),
          border: Border.all(color: Color(0xFF27ae60), width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          margin: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: cellColor != null ? _getPieceColor(cellColor) : Colors.transparent,
            shape: BoxShape.circle,
            boxShadow: cellColor != null ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: Offset(0, 2),
              )
            ] : null,
          ),
          child: isClickable ? _buildHoverEffect() : null,
        ),
      ),
    );
  }

  bool _isCellClickable(int index, GameState gameState, SocketService socketService) {
    if (!socketService.isConnected || 
        gameState.gameOver || 
        gameState.role != 'player' ||
        gameState.board[index] != null) {
      return false;
    }
    
    return gameState.turn == gameState.playerColor;
  }

  Color _getPieceColor(String color) {
    return color == 'black' ? Color(0xFF2c3e50) : Color(0xFFecf0f1);
  }

  Widget _buildHoverEffect() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
    );
  }
}