# Architecture

Rojo project (`default.project.json`): `src/server` -> ServerScriptService, `src/shared` ->
ReplicatedStorage, `src/client` -> StarterPlayerScripts. Server is authoritative for all progress.

## Principle: pure logic, thin Roblox wiring
No Roblox Studio/runtime is available to the development agent, so every rule that can be
expressed without Roblox globals lives in a **pure module** that the plain Luau CLI can test in CI
(`tests/run.luau`). Roblox-facing scripts only wire services, instances and remotes to those
modules. New logic goes into pure modules first.

## Modules
| Module | Kind | Responsibility |
|---|---|---|
| `src/server/ProfileCore.luau` | pure | Session lock (jobId + timestamp, 300s stale), v2 record envelope, v1 migration, field validation, newer-schema refusal, ownership-checked save, retry helper |
| `src/server/ProfileStore.luau` | wiring | DataStore + Players events, load retries, kick on lock/failed load, serialised saves, rejoin race, parallel BindToClose, autosave; exposes `Get`, `AddCatch`, `Save` |
| `src/shared/CatchRules.luau` | pure | Tool resolution/equip checks, catch range, coin reward, quest progress, `applyCatch` |
| `src/shared/SpawnRules.luau` | pure | Weighted species roll with injected RNG |
| `src/shared/Leveling.luau` | pure | XP -> level curve (25*(L-1)*L, cap 100) |
| `src/shared/Mutations.luau` | pure | Mutation roll (8%), multipliers, variant key (`species:mutation`, server-side only; not attribute-safe) |
| `src/shared/Encyclopedia.luau` | pure | Unique/completion helpers (not yet used by any script) |
| `src/shared/CloudVisuals.luau` | wiring | Cloud visual: MeshPart if `MeshIds.cloud` set, else multi-part fallback |
| `src/client/Inventory.client.luau` | client | Compact collection HUD (caught/unique) |
| `src/shared/CloudCatalog.luau` | data | Species (id, name, rarity, radius, reward, spawnWeight, colorRGB, element): 86 stat/colour variants |
| `src/shared/WorldCatalog.luau`, `BossCatalog.luau`, `TravelCatalog.luau`, `IslandCatalog.luau` | data | Planning data; **referenced by no script yet** |
| `src/shared/CatchToolCatalog.luau` | data | Catching tools |
| `src/shared/QuestCatalog.luau` | data | Quests |
| `src/server/CloudCatch.server.luau` | wiring | Spawns clouds, validates catch/equip remotes server-side, animates cloud visuals |
| `src/server/StarterWorld.server.luau` | wiring | Procedural starter floating island, lighting, spawn |
| `src/client/CloudCatch.client.luau` | client | Catch button, quest tracker, level/coins HUD |
| `src/client/CloudTools.client.luau` | client | Tool picker |

## Boundaries and data flow
Client -> remote (`RequestCloudCatch`, `EquipCatchTool`) -> server validates (type, length,
cooldown, range, unlock, profile loaded) -> `ProfileStore.AddCatch` -> `CatchRules.applyCatch`
(base species always counted; mutation variant key tracked separately; only attribute-safe ids replicated)
mutates the in-memory profile -> attributes replicate to the client HUD -> autosave/leave-save via
`ProfileCore` (lock-owned writes only).

## Persistence
Store `CatchACloudProfiles_v1`, key `player_<UserId>`. Record
`{ version = 2, data, lock = { jobId, at }, savedAt }`. Old flat v1 records migrate on first load.

## CI/CD
- `build.yml` (PR and `feature/**` pushes): pinned Luau 0.746 analysis + unit tests; pinned Rojo
  7.4.4 build + XML validation + artifact.
- `auto-publish.yml` (push to `main` touching `src/**`/`tests/**`): same Luau gate, then build and
  **Published** upload via Open Cloud (environment `roblox-publishing`). Publish is skipped if the
  gate fails.
- `deploy.yml`: manual Saved-only upload of a previous build artifact.
