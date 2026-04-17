/// Standard interface for all LLM connectors.
///
/// Every connector (Claude API, ChatGPT, Gemini, Perplexity) implements this.
/// Add a new LLM by creating a new connector file; remove by deleting it.
abstract class LlmConnector {
  String get name;
  bool get isConfigured;

  /// Sends [message] to the LLM with optional [systemPrompt] and [contextFiles].
  /// Returns the assistant's response text, or null on failure.
  Future<String?> sendMessage(
    String message, {
    String? systemPrompt,
    List<String> contextFiles = const [],
  });

  /// Estimated cost of last request in USD (0.0 if not tracked).
  double get lastRequestCostUsd;

  /// Tokens used in last request (in/out).
  ({int input, int output}) get lastTokenUsage;
}
