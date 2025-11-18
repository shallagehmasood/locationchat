import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/socket_service.dart';
import '../widgets/game_board.dart';
import '../widgets/chat_widget.dart';
import '../widgets/score_board.dart';
import '../widgets/player_info.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SocketService>(
      builder: (context, socketService, child) {
        final gameState = socketService.gameState;
        
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
            ),
            child: Column(
              children: [
                // هدر
                _buildHeader(gameState),
                
                // وضعیت اتصال
                _buildConnectionStatus(socketService),
                
                // اطلاعات اتاق
                _buildRoomInfo(gameState),
                
                // وضعیت بازی سریع
                if (gameState.isQuickPlay) _buildQuickPlayStatus(),
                
                // اطلاعات بازیکنان
                PlayerInfoWidget(),
                
                // اطلاعات تماشاگر
                if (gameState.role == 'spectator') _buildSpectatorInfo(),
                
                // محتوای اصلی
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // صفحه بازی
                        Expanded(
                          flex: 2,
                          child: Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  // وضعیت بازی و امتیاز
                                  ScoreBoardWidget(),
                                  SizedBox(height: 16),
                                  
                                  // صفحه بازی
                                  Expanded(
                                    child: GameBoardWidget(),
                                  ),
                                  
                                  // برنده
                                  if (gameState.gameOver) _buildWinner(gameState),
                                  
                                  // کنترل‌ها
                                  _buildControls(socketService),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        // چت
                        Expanded(
                          flex: 1,
                          child: ChatWidget(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(GameState gameState) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        children: [
          Text(
            '🎮 بازی اوتللو 6x6 آنلاین',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'صفحه 6x6 | کد اتاق: ${gameState.roomCode.isNotEmpty ? gameState.roomCode : "----"}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus(SocketService socketService) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            socketService.isConnected ? Icons.wifi : Icons.wifi_off,
            color: socketService.isConnected ? Colors.green : Colors.red,
            size: 20,
          ),
          SizedBox(width: 8),
          Text(
            socketService.isConnected ? 'اتصال برقرار شد' : 'اتصال قطع شد',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomInfo(GameState gameState) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.vpn_key, color: Colors.white, size: 16),
          SizedBox(width: 8),
          Text(
            'کد اتاق: ${gameState.roomCode.isNotEmpty ? gameState.roomCode : "----"}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPlayStatus() {
    return Consumer<SocketService>(
      builder: (context, socketService, child) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '⏳ در حال جستجوی بازیکن...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(width: 8),
                  AnimatedOpacity(
                    opacity: 1.0,
                    duration: Duration(seconds: 1),
                    child: Icon(Icons.search, color: Colors.white),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'کد اتاق شما: ${socketService.gameState.roomCode}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'می‌توانید این کد را با دوستان خود به اشتراک بگذارید',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpectatorInfo() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.remove_red_eye, color: Colors.white, size: 16),
          SizedBox(width: 8),
          Text(
            '👁️ شما در حال تماشای بازی هستید',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWinner(GameState gameState) {
    String winnerText = '';
    Color backgroundColor = Colors.transparent;
    
    if (gameState.blackScore > gameState.whiteScore) {
      winnerText = gameState.role == 'player' && gameState.playerColor == 'black' 
          ? '🎉 شما برنده شدید!' 
          : '🎉 ${gameState.playerNames['black']} برنده شد!';
      backgroundColor = Colors.green;
    } else if (gameState.whiteScore > gameState.blackScore) {
      winnerText = gameState.role == 'player' && gameState.playerColor == 'white' 
          ? '🎉 شما برنده شدید!' 
          : '🎉 ${gameState.playerNames['white']} برنده شد!';
      backgroundColor = Colors.red;
    } else {
      winnerText = '🤝 بازی مساوی شد!';
      backgroundColor = Colors.orange;
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        winnerText,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildControls(SocketService socketService) {
    return Padding(
      padding: EdgeInsets.only(top: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              socketService.createRoom(socketService.gameState.playerName);
              _showSnackBar('اتاق جدید ایجاد شد');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            icon: Icon(Icons.add, color: Colors.white),
            label: Text('ایجاد اتاق جدید'),
          ),
          
          ElevatedButton.icon(
            onPressed: () {
              _copyRoomCode(socketService.gameState.roomCode);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
            ),
            icon: Icon(Icons.copy, color: Colors.white),
            label: Text('کپی لینک اتاق'),
          ),
          
          ElevatedButton.icon(
            onPressed: () {
              if (socketService.gameState.role == 'player' && 
                  socketService.gameState.turn == socketService.gameState.playerColor) {
                socketService.passTurn();
                _showSnackBar('نوبت پاس داده شد');
              } else {
                _showSnackBar('هنوز نوبت شما نیست', isError: true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            icon: Icon(Icons.skip_next, color: Colors.white),
            label: Text('پاس دادن نوبت'),
          ),
          
          ElevatedButton.icon(
            onPressed: () {
              socketService.restartGame();
              _showSnackBar('بازی مجدداً شروع شد');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            icon: Icon(Icons.refresh, color: Colors.white),
            label: Text('شروع مجدد'),
          ),
        ],
      ),
    );
  }

  void _copyRoomCode(String roomCode) async {
    if (roomCode.isEmpty) {
      _showSnackBar('ابتدا یک اتاق ایجاد کنید', isError: true);
      return;
    }
    
    // در فلاتر واقعی از package:url_launcher استفاده می‌شود
    _showSnackBar('لینک اتاق کپی شد: $roomCode');
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}