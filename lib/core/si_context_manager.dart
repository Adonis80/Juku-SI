import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kContextKey = 'si_context_md';

const _kDefaultContext = '''# SI_CONTEXT.md — Mission Control State

**Last updated:** 2026-04-17
**Session:** SI-1 foundation

## Current State
SI initialised. CI chat connected to Claude API (claude-sonnet-4-6).

## Active Connectors
- Claude API: connected (claude-sonnet-4-6)

## Recent Actions
- SI-1 foundation complete.
''';

class SiContextManager extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kContextKey) ?? _kDefaultContext;
  }

  Future<void> updateContext(String newContext) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kContextKey, newContext);
    state = AsyncValue.data(newContext);
  }

  Future<void> appendExchange(String userMsg, String assistantMsg) async {
    final current = state.valueOrNull ?? _kDefaultContext;
    final now = DateTime.now();
    final entry =
        '\n## Exchange ${now.toIso8601String()}\n**User:** $userMsg\n**SI:** $assistantMsg\n';
    await updateContext(current + entry);
  }
}

final siContextProvider = AsyncNotifierProvider<SiContextManager, String>(
  SiContextManager.new,
);
