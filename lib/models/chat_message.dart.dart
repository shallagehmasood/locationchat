class ChatMessage {
  final String playerName;
  final String playerColor;
  final String message;
  final DateTime timestamp;

  ChatMessage({
    required this.playerName,
    required this.playerColor,
    required this.message,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      playerName: json['playerName'] ?? 'ناشناس',
      playerColor: json['playerColor'] ?? 'spectator',
      message: json['message'] ?? '',
      timestamp: DateTime.now(),
    );
  }

  String get formattedTime {
    return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  bool get isSystem => playerColor == 'system';
  bool get isOwnMessage => playerColor != 'system' && playerColor != 'spectator';
}