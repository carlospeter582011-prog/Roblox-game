# Changelog

## Unreleased (feature/world-progress-and-encyclopedia)
- Tool picker now lists all 15 tools (was 5 hardcoded); collection HUD fixed (unique count was always 0), shows species n/total, percent and next world ("coming soon").
- `ProgressRules` pure module; `Encyclopedia` counts catalog species only. 67 tests.

## Merged: PR #13
- Fixed likely crash on mutated catches (invalid attribute name `SpeciesCount_<species>:<mutation>`), base-species accounting and mutation XP, collapsed cloud puffs, hidden XP HUD text, catch button placement; removed duplicate quest `first_moonveil`.
- CI now runs `tests/MutationsSpec.luau` (previously unloaded) and analyses Mutations/Encyclopedia: 55 tests.

## Merged via PR #11 and follow-ups (published to Roblox; runtime unverified)
- Mutations (golden/rainbow/electric/storm), 86 species rows, 15 tools, 38 quests, collection HUD, first-catch tutorial, `CloudVisuals` (MeshPart-ready, no meshes yet).
- Data-only catalogs not yet used by any script: Worlds (10), Bosses (10), Travel, Island, Encyclopedia.

## Foundation (PR #11)
- Replaced the house-and-car prototype with the Catch a Cloud foundation (prototype preserved on
  branch `baseline/house-car-prototype`).
- Starter floating island, spawnable clouds (two species: Breeze, Drizzle) with weighted spawns,
  server-validated catching, five unlockable tools, two chapter-one quests.
- Persistent profile with cross-server session locking, v2 schema, v1 migration, save retries.
- Leveling (XP curve to level 100) and a level/coins HUD; catch button moved clear of the Roblox
  jump button.
- Pure-logic modules with unit tests in CI; publish workflow gated on those tests.
