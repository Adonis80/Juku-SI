import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../connectors/connector_registry.dart';
import '../../connectors/connector_interface.dart';
import 'chat_message.dart';

const _ciSystemPrompt = '''
You are CI — the Central Intelligence of Juku Smart Interface (SI).

You are a personal AI command centre for Dhayan, the founder of Juku, a gamified language learning platform. You orchestrate Claude Code (which builds the app), ChatGPT, Perplexity, Gemini, and other LLMs — routing tasks to the right tool and synthesising results.

Your role:
- Understand what Dhayan needs and route to the best tool
- Give concise, actionable answers
- Proactively surface risks, blockers, and opportunities
- Keep context about the current sprint, tech decisions, and system state

Juku tech stack: Flutter/Dart, Supabase (Postgres), Riverpod, GoRouter.
Current focus: Growth Loop sprints (GL-1 through GL-10+).

Be direct. No preamble. No summaries at the end. Dhayan is a senior engineer who reads diffs.
''';

final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>((
  ref,
) {
  final connector = ref.watch(activeConnectorProvider);
  return ChatNotifier(connector);
});

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  ChatNotifier(this._connector) : super([]) {
    _loadHistory();
  }

  final LlmConnector _connector;
  static const _historyKey = 'ci_chat_history';

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: ChatRole.user,
      text: text.trim(),
      timestamp: DateTime.now(),
    );

    final loadingMsg = ChatMessage(
      id: '${userMsg.id}_loading',
      role: ChatRole.assistant,
      text: '',
      timestamp: DateTime.now(),
      isLoading: true,
    );

    state = [...state, userMsg, loadingMsg];

    final response = await _connector.sendMessage(
      text,
      systemPrompt: _ciSystemPrompt,
    );

    state = state.map((m) {
      if (m.id == loadingMsg.id) {
        return m.copyWith(
          text: response ?? '⚠️ No response received.',
          isLoading: false,
        );
      }
      return m;
    }).toList();

    await _saveHistory();
  }

  void clearHistory() {
    state = [];
    _clearSaved();
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = state
          .where((m) => !m.isLoading)
          .take(100)
          .map(
            (m) => {
              'id': m.id,
              'role': m.role.name,
              'text': m.text,
              'timestamp': m.timestamp.toIso8601String(),
            },
          )
          .toList();
      await prefs.setString(_historyKey, jsonEncode(json));
    } catch (_) {}
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_historyKey);
      if (raw == null) return;
      final list = jsonDecode(raw) as List<dynamic>;
      state = list.map((item) {
        final map = item as Map<String, dynamic>;
        return ChatMessage(
          id: map['id'] as String,
          role: ChatRole.values.byName(map['role'] as String),
          text: map['text'] as String,
          timestamp: DateTime.parse(map['timestamp'] as String),
        );
      }).toList();
    } catch (_) {
      state = [];
    }
  }

  Future<void> _clearSaved() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
    } catch (_) {}
  }
}
