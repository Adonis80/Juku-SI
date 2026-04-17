import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'connector_interface.dart';

/// OpenAI ChatGPT connector — routes messages to gpt-4o.
///
/// Set [apiKey] from environment: OPENAI_API_KEY.
class ChatGptConnector implements LlmConnector {
  ChatGptConnector({required this.apiKey});

  final String apiKey;

  static const _model = 'gpt-4o';
  static const _apiUrl = 'https://api.openai.com/v1/chat/completions';
  static const _maxTokens = 4096;

  @override
  String get name => 'ChatGPT (GPT-4o)';

  @override
  bool get isConfigured => apiKey.isNotEmpty;

  @override
  double get lastRequestCostUsd => _lastCost;
  double _lastCost = 0;

  @override
  ({int input, int output}) get lastTokenUsage => _lastTokens;
  ({int input, int output}) _lastTokens = (input: 0, output: 0);

  @override
  Future<String?> sendMessage(
    String message, {
    String? systemPrompt,
    List<String> contextFiles = const [],
  }) async {
    if (!isConfigured) {
      return '⚠️ OpenAI API key not configured. Set OPENAI_API_KEY.';
    }

    try {
      final messages = <Map<String, dynamic>>[];
      if (systemPrompt != null && systemPrompt.isNotEmpty) {
        messages.add({'role': 'system', 'content': systemPrompt});
      }
      messages.add({
        'role': 'user',
        'content': _buildContent(message, contextFiles),
      });

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': _maxTokens,
          'messages': messages,
        }),
      );

      if (response.statusCode != 200) {
        debugPrint(
          '[ChatGptConnector] error ${response.statusCode}: ${response.body}',
        );
        return '⚠️ OpenAI error: HTTP ${response.statusCode}';
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = data['choices'] as List<dynamic>;
      final text =
          ((choices.first as Map)['message'] as Map)['content'] as String? ??
          '';

      final usage = data['usage'] as Map<String, dynamic>? ?? {};
      final inputTokens = (usage['prompt_tokens'] as int?) ?? 0;
      final outputTokens = (usage['completion_tokens'] as int?) ?? 0;
      _lastTokens = (input: inputTokens, output: outputTokens);
      // GPT-4o pricing: $5/M input, $15/M output
      _lastCost = (inputTokens * 5.0 + outputTokens * 15.0) / 1_000_000;

      return text;
    } catch (e) {
      debugPrint('[ChatGptConnector] exception: $e');
      return '⚠️ Connection error. Check your network.';
    }
  }

  String _buildContent(String message, List<String> contextFiles) {
    if (contextFiles.isEmpty) return message;
    final sb = StringBuffer();
    for (final file in contextFiles) {
      sb.writeln('<context>\n$file\n</context>');
    }
    sb.write(message);
    return sb.toString();
  }
}
