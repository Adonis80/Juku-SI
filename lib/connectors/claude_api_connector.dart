import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'connector_interface.dart';

/// Claude API connector — routes messages to Anthropic claude-sonnet-4-6.
///
/// Set [apiKey] from environment or secure storage. Uses the Anthropic
/// Messages API directly (no SDK dependency).
class ClaudeApiConnector implements LlmConnector {
  ClaudeApiConnector({required this.apiKey});

  final String apiKey;

  static const _model = 'claude-sonnet-4-6';
  static const _apiUrl = 'https://api.anthropic.com/v1/messages';
  static const _maxTokens = 8192;

  @override
  String get name => 'Claude (Sonnet 4.6)';

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
    if (!isConfigured) return '⚠️ Claude API key not configured. Set CLAUDE_API_KEY.';

    try {
      final body = <String, dynamic>{
        'model': _model,
        'max_tokens': _maxTokens,
        'messages': [
          {
            'role': 'user',
            'content': _buildContent(message, contextFiles),
          },
        ],
      };

      if (systemPrompt != null && systemPrompt.isNotEmpty) {
        body['system'] = systemPrompt;
      }

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
          'content-type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        debugPrint('[ClaudeApiConnector] error ${response.statusCode}: ${response.body}');
        return '⚠️ Claude API error: HTTP ${response.statusCode}';
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final content = data['content'] as List<dynamic>;
      final text = (content.first as Map)['text'] as String? ?? '';

      final usage = data['usage'] as Map<String, dynamic>? ?? {};
      final inputTokens = (usage['input_tokens'] as int?) ?? 0;
      final outputTokens = (usage['output_tokens'] as int?) ?? 0;
      _lastTokens = (input: inputTokens, output: outputTokens);
      // Sonnet 4.6 pricing: $3/M input, $15/M output
      _lastCost = (inputTokens * 3.0 + outputTokens * 15.0) / 1_000_000;

      return text;
    } catch (e) {
      debugPrint('[ClaudeApiConnector] exception: $e');
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
