# DECISIONS.md — Juku SI

## D-001: Flutter web for SI-1 (2026-04-17)
SI targets Mac browser + iPhone. Single Flutter codebase.

## D-002: Claude API connector first (2026-04-17)
Direct HTTP, key-based. Proves the connector pattern before Chrome MCP connectors.

## D-003: SharedPreferences for web context storage (2026-04-17)
File IO unavailable in browser. SharedPreferences persists SI_CONTEXT.md content in localStorage.

## D-004: CC status via localStorage on web (2026-04-17)
CC writes status.json. A future bridge service will sync it to localStorage. SI polls every 10s.
