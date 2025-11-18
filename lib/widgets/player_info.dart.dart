import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/socket_service.dart';

class PlayerInfoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SocketService>(
      builder: (context, socketService, child) {
        final gameState = socketService.gameState;
        
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPlayerInfo(
                'بازیکن ۱ (سیاه)',
                gameState.playerNames['black'] ?? 'منتظر...',
                Colors.black87,
                gameState.role == 'player' && gameState.playerColor == 'black',
              ),
              _buildPlayerInfo(
                'بازیکن ۲ (سفید)',
                gameState.playerNames['white'] ?? 'منتظر بازیکن...',
                Colors.grey[100]!,
                gameState.role == 'player' && gameState.playerColor == 'white',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlayerInfo(String title, String name, Color color, bool isMe) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: color == Colors.grey[100] 
                  ? Border.all(color: Colors.grey)
                  : null,
            ),
          ),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (isMe)
                Text(
                  'شما',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}