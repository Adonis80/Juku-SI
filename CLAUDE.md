# CLAUDE.md — Juku SI (v1.0)

**What this is:** Flutter web + iOS app. Juku Smart Interface — a personal AI command centre that orchestrates Claude Code, ChatGPT, Perplexity, Gemini, and any LLM via a single CI (Central Intelligence) chat interface.

**Spec:** ~/Documents/Claude/Projects/The-Builder/SI-PRODUCT.md
**Shared backend:** Supabase (same project as Juku-Flutter: https://tipinjxdupfwntmkarkj.supabase.co)

---

## Build Commands

```bash
export PATH="$HOME/development/flutter/bin:$PATH"
flutter analyze --no-pub   # ZERO issues before commit
flutter test --no-pub      # ZERO failures before commit
flutter run -d chrome      # Run in browser
dart format .              # Format Dart files
```

---

## NON-NEGOTIABLES

- **NEVER force-push** to main
- **NEVER declare done** while `flutter analyze` has issues or `flutter test` has failures
- **NEVER mix business logic into widgets** — logic goes in providers or services
- **NEVER use `print()`** — `debugPrint()` only in debug blocks
- **ALWAYS run** `flutter analyze --no-pub` after any Dart edit
- **ALWAYS commit and push** after each completed task
- **ALWAYS notify** Dhayan via Dispatch: `[SI] ✅ Task — summary`

---

## Tech Stack

- **Flutter 3.41.6** (Dart 3.11.4)
- **flutter_riverpod ^2.6.1** — StateNotifierProvider for state
- **google_fonts ^6.x** — Inter as primary typeface
- **flutter_animate ^4.5** — micro-animations
- **http ^1.x** — Claude API + CC status polling
- **shared_preferences ^2.x** — chat history persistence

> Note: Upgrade to Riverpod 3.x in SI-2. Avoid `StateNotifier` deprecation.

---

## Architecture

```
lib/
  core/              — CC status reader, context manager
  connectors/        — one file per LLM (claude_api_connector.dart, ...)
  features/
    chat/            — CI chat screen + provider + message model
    dashboard/       — CC status panel (polls localhost:3333/status.json)
    improvements/    — Suggested improvements tab (SI-4)
    guide/           — User guide (SI-6)
    auth/            — WebAuthn passkeys (SI-3)
  theme/             — SIColors, GlassCard, HoloText, PerspectiveGridPainter
```

---

## Design System (Minority Report)

- **Background:** `Color(0xFF050A0F)` — deep space dark
- **Grid:** `PerspectiveGridPainter` — converging cyan lines, horizon glow
- **Cards:** `GlassCard` — BackdropFilter blur + gradient + glowing border
- **Text:** `HoloText` — Inter 200–300 weight, wide letter-spacing, glow shadows
- **Accent:** `SIColors.cyan` (#00D4FF) primary, `SIColors.purple` (#8B5CF6) user
- **Animations:** 200ms fade-in + 250ms ease-out slide on all new messages

---

## CC Bridge (Status Panel)

- **SI reads:** `localhost:3333/status.json` (polled every 30s)
- **Schema:** `{ "state": "working|idle|error", "current_task": "...", "last_output": "...", "updated_at": "ISO8601" }`
- **Companion watcher:** ⏳ Not yet built — run `npx serve -p 3333 ~/Documents/Claude/Projects/The-Builder` to serve status.json manually

---

## Claude API Connector

- **Model:** `claude-sonnet-4-6`
- **Key:** Set via `CLAUDE_API_KEY` env var or `--dart-define=CLAUDE_API_KEY=sk-ant-...`
- **System prompt:** CI persona, routes to best tool, Juku context baked in
- **Cost tracking:** Sonnet 4.6 pricing — $3/M input, $15/M output

---

## Sprint Plan

| Sprint | What | Status |
|---|---|---|
| SI-1 | Foundation: theme, CI chat, Claude API stub, CC status panel | ✅ |
| SI-2 | Connector layer: ChatGPT, Gemini, Perplexity, file upload routing | ⏳ |
| SI-3 | Auth: WebAuthn passkeys, multi-tenant shell | ⏳ |
| SI-4 | Knowledge base + Suggested Improvements tab | ⏳ |
| SI-5 | Usage dashboard + gamification | ⏳ |
| SI-6 | User guide + polish + public beta | ⏳ |

---

## ⏳ Manual Setup

- ⏳ Set Claude API key: `export CLAUDE_API_KEY=sk-ant-...` or pass via `--dart-define`
- ⏳ CC bridge watcher: serve ~/Documents/Claude/Projects/The-Builder/ at localhost:3333
- ⏳ `gh repo create Adonis80/Juku-SI --private` and push

---

## Commit Rules

```bash
git add -A
git commit -m "feat(SI-1): description"
git push origin main
```
