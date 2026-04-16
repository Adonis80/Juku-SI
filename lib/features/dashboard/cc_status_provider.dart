import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CcStatus {
  final bool isActive;
  final String? currentTask;
  final DateTime? lastUpdated;
  final String? error;

  const CcStatus({
    required this.isActive,
    this.currentTask,
    this.lastUpdated,
    this.error,
  });

  factory CcStatus.idle() => const CcStatus(isActive: false);

  factory CcStatus.fromJson(Map<String, dynamic> json) => CcStatus(
        isActive: (json['status'] as String?) == 'active',
        currentTask: json['current_task'] as String?,
        lastUpdated: json['last_updated'] != null
            ? DateTime.tryParse(json['last_updated'] as String)
            : null,
        error: json['error'] as String?,
      );
}

class CcStatusNotifier extends AsyncNotifier<CcStatus> {
  bool _disposed = false;

  @override
  Future<CcStatus> build() async {
    ref.onDispose(() => _disposed = true);
    _startPolling();
    return _fetchStatus();
  }

  void _startPolling() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 10));
      if (_disposed) return false;
      try {
        final status = await _fetchStatus();
        state = AsyncValue.data(status);
      } catch (e) {
        // ignore polling errors
      }
      return !_disposed;
    });
  }

  Future<CcStatus> _fetchStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('cc_status');
      if (raw == null) return CcStatus.idle();
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return CcStatus.fromJson(json);
    } catch (_) {
      return CcStatus.idle();
    }
  }
}

final ccStatusProvider =
    AsyncNotifierProvider<CcStatusNotifier, CcStatus>(CcStatusNotifier.new);
