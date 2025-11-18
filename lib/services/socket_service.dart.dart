import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/game_state.dart';
import '../models/chat_message.dart';

class SocketService with ChangeNotifier {
  late IO.Socket _socket;
  GameState _gameState = GameState(
    roomCode: '',
    playerId: '',
    playerName: '',
    role: 'player',
    board: List.filled(36, null),
    turn: 'black',
    gameOver: false,
    blackScore: 2,
    whiteScore: 2,
    playerNames: {'black': '', 'white': ''},
    connected: false,
  );

  final List<ChatMessage> _chatMessages = [];
  final String _serverUrl = 'http://178.63.171.244:8000';

  GameState get gameState => _gameState;
  List<ChatMessage> get chatMessages => _chatMessages;
  bool get isConnected => _gameState.connected;

  SocketService() {
    _initSocket();
  }

  void _initSocket() {
    try {
      _socket = IO.io(
        _serverUrl,
        IO.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .enableAutoConnect()
          .build(),
      );

      _setupEventListeners();
      _socket.connect();
    } catch (e) {
      if (kDebugMode) {
        print('Socket initialization error: $e');
      }
    }
  }

  void _setupEventListeners() {
    _socket.onConnect((_) {
      _updateGameState(connected: true);
      if (kDebugMode) {
        print('Connected to server');
      }
    });

    _socket.onDisconnect((_) {
      _updateGameState(connected: false);
    });

    _socket.on('roomCreated', (data) {
      _handleRoomCreated(data);
    });

    _socket.on('roomJoined', (data) {
      _handleRoomJoined(data);
    });

    _socket.on('quickPlayWaiting', (data) {
      _handleQuickPlayWaiting(data);
    });

    _socket.on('quickPlayMatched', (data) {
      _handleQuickPlayMatched(data);
    });

    _socket.on('joinedAsSpectator', (data) {
      _handleJoinedAsSpectator(data);
    });

    _socket.on('playerJoined', (data) {
      _handlePlayerJoined(data);
    });

    _socket.on('gameStateUpdated', (data) {
      _handleGameStateUpdated(data);
    });

    _socket.on('moveMade', (data) {
      _handleMoveMade(data);
    });

    _socket.on('turnPassed', (data) {
      _handleTurnPassed(data);
    });

    _socket.on('gameOver', (data) {
      _handleGameOver(data);
    });

    _socket.on('newMessage', (data) {
      _handleNewMessage(data);
    });

    _socket.on('error', (data) {
      if (kDebugMode) {
        print('Socket error: $data');
      }
    });
  }

  void _updateGameState({
    String? roomCode,
    String? playerId,
    String? playerColor,
    String? playerName,
    String? role,
    List<String?>? board,
    String? turn,
    bool? gameOver,
    int? blackScore,
    int? whiteScore,
    Map<String, String>? playerNames,
    bool? connected,
    bool? isQuickPlay,
  }) {
    _gameState = _gameState.copyWith(
      roomCode: roomCode,
      playerId: playerId,
      playerColor: playerColor,
      playerName: playerName,
      role: role,
      board: board,
      turn: turn,
      gameOver: gameOver,
      blackScore: blackScore,
      whiteScore: whiteScore,
      playerNames: playerNames,
      connected: connected,
      isQuickPlay: isQuickPlay,
    );
    notifyListeners();
  }

  void _handleRoomCreated(data) {
    _updateGameState(
      roomCode: data['roomCode'],
      playerId: data['playerId'],
      playerColor: data['playerColor'],
      playerName: data['playerName'],
      connected: true,
    );
    _addSystemMessage('اتاق بازی با کد ${data['roomCode']} ایجاد شد');
  }

  void _handleRoomJoined(data) {
    _updateGameState(
      roomCode: data['roomCode'],
      playerId: data['playerId'],
      playerColor: data['playerColor'],
      playerName: data['playerName'],
      connected: true,
    );
    
    if (data['gameState'] != null) {
      _handleGameStateUpdated(data['gameState']);
    }
    
    if (data['chatHistory'] != null) {
      _chatMessages.clear();
      for (var msg in data['chatHistory']) {
        _chatMessages.add(ChatMessage.fromJson(msg));
      }
    }
    
    _addSystemMessage('شما به عنوان بازیکن سفید به بازی پیوستید');
  }

