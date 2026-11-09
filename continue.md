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

## 2026-11-09 — 3D world model conversion (PR #17, draft)
- Read latest `main` and reconciled previous agent's work: main already has 86 species rows, 15 tools, 38 quests, mutation/encyclopedia/tool UI, and an Open Cloud Published upload with CI evidence, but no Roblox Studio runtime evidence.
- New branch `feature/3d-model-world-assets` from `main`; draft PR https://github.com/carlospeter582011-prog/Roblox-game/pull/17.
- Added `src/server/WorldAssetModels.luau`: reusable Roblox 3D Model assemblies for SkyTree3D, SkyCrystal3D, FloatingRock3D, with optional MeshPart slots for approved verified Mesh IDs. Wired `StarterWorld.server.luau` to instantiate these. Registered provenance and caveats in ASSET_REGISTRY.md.
- No Canvas is used for world objects. ScreenGui remains for necessary HUD controls. **No real external MeshPart IDs are yet configured**, so this is not a completed professional mesh replacement. Do not treat Model asset IDs as MeshPart IDs. No external asset was uploaded.
- PR #17 is DRAFT, NOT merged or published. Needs CI, Roblox runtime visual verification and approved mesh asset IDs. Do not claim success before evidence.

## 2026-11-09 — continuation: original 3D sky arches
- Inspected current main and this branch via GitHub connector (private repository cannot be assumed cloned locally). Earlier handoff on `feature/catch-a-cloud-foundation` was stale: PR #11 and PR #15 are already merged/published according to main handoff.
- Added reusable `WorldAssetModels.skyArch` with actual Roblox Model/Part geometry, four placements on the starter island, decorative non-collidable pillars, and an illuminated keystone. No Canvas and no third-party asset needed. Commits `66734e34ea06da4a0f1dc2e007130f744c851c80` and `e381c8b849c9427785cda2a03049717e4af2cc85`.
- Existing tree/crystal/floating rock are also 3D Model assemblies; optional MeshPart slots still need legitimately licensed uploaded mesh IDs. No internet mesh has been imported or uploaded; do not claim otherwise.
- Not yet CI-checked, merged, published, or visually verified. Continue PR #17; verify Rojo/Luau CI and Roblox runtime before promotion. Preserve ScreenGui for player controls (it is not Canvas world art).

## 2026-11-09 — 3D world models merged, production publish pending verification
- PR #17 was marked ready and merged into `main` after GitHub Actions build/test run 42623506887 reported success on branch head ca46b94. Merge commit `7974731e5e2271e3bb6e4a2b423bc11951a76a3b`.
- `StarterWorld` now uses original 3D Model assemblies for trees, crystals, floating rocks and four glowing sky arches. These are procedural Part-based Roblox Models, NOT imported external mesh assets. No external MeshPart asset ID has been uploaded or configured; no Canvas world art. ScreenGui stays for HUD.
- `auto-publish.yml` triggers on main source changes and uploads `Published` after test/build gates. This merge triggers the workflow, but the result of THIS production run has not yet been independently verified. Do not say live published until GitHub Actions confirms the publish step.
- Next: inspect production run and Roblox place, then implement licensed external mesh upload (Open Cloud asset type/permissions) with recorded provenance; no guessed asset IDs. No runtime/visual verification.

## 2026-11-09 — original cloud GLB upload automation added
- Added original 5-component cloud mesh generator `scripts/generate_cloud_glb.py` (GLB, using trimesh), upload wrapper `scripts/upload_original_cloud.py`, and `.github/workflows/import-original-cloud.yml` (push to main on these paths plus workflow_dispatch). Initial workflow-triggering commit: `d3cf49aca22853919e236ae13655867c37f8d676`.
- Pipeline builds and validates a real 3D GLB, attempts owner upload through Open Cloud using existing GitHub secret `ROBLOX_API_KEY`, and publishes `original-cloud-model-asset-id` artifact on success. **Workflow outcome not verified in this session; don't claim upload success.**
- Roblox GLB uploads are Model packages, NOT directly usable MeshPart.MeshIds. The ID must not be pasted into `CloudVisuals.MeshIds.cloud`; requires a validated model insertion/integration route and runtime testing. `ASSET_REGISTRY.md` updated. No mesh asset integrated yet. Production publish of PR #17 remains unverified from GitHub Actions.
- Next: inspect GitHub Actions `Import Original Cloud 3D Model` run, diagnose API failure if any, extract confirmed ID, integrate Model safely (e.g. server asset loading with validated ownership and fallback), run CI, publish and visually QA. No Roblox Studio available to owner.

