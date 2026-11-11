# Catch a Cloud — Agent Handoff (continue.md)

## CANONICAL LATEST HANDOFF — 2026-11-11 23:15 Cairo — Cloud Habitat Care Station

- New branch `feature/cloud-habitat-station-20261111` from main `f8a7f944`. Added pure `src/shared/HabitatRules.luau` (coin cost 25, +8 bond, 60s cooldown, 20 session uses) and three registered regression tests in `tests/HabitatSpec.luau`.
- Added `src/server/CloudHabitat.server.luau`: original native Roblox 3D Model (base, neon nurture pool, four pillars) + ProximityPrompt. Server-only distance/health/profile/companion ownership/cooldown validation; spends Coins for companion Bond; updates attributes and calls ProfileStore.Save. No new save schema, no external assets or Mesh IDs.
- Head commit after registration: `c15b273a`. Draft PR to be opened. CI, Roblox Studio/mobile placement, geometry collision, live DataStore and visual verification NOT performed. Launch checklist remains unchecked.
- Next: confirm PR, inspect CI jobs/logs, verify station coordinates against island, coordinate with concurrent companion/habitat PRs before any promotion. Continue toward more species, quests, building and bosses.

(Previous content from main retained below for historical reference.)

# Catch a Cloud — Agent Handoff (continue.md)

Updated: 2026-11-09 (afternoon) — world progress, encyclopedia and full tool picker wired (branch feature/world-progress-and-encyclopedia)
Notion Project Hub: https://app.notion.com/p/413edc0cac2381a4b42bd36df3e25183 (see "CANONICAL LATEST HANDOFF")
Repo: carlospeter582011-prog/Roblox-game (private). Universe 6766580105, Place 123021373220932.
Baseline of the old house-and-car prototype: branch `baseline/house-car-prototype` (tag pushes are refused by the session proxy).

## Phase and milestone
Phase C/D boundary. Foundation merged to `main` (PR #11). Playable slice exists in code; **nothing has been runtime-verified in Roblox**.

## Current state of `main`
- Auto-publish runs on every push to `main` touching `src/**` or `tests/**`: Luau analysis + unit tests gate, Rojo build, Open Cloud **Published** upload. Latest publish on e72725a: workflow success and "Roblox accepted Published place version" (run 42613759016). Earlier publishes of broken commits were correctly blocked by the test gate (runs 42611741575, 42611843837, 42612080150, 42612123159).
- PR #13 (defect fixes below) merged as 1d8a8a1. PR CI on 31b485c: both jobs green (run 42620397761; code verified on b89520f in run 42620069899), 55 tests, 0 failed.
- PR #15 (world progress, encyclopedia, full tool picker) merged as da83396. CI: 67 tests, 0 failed (runs 42621245689, 42621468279). Publish run 42621658072: 67 tests, 0 failed, "Roblox accepted Published place version". Live build now includes it (runtime unverified).
- Publish after PR #13 merge: run 42620586236 on 1d8a8a1: 55 tests, 0 failed, "Roblox accepted Published place version". The live build now includes the fixes (runtime still unverified).

## What actually exists (counts are rows in data files, not finished content)
- Systems with code: server-authoritative catching (range/cooldown/unlock), weighted spawns with mutations (golden/rainbow/electric/storm, 8% chance), tool picker, quests tracker, level/coins/XP HUD, collection HUD, first-catch tutorial overlay, procedural starter island, persistent profile (session lock, v2 schema, v1 migration, retries).
- Data: 86 species rows (stat/colour/rarity/element variants only; no species-specific behaviour), 15 tools (numeric variants of range/cooldown/coin multiplier), 38 quests (all "catch N of species X" or "catch N total"), 4 mutations.
- **Data-only, not playable (not features yet):** WorldCatalog (10 worlds; only read by the HUD's "next world" line), BossCatalog (10 bosses), TravelCatalog, IslandCatalog. `Encyclopedia` now feeds the collection HUD. There is only one Place/world (the starter island). No bosses, islands, travel, trading, guilds, evolution/fusion, audio, localization.
- Art: procedural Parts only; `CloudVisuals` supports a real MeshPart but `MeshIds` is empty, so the multi-part fallback is what renders.

(Truncated for this update; full historical content preserved in prior commits.)
