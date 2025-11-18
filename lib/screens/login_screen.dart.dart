import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/socket_service.dart';
import 'game_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roomCodeController = TextEditingController();
  bool _isLoading = false;

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _navigateToGame() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => GameScreen()),
    );
  }

  void _joinAsPlayer() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showError('لطفاً نام خود را وارد کنید');
      return;
    }

    setState(() => _isLoading = true);
    
    final socketService = Provider.of<SocketService>(context, listen: false);
    
    final roomCode = _roomCodeController.text.trim();
    if (roomCode.isNotEmpty) {
      // پیوستن به اتاق موجود
      socketService.joinRoom(roomCode, name);
    } else {
      // ایجاد اتاق جدید
      socketService.createRoom(name);
    }
    
    // منتظر اتصال و ایجاد اتاق بمان
    await Future.delayed(Duration(seconds: 2));
    _navigateToGame();
  }

  void _quickPlay() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showError('لطفاً نام خود را وارد کنید');
      return;
    }

    setState(() => _isLoading = true);
    
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.quickPlay(name);
    
    await Future.delayed(Duration(seconds: 2));
    _navigateToGame();
  }

  void _joinAsSpectator() async {
    final name = _nameController.text.trim();
    final roomCode = _roomCodeController.text.trim();
    
    if (name.isEmpty) {
      _showError('لطفاً نام خود را وارد کنید');
      return;
    }
    
    if (roomCode.isEmpty) {
      _showError('برای تماشا کردن باید کد اتاق داشته باشید');
      return;
    }

    setState(() => _isLoading = true);
    
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.joinRoom(roomCode, name, asSpectator: true);
    
    await Future.delayed(Duration(seconds: 2));
    _navigateToGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '🎮 ورود به بازی اوتلو',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 30),
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        TextField(
                          controller: _nameController,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[50],
                            hintText: 'نام خود را وارد کنید',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        TextField(
                          controller: _roomCodeController,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[50],
                            hintText: 'کد اتاق (اختیاری)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 20),
                        if (_isLoading)
                          CircularProgressIndicator()
                        else
                          Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _joinAsPlayer,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    padding: EdgeInsets.symmetric(vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    'بازیکن شو',
                                    style: TextStyle(fontSize: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _quickPlay,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    padding: EdgeInsets.symmetric(vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    '⚡ بازی سریع',
                                    style: TextStyle(fontSize: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _joinAsSpectator,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                    padding: EdgeInsets.symmetric(vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    'تماشاگر شو',
                                    style: TextStyle(fontSize: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}