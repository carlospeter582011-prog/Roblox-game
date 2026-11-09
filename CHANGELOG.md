# Changelog

## Unreleased (branch `feature/catch-a-cloud-foundation`, PR #11)
- Replaced the house-and-car prototype with the Catch a Cloud foundation (prototype preserved on
  branch `baseline/house-car-prototype`).
- Starter floating island, spawnable clouds (two species: Breeze, Drizzle) with weighted spawns,
  server-validated catching, five unlockable tools, two chapter-one quests.
- Persistent profile with cross-server session locking, v2 schema, v1 migration, save retries.
- Leveling (XP curve to level 100) and a level/coins HUD; catch button moved clear of the Roblox
  jump button.
- Pure-logic modules with unit tests in CI; publish workflow gated on those tests.
