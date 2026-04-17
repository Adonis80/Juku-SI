import 'dart:convert';

import 'package:http/http.dart' as http;

/// CC (Claude Code) session status.
class CcStatus {
  const CcStatus({
    required this.state,
    required this.currentTask,
    required this.lastOutput,
    required this.updatedAt,
  });

  /// working | idle | error | unknown
  final String state;
  final String currentTask;
  final String lastOutput;
  final DateTime updatedAt;

  static final empty = CcStatus(
    state: 'unknown',
    currentTask: 'No active session',
    lastOutput: '',
    updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
  );

  factory CcStatus.fromJson(Map<String, dynamic> json) {
    return CcStatus(
      state: json['state'] as String? ?? 'unknown',
      currentTask: json['current_task'] as String? ?? '',
      lastOutput: json['last_output'] as String? ?? '',
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  bool get isWorking => state == 'working';
  bool get isIdle => state == 'idle';
  bool get isError => state == 'error';
  bool get isUnknown => state == 'unknown';
}

/// Fetches CC status from localhost:3333/status.json.
///
/// Claude Code (or a companion watcher script) should serve status.json
/// at this port. Returns [CcStatus.empty] when offline or malformed.
Future<CcStatus> readCcStatus({String host = 'localhost', int port = 3333}) async {
  try {
    final uri = Uri.http('$host:$port', '/status.json');
    final response = await http.get(uri).timeout(const Duration(seconds: 2));
    if (response.statusCode != 200) return CcStatus.empty;
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return CcStatus.fromJson(json);
  } catch (_) {
    return CcStatus.empty;
  }
}
