import 'package:flutter/foundation.dart';

@immutable
class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final String? connectorName;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.connectorName,
  });

  factory ChatMessage.user(String content) => ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        content: content,
        isUser: true,
        timestamp: DateTime.now(),
      );

  factory ChatMessage.assistant(String content, {String? connectorName}) =>
      ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        content: content,
        isUser: false,
        timestamp: DateTime.now(),
        connectorName: connectorName,
      );
}
