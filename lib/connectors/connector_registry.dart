import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'claude_api_connector.dart';
import 'chatgpt_connector.dart';
import 'gemini_connector.dart';
import 'perplexity_connector.dart';
import 'connector_interface.dart';

/// All registered LLM connectors. Add/remove connectors here.
final allConnectorsProvider = Provider<List<LlmConnector>>((ref) {
  return [
    ClaudeApiConnector(
      apiKey: const String.fromEnvironment('CLAUDE_API_KEY', defaultValue: ''),
    ),
    ChatGptConnector(
      apiKey: const String.fromEnvironment('OPENAI_API_KEY', defaultValue: ''),
    ),
    GeminiConnector(
      apiKey: const String.fromEnvironment('GEMINI_API_KEY', defaultValue: ''),
    ),
    PerplexityConnector(
      apiKey: const String.fromEnvironment(
        'PERPLEXITY_API_KEY',
        defaultValue: '',
      ),
    ),
  ];
});

/// Index of the currently selected connector (0 = Claude by default).
final activeConnectorIndexProvider = StateProvider<int>((ref) => 0);

/// The active connector instance.
final activeConnectorProvider = Provider<LlmConnector>((ref) {
  final connectors = ref.watch(allConnectorsProvider);
  final index = ref.watch(activeConnectorIndexProvider);
  return connectors[index.clamp(0, connectors.length - 1)];
});
