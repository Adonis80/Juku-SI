import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'connector_interface.dart';

/// Perplexity connector — routes messages to sonar (online search).
///
/// Set [apiKey] from environment: PERPLEXITY_API_KEY.
/// Sonar includes live web search — ideal for real-time research queries.
class PerplexityConnector implements LlmConnector {
  PerplexityConnector({required this.apiKey});

  final String apiKey;

  static const _model = 'sonar';
  static const _apiUrl = 'https://api.perplexity.ai/chat/completions';

  @override
  String get name => 'Perplexity (Sonar)';

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
      return '⚠️ Perplexity API key not configured. Set PERPLEXITY_API_KEY.';
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
          'messages': messages,
          'max_tokens': 4096,
        }),
      );

      if (response.statusCode != 200) {
        debugPrint(
          '[PerplexityConnector] error ${response.statusCode}: ${response.body}',
        );
        return '⚠️ Perplexity error: HTTP ${response.statusCode}';
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
      // Sonar pricing: ~$1/M tokens
      _lastCost = (inputTokens + outputTokens) * 1.0 / 1_000_000;

      return text;
    } catch (e) {
      debugPrint('[PerplexityConnector] exception: $e');
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
