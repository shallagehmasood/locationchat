import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/socket_service.dart';

class ChatWidget extends StatefulWidget {
  @override
  _ChatWidgetState createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SocketService>(
      builder: (context, socketService, child) {
        final messages = socketService.chatMessages;
        
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });

        return Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              // هدر چت
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.chat, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      '💬 چت بازی',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // لیست پیام‌ها
              Expanded(
                child: Container(
                  color: Colors.grey[50],
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessageItem(messages[index]);
                    },
                  ),
                ),
              ),
              
              // input چت
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'پیام خود را بنویسید...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        maxLength: 200,
                        onSubmitted: (_) => _sendMessage(socketService),
                      ),
                    ),
                    SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: IconButton(
                        icon: Icon(Icons.send, color: Colors.white),
                        onPressed: () => _sendMessage(socketService),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageItem(ChatMessage message) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.isOwnMessage) Expanded(child: SizedBox()),
          Flexible(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getMessageColor(message),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.playerName,
                    style: TextStyle(
                      fontSize: 12,
                      color: _getTextColor(message),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    message.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: _getTextColor(message),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    message.formattedTime,
                    style: TextStyle(
                      fontSize: 10,
                      color: _getTextColor(message).withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!message.isOwnMessage) Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  Color _getMessageColor(ChatMessage message) {
    if (message.isSystem) return Colors.orange;
    if (message.isOwnMessage) return Colors.blue;
    return Colors.white;
  }

  Color _getTextColor(ChatMessage message) {
    if (message.isSystem || message.isOwnMessage) return Colors.white;
    return Colors.black87;
  }

  void _sendMessage(SocketService socketService) {
    final message = _messageController.text.trim();
    if (message.isNotEmpty && socketService.isConnected) {
      socketService.sendMessage(message);
      _messageController.clear();
    }
  }
}