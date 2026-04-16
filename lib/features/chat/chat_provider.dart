import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../connectors/claude_api_connector.dart';
import '../../core/si_context_manager.dart';
import 'chat_message.dart';

const _kSystemPrompt = '''You are SI — Mission Control. A personal AI command centre powered by Claude.
You help orchestrate tasks across tools and LLMs. Be concise and precise.
The SI context below shows current state and recent activity.''';

class ChatNotifier extends AsyncNotifier<List<ChatMessage>> {
  final _connector = ClaudeApiConnector();

  @override
  Future<List<ChatMessage>> build() async => const [];

  Future<void> sendMessage(String text) async {
    final messages = state.valueOrNull ?? const [];
    final userMsg = ChatMessage.user(text);
    state = AsyncValue.data([...messages, userMsg]);

    try {
      final context = await ref.read(siContextProvider.future);
      final systemContext = '$_kSystemPrompt\n\n## SI Context\n$context';
      final response =
          await _connector.sendMessage(systemContext, text);
      final assistantMsg =
          ChatMessage.assistant(response, connectorName: _connector.name);
      state = AsyncValue.data([...messages, userMsg, assistantMsg]);
      await ref
          .read(siContextProvider.notifier)
          .appendExchange(text, response);
    } catch (e) {
      final errMsg = ChatMessage.assistant('Error: $e');
      state = AsyncValue.data([...messages, userMsg, errMsg]);
    }
  }
}

final chatProvider =
    AsyncNotifierProvider<ChatNotifier, List<ChatMessage>>(ChatNotifier.new);
