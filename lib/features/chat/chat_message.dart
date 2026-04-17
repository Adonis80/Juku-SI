/// A single message in the CI chat.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.timestamp,
    this.isLoading = false,
  });

  final String id;
  final ChatRole role;
  final String text;
  final DateTime timestamp;
  final bool isLoading;

  bool get isUser => role == ChatRole.user;
  bool get isAssistant => role == ChatRole.assistant;

  ChatMessage copyWith({String? text, bool? isLoading}) {
    return ChatMessage(
      id: id,
      role: role,
      text: text ?? this.text,
      timestamp: timestamp,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

enum ChatRole { user, assistant }
