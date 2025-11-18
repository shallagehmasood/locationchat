class GameState {
  final String roomCode;
  final String playerId;
  final String? playerColor;
  final String playerName;
  final String role;
  final List<String?> board;
  final String turn;
  final bool gameOver;
  final int blackScore;
  final int whiteScore;
  final Map<String, String> playerNames;
  final bool connected;
  final bool isQuickPlay;

  GameState({
    required this.roomCode,
    required this.playerId,
    this.playerColor,
    required this.playerName,
    required this.role,
    required this.board,
    required this.turn,
    required this.gameOver,
    required this.blackScore,
    required this.whiteScore,
    required this.playerNames,
    required this.connected,
    this.isQuickPlay = false,
  });

  GameState copyWith({
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
    return GameState(
      roomCode: roomCode ?? this.roomCode,
      playerId: playerId ?? this.playerId,
      playerColor: playerColor ?? this.playerColor,
      playerName: playerName ?? this.playerName,
      role: role ?? this.role,
      board: board ?? this.board,
      turn: turn ?? this.turn,
      gameOver: gameOver ?? this.gameOver,
      blackScore: blackScore ?? this.blackScore,
      whiteScore: whiteScore ?? this.whiteScore,
      playerNames: playerNames ?? this.playerNames,
      connected: connected ?? this.connected,
      isQuickPlay: isQuickPlay ?? this.isQuickPlay,
    );
  }
}