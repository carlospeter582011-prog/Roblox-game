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

## Wired in PR #15 (merged and published; unverified in-game)
- `ProgressRules.luau` (pure): unlock ordering/status for tools and worlds.
- Tool picker listed 5 hardcoded tools, so 10 of 15 could never be equipped by a player; now lists all tools in unlock order in a scrolling panel.
- Collection HUD compared 12 characters to the 13-character `SpeciesCount_` prefix, so "Unique" was always 0. Parsing is now `Encyclopedia.fromAttributes` (tested); HUD shows species n/total with percent and "Next world ... (coming soon)". Worlds remain data only; nothing teleports or loads a world yet.
- `Encyclopedia` counts catalog species only, so variant keys cannot push completion past 100%.
- New tests also assert world/boss catalog integrity (unique orders, increasing thresholds, one boss per world).

## Defects found and fixed in PR #13 (merged; found by reading, not by running the game)
1. Mutated catches were saved/replicated under keys like `breeze:golden`, and `SetAttribute("SpeciesCount_breeze:golden")` uses a character Roblox attribute names do not allow (documented rule; not observed in Studio) so ~8% of catches likely threw mid-handler, and returning players with such a saved key would error on load. Now only attribute-safe ids are replicated; legacy keys are skipped on load.
2. Mutated catches did not advance species quests; mutation XP multiplier was never applied. Now base species is always counted, variants tracked separately, XP multiplier applied.
3. Cloud bobbing moved every puff to one point (collapsed shape). Offsets preserved.
4. HUD computed XP progress but never showed it; catch button moved mid-right (the shrink to 120x40 requested earlier is kept) to stay clear of the Roblox jump button.
5. Quest `first_moonveil` removed (duplicate of `first_aurora`, unimplemented condition).
6. CI gap: `tests/MutationsSpec.luau` was never loaded; the "39 tests passing" did not include mutation tests.

## Verified vs not verified
- VERIFIED by CI evidence: Rojo build, XML validation, Luau static analysis of pure modules, 67 unit tests (profile lock/migration/retry vs a fake DataStore; catch rules; spawn/leveling; mutations; catalog integrity), publish accepted by Roblox API (run 42613759016).
- NOT VERIFIED: any in-game behaviour. Studio/runtime, real DataStore, BindToClose, kick flow, client UI, touch layout on the Android tablet, camera, performance, visuals (no genuine screenshots exist), multiplayer, whether the attribute-name rule behaves as documented.

## Known issues / limits
- If a final release-save fails after retries the lock stays up to 300s; rejoining inside that window kicks the player.
- Sanitize resets a corrupt numeric field to 0 on save rather than rejecting the record.
- Species quests count the base species including mutated variants; there is no per-variant quest.
- `docs/3d-assets.md` tells the reader to import via Studio; the owner works on an Android tablet without Studio. Use the Open Cloud upload pipeline (`scripts/upload_sports_car.py`, `.github/workflows/import-sports-car.yml`) for meshes instead, and record every asset in ASSET_REGISTRY.md. The sports-car asset 124315115505635 is unrecorded-source/licence and unused now.
- Another agent (or the owner) pushes to this repo between sessions: always `git fetch` and read `git log origin/main` before working, and do not overwrite continue.md with a shorter stub.

## Pending decisions
- Q83: collaborative island building (provisional: owner-only editing).
- Owner decision needed on whether each push to `main` should keep auto-publishing while runtime behaviour is unverified (current setting follows the owner's "auto-publish after validation" authorisation).

## Next planned actions (in order)
1. Owner plays the published build (da83396) on the tablet and reports what they see: first catch time, whether mutated clouds (golden/rainbow/electric/storm tint) can be caught without errors, button placement, HUD readability. This is the only runtime evidence available; no Studio automation exists here.
2. Wire the remaining data-only catalogs into real systems one at a time, each with pure logic + tests: world unlock/travel with teleport fallback (needs additional Places), boss encounter state machine, island ownership/persistence.
3. Species behaviour data model (movement patterns, abilities, spawn conditions by world/weather) before adding species toward 150; do not count stat variants as distinct species.
4. Asset pipeline: pick CC0 cloud/vegetation meshes, upload via Open Cloud, set `CloudVisuals.MeshIds`, record in ASSET_REGISTRY.md, inspect every MeshPart.
5. Pin and extend CI; keep the publish gate green.

## How to resume
1. Read Notion "CANONICAL LATEST HANDOFF", this file, `ROADMAP.md`, `TEST_REPORT.md`.
2. `git fetch`, read `git log origin/main`, `gh run list -R carlospeter582011-prog/Roblox-game` (GraphQL is blocked: use `gh api` REST for PRs; tags cannot be pushed).
3. Sandbox cannot download Luau/Rojo; tests run on GitHub's runner: push a `feature/**` branch or open a PR, then read the run.
4. Never check an acceptance box or claim completion without runtime evidence. Update this file and Notion after each milestone with commit SHAs and run IDs.
