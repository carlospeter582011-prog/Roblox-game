# Test Report

Honest status only. "Not verified" means nobody has run it.

## Automated (CI, GitHub Actions, pinned Luau 0.746 + Rojo 7.4.4)
Command: `luau tests/run.luau` plus `luau-analyze` on the pure modules
(ProfileCore, CatchRules, SpawnRules, Leveling, Mutations, Encyclopedia).

| Suite | Tests | Covers |
|---|---|---|
| `tests/run.luau` | 14 | Profile core: lock, migration, validation, retry |
| `tests/CatchRulesSpec.luau` | 13 | Catch rules, catalog integrity |
| `tests/SpawnLevelSpec.luau` | 12 | Spawn rolls, leveling |
| `tests/MutationsSpec.luau` | 4 | Mutation roll/key/bonus (was never loaded until PR #13) |
| `tests/MutationAccountingSpec.luau` | 12 | Attribute-safe ids, mutated-catch accounting, quest catalog integrity |

Latest result: **55 tests, 0 failed** on b89520f ([PR #13 run 42620069899](https://github.com/carlospeter582011-prog/Roblox-game/actions/runs/42620069899)), both jobs green.
Before PR #13 the reported "39 tests" excluded the mutation tests.

Publish evidence: run 42613759016 (main, e72725a): workflow success; Roblox API accepted a Published place version. The gate blocked four earlier broken publishes.

## Not verified (no Studio/runtime available to the development agent)
- Real DataStore behaviour (`UpdateAsync` cancel-on-nil, budgets, throttling), `BindToClose` timing, Players event ordering, kick flow, two-server lock handoff.
- All server wiring and client UI at runtime; touch layout on an Android tablet; camera; mobile performance.
- Whether `SetAttribute` rejects `:` in names as documented (the fix is defensive either way).
- Visual appearance (no genuine screenshots exist; none will be invented). Multiplayer.

## Release readiness
Not release-ready as a finished game. Builds that pass CI are published as early builds; runtime behaviour is unverified until the owner plays on a device and reports.

## Failures and fixes
- Profile save guard could never trigger: fixed by session locking (67052d6).
- Publish workflow file check referenced the removed prototype: fixed.
- Four publishes blocked by the test gate (quests pointing at missing species): fixed upstream by e1ba85d.
- Mutated-catch attribute names, species-quest accounting, dead XP multiplier, collapsed puff animation, hidden XP HUD text, duplicate quest, unloaded MutationsSpec: fixed in PR #13.
