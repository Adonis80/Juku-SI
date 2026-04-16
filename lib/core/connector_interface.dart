abstract class LlmConnector {
  String get name;
  String get mode;

  Future<String> sendMessage(
    String systemContext,
    String userMessage, {
    List<String> files = const [],
  });

  ConnectorUsage getUsage();
}

class ConnectorUsage {
  final int tokensIn;
  final int tokensOut;
  final double costUsd;

  const ConnectorUsage({
    required this.tokensIn,
    required this.tokensOut,
    required this.costUsd,
  });

  ConnectorUsage operator +(ConnectorUsage other) => ConnectorUsage(
        tokensIn: tokensIn + other.tokensIn,
        tokensOut: tokensOut + other.tokensOut,
        costUsd: costUsd + other.costUsd,
      );

  static const zero = ConnectorUsage(tokensIn: 0, tokensOut: 0, costUsd: 0);
}