## 2026-11-09 — tablet-first asset workflow documentation correction
- Corrected `docs/3d-assets.md` on main (commit `1f87244db43ab5dc0b0bd3383009d4297b520cdd`): removed Studio-only import instructions; documented GitHub Actions original GLB generation/upload, asset provenance and validation, and explicit distinction between Model asset IDs and MeshPart MeshIds.
- No asset upload, mesh insertion, runtime test or new CI verification performed in this checkpoint. Existing original-cloud upload workflow outcome remains unknown. No acceptance checkbox changed.
- Next: inspect `Import Original Cloud 3D Model` Actions run and moderation/asset artifact, then build an ownership-validated Model insertion adapter with procedural fallback; verify actual appearance in Roblox on mobile.

## 2026-11-09 — first 3D audit task implemented (source-level gate)
- Added `scripts/audit_3d_world.py` (commit `6cd5e5f9b1b10b782992cfaee338e3b5506d0a0d`). It scans all Luau server/client source, reports actual Roblox 3D constructors and GUI constructors separately, and fails on GUI creation in server world scripts or explicit 2D world-object stand-ins. Legitimate ScreenGui/CanvasGroup client UI remains allowed.
- Wired this audit into `.github/workflows/auto-publish.yml` after unit tests, commit `8dea4cb1d2775d7ee3d68990bb8c873d3434b377`. This commit triggers a production publish workflow; **run result and Roblox Published status still require inspection**. This is a static-source audit, NOT proof of visual correctness or imported meshes.
- Code inspection of `src/server/StarterWorld.server.luau` and `src/server/CloudCatch.server.luau` confirms Parts, Models, SpawnLocation and cloud 3D visuals; HUD source path and complete source tree not independently enumerated yet. **Not a complete 3D audit**. Keep Notion audit task unchecked until full audit results and generated place inspection are reviewed.
- Next: inspect workflow logs and audit output; inspect other scripts and generated place; validate cloud upload and insert 3D model with safe fallback; obtain Android play-test screenshots. Avoid claiming game ready to test until a fresh Published run is confirmed.

## 2026-11-09 — FIRST REAL ANDROID SCREENSHOT; UI corrections
- Owner supplied an actual Android Roblox screenshot (recents thumbnail). It clearly shows overlapping level/quest/status HUD and an overlarge always-visible collection panel. It also shows procedural 3D tree/cloud/crystal geometry; **not proof of imported mesh models**. Roblox Open Cloud Published run 42625022008 succeeded (67 tests, 3D source audit, Rojo, HTTP 200) but the visual QA revealed a real problem missed by static tests.
- Changed `src/client/CloudCatch.client.luau` to separate level/status/quest placements, constrain label sizes, reduce text, and center a smaller tutorial (`d6becd67`). Changed `src/client/Inventory.client.luau` to hide collection until user taps Collection (`99f93b48`). Both pushed to main; **new publish workflow result not yet verified**. Must inspect CI and ask owner for a full-screen new screenshot.
- Procedural Roblox Parts are 3D, but no imported external MeshPart cloud asset is verified. Next: inspect original-cloud upload workflow, integrate genuine model/mesh assets, further mobile UX QA. Do not mark complete.

## 2026-11-09 — real 3D Roblox Model package integration adapter
- Added a guarded, **disabled until confirmed asset ID** Model package loader in `src/shared/CloudVisuals.luau` (`cf89c7ac`). It uses server InsertService:LoadAsset only when `VERIFIED_CLOUD_MODEL_ASSET_ID` is configured, caches geometry, copies only BaseParts (discarding scripts/remote/non-geometry children), recolors/anchors/noncollides, and falls back to existing procedural 3D puffs on failure. Distinguishes Roblox Model package ID from MeshPart.MeshId.
- Updated `src/server/CloudCatch.server.luau` (`bd45fcee`) to track all descendant BaseParts so nested imported Models bob correctly, instead of only immediate children.
- **No uploaded Model ID was available/verified** and the configuration is nil, so the live game will still use procedural puffs. Need inspect import workflow logs/artifact, verify actual creator-owned model ID and InsertService permissions, then set ID and validate in Android runtime. This source push triggers CI/publish; status not checked. Not a claim that imported models are visible yet.

