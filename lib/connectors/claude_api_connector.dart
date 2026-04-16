import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/connector_interface.dart';

class ClaudeApiConnector implements LlmConnector {
  static const _model = 'claude-sonnet-4-6';
  static const _apiUrl = 'https://api.anthropic.com/v1/messages';
  static const _inputCostPer1M = 3.0;
  static const _outputCostPer1M = 15.0;

  final String _apiKey;
  ConnectorUsage _sessionUsage = ConnectorUsage.zero;

  ClaudeApiConnector({String? apiKey})
      : _apiKey = apiKey ??
            const String.fromEnvironment(
              'ANTHROPIC_API_KEY',
              defaultValue: '',
            );

  @override
  String get name => 'Claude API';

  @override
  String get mode => 'api';

  @override
  Future<String> sendMessage(
    String systemContext,
    String userMessage, {
    List<String> files = const [],
  }) async {
    if (_apiKey.isEmpty) {
      return 'Claude API key not configured. Run with --dart-define=ANTHROPIC_API_KEY=<key>';
    }

    final body = jsonEncode({
      'model': _model,
      'max_tokens': 4096,
      'system': systemContext,
      'messages': [
        {'role': 'user', 'content': userMessage},
      ],
    });

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
          'content-type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode != 200) {
        debugPrint('Claude API error ${response.statusCode}: ${response.body}');
        return 'Error ${response.statusCode}: ${response.reasonPhrase}';
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final content = (json['content'] as List<dynamic>).first
          as Map<String, dynamic>;
      final text = content['text'] as String;

      final usage = json['usage'] as Map<String, dynamic>?;
      if (usage != null) {
        final tokIn = (usage['input_tokens'] as int?) ?? 0;
        final tokOut = (usage['output_tokens'] as int?) ?? 0;
        final cost = (tokIn / 1000000 * _inputCostPer1M) +
            (tokOut / 1000000 * _outputCostPer1M);
        _sessionUsage = _sessionUsage +
            ConnectorUsage(
                tokensIn: tokIn, tokensOut: tokOut, costUsd: cost);
      }

      return text;
    } catch (e) {
      debugPrint('ClaudeApiConnector error: $e');
      return 'Connection error: $e';
    }
  }

  @override
  ConnectorUsage getUsage() => _sessionUsage;
}
