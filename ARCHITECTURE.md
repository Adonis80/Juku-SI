# Architecture — Juku SI (Mission Control)

## Overview
Flutter web app (Mac browser + iPhone). Single codebase. Dark premium glass morphism UI (Minority Report aesthetic).

## Folder Structure
lib/
  core/            — CI agent, router, context manager
  connectors/      — one file per LLM (Claude API first)
  features/
    dashboard/     — CC status panel
    chat/          — main CI chat interface
  theme/           — SI design tokens

## State Management
Riverpod 3 — AsyncNotifierProvider only. No StateNotifier.

## Connector Interface
abstract class LlmConnector {
  Future<String> sendMessage(String context, String message);
  ConnectorUsage getUsage();
  String get mode; // 'api' or 'personal_account'
}

## Memory System
SI_CONTEXT.md — master state file in project root. On web, stored in SharedPreferences.

## CC Status Panel
Reads localStorage key 'cc_status' on web. Polls every 10s.