## 2026-11-09 — ORIGINAL GLB CLOUD UPLOAD VERIFIED AND ENABLED
- Inspected GitHub Actions run `42624259940` job `129183845390`: success, 16,852-byte original GLB generated, 5 meshes validated, Roblox returned `Uploaded model: assets/104852877755332`, artifact `13678575138` created. Creator ID `7550783083`.
- Enabled Model asset `104852877755332` in `src/shared/CloudVisuals.luau` with modern `AssetService:LoadAssetAsync`, preserving geometry-only copy and procedural fallback (`24f09786`). Model asset ID is **NOT** MeshPart.MeshId. Registered in ASSET_REGISTRY (`938108ab`).
- **NOT YET VERIFIED**: newest production auto-publish run after code commit, live model load permissions, correct size/pivot, mobile visual appearance. Owner can test after publish confirmation. Next: inspect Actions run and mobile screenshot; fix load/scale if fallback remains.

## 2026-11-09 — imported cloud geometry normalization
- Updated `src/shared/CloudVisuals.luau` (`94b3203361ba9c81184ea239416145c5c40582c9`) to cap copied imported BaseParts at 32, reject invalid geometry bounds, normalize largest dimension to 6 studs, and recenter the imported Model before positioning. This addresses likely GLB origin/scale mismatch; procedural 3D fallback remains.
- Confirmed prior GitHub handoff reports uploaded original Model `104852877755332` from successful workflow run `42624259940`; **not** a MeshPart.MeshId. No new external asset or ID introduced.
- This run did not independently confirm the latest auto-publish workflow or Studio/Android rendering. Next: check publish run, test loaded Model on Android, inspect fallback warnings, add automated tests for geometry bounds, continue 3D world and boss gameplay.


## 2026-11-09 — Starter island fall recovery (code only)
- Added `src/shared/RecoveryRules.luau`, `src/server/PlayerRecovery.server.luau` and `tests/RecoverySpec.luau`; registered three tests in `tests/run.luau` (commits d840894, 1b1a7c8, 2cdf9ba, cc5fd99).
- Server checks fallen characters near starter island at 4Hz, rescues to 3D spawn area and clears velocity; ignores distant locations to avoid interfering with future worlds. Pure policy tests cover threshold, distance, cooldown and invalid values.
- All geometry remains Roblox 3D; HUD remains legitimate ScreenGui. No external model imported in this run; original cloud Model ID 104852877755332 remains type Model, not MeshPart MeshId.
- **UNVERIFIED**: CI outcome for these commits, live auto-publish, Roblox runtime/mobile, spawn safety and visual correctness. Never check launch acceptance until verified. Next: inspect publish gate and actual in-game behavior; integrate additional worlds and gameplay.

## 2026-11-09 — Deep-void rescue hardening (automation)
- Changed `src/shared/RecoveryRules.luau` to rescue players who fall below -500 studs even outside the starter island radius; previously those players could fall forever. Normal nearby recovery at -85 remains, with the existing cooldown. Added finite-value, nonnegative-distance and monotonic-time guards.
- Added two test cases in `tests/RecoverySpec.luau` for deep-void rescue and invalid inputs. Implementation commits `1b01d64e`, `9a8c9798`.
- This is actual Roblox 3D character/physics policy, not a 2D world object. No new mesh/GLB was sourced; existing Model asset `104852877755332` is still a Model, not a MeshPart MeshId. ASSET_REGISTRY remains unchanged because the asset inventory did not change.
- **Unverified:** latest CI execution, Published Open Cloud result, in-game fall behavior, and mobile visuals. Keep acceptance checklist open. Next: inspect publishing workflow result, Android test, world checkpoints and playable boss encounters.

## 2026-11-09 — second Android screenshot UX QA
- User supplied full-screen landscape Android screenshot. XP/status/quest labels overlap; Tools and Collection buttons cover Roblox movement joystick. Avatar appears on/against a tall tree trunk; investigate collision/spawn/camera separately. Trees are clearly procedural Part-based 3D; screenshot cannot prove GLB cloud Model loaded.
- Concurrent agent had already moved `message` to top y18 and quest/level to y118 in `CloudCatch.client.luau` (latest main), so did not overwrite its newer change. Moved `Collection` toggle/panel to right side (`e149b2fd`) and `Tools` button/panel to right side (`2c8e9142`) away from movement joystick. New CI publish and Android visual results not verified.
- Next: confirm CI publish, inspect fresh screenshot, review cloud model runtime loading and player spawn/collision; improve responsive HUD instead of overlapping fixed-width labels.
