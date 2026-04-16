# CLAUDE.md — Juku SI (Mission Control)

What this is: Flutter web app — personal AI command centre. CI chat interface orchestrating Claude API and future LLM connectors.

Repo: https://github.com/Adonis80/Juku-SI

## Build Commands
export PATH="$HOME/development/flutter/bin:$PATH"
flutter analyze --no-pub
flutter test --no-pub
flutter run -d chrome --dart-define=ANTHROPIC_API_KEY=<key>
flutter build web --dart-define=ANTHROPIC_API_KEY=<key>

## NON-NEGOTIABLES
- NEVER mix business logic into widgets
- NEVER use print() — debugPrint() only
- ALWAYS run flutter analyze --no-pub after any Dart edit
- ALWAYS commit and push after each completed task
- ZERO analyze issues before commit

## Tech Stack
- Flutter 3.41.6 (Dart 3.11.4) — web
- flutter_riverpod: ^2.6.1 — AsyncNotifierProvider only
- http: ^1.2.2 — Claude API calls
- flutter_animate: ^4.5.0 — animations
- google_fonts: ^6.2.1 — Inter typeface
- shared_preferences: ^2.3.5 — web localStorage

## Design: Minority Report
Deep navy (0xFF0A0E1A), cyan (0xFF06B6D4) + purple (0xFF8B5CF6) neons.
GlassCard with BackdropFilter blur. PerspectiveGridPainter background.
HoloText with cyan glow shadows. Animations 300ms ease-out.

## ANTHROPIC_API_KEY
Passed via --dart-define=ANTHROPIC_API_KEY=<key> at run/build time.
Never hardcoded. Never in .env files committed to git.
