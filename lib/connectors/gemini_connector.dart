import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'connector_interface.dart';

/// Google Gemini connector — routes messages to gemini-2.0-flash.
///
/// Set [apiKey] from environment: GEMINI_API_KEY.
class GeminiConnector implements LlmConnector {
  GeminiConnector({required this.apiKey});

  final String apiKey;

  static const _model = 'gemini-2.0-flash';
  static const _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';

  @override
  String get name => 'Gemini (2.0 Flash)';

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
      return '⚠️ Gemini API key not configured. Set GEMINI_API_KEY.';
    }

    try {
      final body = <String, dynamic>{
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': _buildContent(message, contextFiles)},
            ],
          },
        ],
        'generationConfig': {'maxOutputTokens': 4096},
      };

      if (systemPrompt != null && systemPrompt.isNotEmpty) {
        body['systemInstruction'] = {
          'parts': [
            {'text': systemPrompt},
          ],
        };
      }

      final url = Uri.parse('$_baseUrl?key=$apiKey');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        debugPrint(
          '[GeminiConnector] error ${response.statusCode}: ${response.body}',
        );
        return '⚠️ Gemini error: HTTP ${response.statusCode}';
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = data['candidates'] as List<dynamic>;
      final content =
          (candidates.first as Map)['content'] as Map<String, dynamic>;
      final parts = content['parts'] as List<dynamic>;
      final text = (parts.first as Map)['text'] as String? ?? '';

      final usageMeta = data['usageMetadata'] as Map<String, dynamic>? ?? {};
      final inputTokens = (usageMeta['promptTokenCount'] as int?) ?? 0;
      final outputTokens = (usageMeta['candidatesTokenCount'] as int?) ?? 0;
      _lastTokens = (input: inputTokens, output: outputTokens);
      // Gemini 2.0 Flash pricing: $0.075/M input, $0.30/M output
      _lastCost = (inputTokens * 0.075 + outputTokens * 0.30) / 1_000_000;

      return text;
    } catch (e) {
      debugPrint('[GeminiConnector] exception: $e');
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
