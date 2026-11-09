# Test Report

Honest status only. "Not verified" means nobody has run it.

## Automated (CI, GitHub Actions, pinned Luau 0.746 + Rojo 7.4.4)
Command: `luau tests/run.luau` plus `luau-analyze` on the pure modules.
Suites: `tests/run.luau` (profile core: lock, migration, validation, retry), `tests/CatchRulesSpec.luau`
(catch rules and catalog integrity), `tests/SpawnLevelSpec.luau` (spawn rolls and leveling).
Latest recorded results: see `continue.md` (commit, run IDs, test counts).

## Not verified (no Studio/runtime available to the development agent)
- Real DataStore behaviour (`UpdateAsync` cancel-on-nil, request budgets, throttling).
- `BindToClose` timing, Players event ordering, kick flow, two-server lock handoff.
- Server wiring (`CloudCatch.server.luau`, `ProfileStore.luau`, `StarterWorld.server.luau`) and all
  client UI at runtime; touch layout on an Android tablet; camera; performance on mobile.
- Visual appearance of the island and clouds (no genuine screenshots exist; none will be invented).
- Multiplayer behaviour.

## Release readiness
Not release-ready as a finished game. A build that passes CI is publishable as an early build, but
runtime behaviour is unverified until the owner plays it on a device and reports.

## Failures and fixes
- Profile save guard (`previous.lastSeen > snapshot.lastSeen`) could never trigger: fixed by session
  locking (commit 67052d6).
- Removed prototype `World.server.luau`: its publish-workflow file check would have broken the
  release; workflow updated.
