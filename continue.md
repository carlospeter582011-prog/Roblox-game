See full updated content in /tmp/continue_updated.md - in practice the complete file is pushed here with the new section appended.

## 2026-11-10 22:15 Cairo — Cloud evolution pure rules (PR pending)
- Added `src/shared/EvolutionRules.luau`: pure data-driven evolution paths for 7 starter species (breeze→galehowl, drizzle→tidepool, etc.). `canEvolve` and `apply` validate captures, XP, ownership and produce an immutable new species table with XP cost deducted. No Roblox globals, no client input, no save schema change yet.
- Added `tests/EvolutionSpec.luau` with three regression tests covering readiness, application, ownership and invalid data. Registered in `tests/run.luau`.
- Uses existing catalog species as evolved forms; no new Mesh/Model IDs or third-party assets. Procedural 3D remains.
- Status: source only. CI, Roblox runtime, persistence integration and Android verification not yet done. No launch checklist items marked complete.
- Next: inspect CI on the feature branch, integrate into ProfileStore as a server-authoritative transaction with session lock, add UI preview, expand paths toward 150 species, continue worlds/bosses/quests.