  void _handleQuickPlayWaiting(data) {
    _handleRoomCreated(data);
    _updateGameState(isQuickPlay: true);
    _addSystemMessage('در حال جستجوی بازیکن...');
  }

  void _handleQuickPlayMatched(data) {
    _handleRoomJoined(data);
    _updateGameState(isQuickPlay: false);
    _addSystemMessage('بازی سریع: شما به عنوان بازیکن سفید به بازی پیوستید');
  }

  void _handleJoinedAsSpectator(data) {
    _updateGameState(
      roomCode: data['roomCode'],
      playerId: data['playerId'],
      playerName: data['playerName'],
      role: 'spectator',
      connected: true,
    );
    
    if (data['gameState'] != null) {
      _handleGameStateUpdated(data['gameState']);
    }
    
    if (data['chatHistory'] != null) {
      _chatMessages.clear();
      for (var msg in data['chatHistory']) {
        _chatMessages.add(ChatMessage.fromJson(msg));
      }
    }
    
    _addSystemMessage('شما به عنوان تماشاگر به بازی پیوستید');
  }

  void _handlePlayerJoined(data) {
    _updateGameState(
      playerNames: {
        'black': _gameState.playerNames['black']!,
        'white': data['playerName'],
      },
    );
    _addSystemMessage('${data['playerName']} به بازی پیوست!');
  }

  void _handleGameStateUpdated(data) {
    _updateGameState(
      board: List<String?>.from(data['board']),
      turn: data['turn'],
      gameOver: data['gameOver'],
      playerNames: Map<String, String>.from(data['playerNames']),
    );
    _calculateScores();
  }

  void _handleMoveMade(data) {
    // اعمال حرکت روی صفحه
    final newBoard = List<String?>.from(_gameState.board);
    newBoard[data['index']] = data['color'];
    
    for (var flipIndex in data['flips']) {
      newBoard[flipIndex] = data['color'];
    }
    
    _updateGameState(
      board: newBoard,
      turn: data['newTurn'],
    );
    _calculateScores();
    
    _addSystemMessage('${data['playerName']} حرکت خود را انجام داد');
  }

  void _handleTurnPassed(data) {
    _updateGameState(turn: data['newTurn']);
    _addSystemMessage('${data['playerName']} نوبت خود را پاس داد');
  }

  void _handleGameOver(data) {
    _updateGameState(gameOver: true);
    _addSystemMessage('بازی پایان یافت. برنده: ${data['winner']}');
  }

  void _handleNewMessage(data) {
    _chatMessages.add(ChatMessage.fromJson(data));
    notifyListeners();
  }

  void _addSystemMessage(String message) {
    _chatMessages.add(ChatMessage(
      playerName: 'سیستم',
      playerColor: 'system',
      message: message,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  void _calculateScores() {
    int black = 0, white = 0;
    for (var cell in _gameState.board) {
      if (cell == 'black') black++;
      if (cell == 'white') white++;
    }
    _updateGameState(blackScore: black, whiteScore: white);
  }

  // متدهای عمومی برای ارسال events
  void createRoom(String playerName) {
    _socket.emit('createRoom', {'playerName': playerName});
  }

  void joinRoom(String roomCode, String playerName, {bool asSpectator = false}) {
    _socket.emit('joinRoom', {
      'roomCode': roomCode,
      'playerName': playerName,
      'asSpectator': asSpectator,
    });
  }

  void quickPlay(String playerName) {
    _socket.emit('quickPlay', {'playerName': playerName});
  }

  void makeMove(int index) {
    if (_gameState.playerColor != null) {
      _socket.emit('makeMove', {
        'roomCode': _gameState.roomCode,
        'index': index,
        'color': _gameState.playerColor,
      });
    }
  }

  void passTurn() {
    if (_gameState.playerColor != null) {
      _socket.emit('passTurn', {
        'roomCode': _gameState.roomCode,
        'color': _gameState.playerColor,
      });
    }
  }

  void sendMessage(String message) {
    _socket.emit('sendMessage', {
      'roomCode': _gameState.roomCode,
      'message': message,
      'playerName': _gameState.playerName,
      'playerColor': _gameState.role == 'player' ? _gameState.playerColor : 'spectator',
    });
  }

  void restartGame() {
    _socket.emit('restartGame', _gameState.roomCode);
  }

  @override
  void dispose() {
    _socket.disconnect();
    super.dispose();
  }
}