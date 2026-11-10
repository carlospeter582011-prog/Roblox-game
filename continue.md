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

## 2026-11-09 — second Android screenshot HUD QA
- Actual screenshot shows XP/quest/status overlap and bottom-left controls overlapping mobile joystick; 3D geometry visible but imported GLB appearance not proven.
- Pushed `CloudCatch.client.luau` commit `5025a5dd`: separate level top-left and quest top-right, show catch messages temporarily rather than a permanent centered instruction. Pushed `CloudTools.client.luau` commit `d0f5d37e`: Tools moved away from joystick.
- Concurrent agent updated `Inventory.client.luau` to position Collection top-right; a 409 conflict was detected, so latest file was re-read and preserved, not overwritten.
- New CI/publish and actual Android appearance still unverified; inspect latest workflow and screenshot. Investigate player standing on tall trunk and model runtime visibility.

## 2026-11-09 — mobile Collection vs Jump collision fixed in source
- Owner provided new full-screen Android screenshot: Collection button at bottom-right overlays Roblox's native Jump control, blocking jumping. Second recents screenshot shows expanded Tools menu; not a full-screen view.
- Updated `src/client/Inventory.client.luau` (`c1d9539c`) to position Collection button top-center at (0.5, 158px) and its hidden-by-default panel below at (0.5, 198px), anchored centrally, away from Jump and movement joystick. Tools remains left below HUD; Catch remains right. Preserve native Roblox Jump button.
- Need inspect new auto-publish workflow and retest actual Android display before marking visual QA complete. Existing cloud Model import runtime appearance also still unverified.

## 2026-11-09 — 3D world visual overhaul, phase 1
- Based on Android screenshots, fixed climbable tree trunk/underside rock collision in `WorldAssetModels.luau` and added three tiered 3D canopy levels to trees (commit `ccca3805`). This targets player standing atop a tall trunk and simplistic sphere-only trees. Existing 5 spherical foliage parts remain for rounded fantasy styling.
- Improved `StarterWorld.server.luau` floating-island underside with 12 staggered noncollidable 3D slate cliff ledges; disabled collision on decorative base cylinder; changed spawn pad from bright Neon to subdued semi-transparent SmoothPlastic; reduced ambient/lighting brightness (commit `e8b568a4`).
- Changes are genuine Roblox Parts/Models, not Canvas. They do NOT replace all trees with imported meshes. Uploaded cloud GLB Model asset `104852877755332` is configured in `CloudVisuals.luau`, but actual runtime appearance/load is unverified; need screenshot/diagnostics. Current production CI/publish status also unverified.
- Next: verify workflow, inspect Android screenshot for spawn/clipping, improve mesh asset integration and cloud variety; avoid claiming full game complete.

## 2026-11-09 — mobile screenshot: cloud/tree source verified in code, UI controls revised
- Screenshot in Android recents shows 3D world geometry (not Canvas). `WorldAssetModels.tree` creates Roblox Model/Part trunk, foliage balls and canopy tiers, **not imported tree MeshPart** (`Assets.MeshIds.tree=nil`). `CloudVisuals.createCloudVisual` attempts Roblox Model `104852877755332` through AssetService and otherwise creates six 3D Part puffs; image alone cannot distinguish imported Model from fallback. Neither is Canvas.
- Pushed `Inventory.client.luau` `78417fab`: Collection moved beside Tools at x=112, y=144, panel x=112 y=184; no longer centered or on native Jump.
- Pushed `CloudTools.client.luau` `88863bb4`: Tools y=144, compact scroll panel y=184, selected/locked tool feedback and active button name; existing equip remote remains server-authoritative. Need test in live Roblox.
- Pushed `CloudCatch.client.luau` `81d90f7c`: wallet level/coins readout increased to 290x40, font 16.
- Pushed `CloudVisuals.luau` `f112ea66`: `VisualSource` attribute on each cloud visual distinguishes `ImportedRobloxModel`, `MeshPart`, `Procedural3DParts`; `ModelAssetId` attribute for imported; log failure reason. Inspect live instances or server logs to confirm model load, not screenshots alone.
- Changes not yet validated by newest CI/Roblox runtime; verify publish and user mobile QA. Next implement true imported tree model and check cloud runtime load permissions.

## 2026-11-09 — larger island, spawn/UI and coin-based tool shop
- Expanded walkable island from 95x95 to 205x205, decorative base 115 to 225, moved trees/arches/cliffs outward, moved spawn to (0,2,-25) to clear central trunk; cloud spawns now spread across +/-72 studs (`155676be`, `6afb5d5`). No Roblox runtime test yet.
- Tutorial reduced to short prompt near upper center and dismisses after 7 seconds (`b8591c6`, `3fe8d32`), to avoid overlap with wallet/quest.
- Tool purchases implemented: prices 5 coins per required catch (minimum 50), starter free; server validates coin balance, catch unlock and ownership; purchased tools are stored in `ProfileCore` ownedTools and replicated via `OwnsTool_` attributes; server only allows owned tools to equip; client displays Buy/Equip/Equipped (`c1ff741`, `488d529`, `116b7b8`, `6afb5d5`, `6ffcb8f`). Existing profiles migrate with starter ownership. **Not yet tested in live game; review CI and purchase/save/rejoin behavior before marking done.**
- Multiplayer: players who join the same Roblox server share the same Workspace/map/cloud spawns; per-player coins and ownership remain separate. Joining same experience alone does not guarantee same server.

## 2026-11-09 — original 3D navigation markers
- Added original `SkyLantern3D` model in `WorldAssetModels.luau` and five non-colliding lanterns near the starter spawn in `StarterWorld.server.luau`. Uses actual Roblox Model/Part/PointLight geometry; no Canvas stand-ins, external assets or new asset IDs. Commits: `89a6aca`, `2be3f76`.
- Registered original geometry in ASSET_REGISTRY.md. This is an incremental environment/navigation improvement, not a completed world.
- CI, Published upload, mobile visual readability, placement and runtime are **not yet verified** for these commits. Keep all full-launch acceptance boxes unchecked. Next: inspect the new auto-publish run, check actual Roblox appearance, fix overlap/layout, then implement playable world mechanics and bosses.

## 2026-11-09 — spawn-aware fall recovery
- RecoveryRules.recoveryPosition (75b122f), PlayerRecovery (bbaedc8), and two pure tests (b07eb0a): rescue now targets the actual SkyArrival SpawnLocation with safe clearance instead of hardcoded (0,9,0). Missing spawn fails closed. No Canvas world art added.
- GitHub combined status and PR-run lookup returned empty; these do NOT establish publish failure or success. Push-triggered auto-publish, CI and Roblox runtime remain unverified.
- No new GLB imported. Model asset 104852877755332 is NOT a MeshPart MeshId. Next: inspect publish job logs, Android rescue, then real world/boss gameplay.

## 2026-11-09 — server-validated Sky Crystal discovery
- Commit 57c66e0c04d93b639aa13fbd6fa749afc2587ee9 adds native ProximityPrompt interactions to up to 18 actual SkyCrystal3D objects on StarterWorld. Server checks character distance, limits each crystal to one discovery per user per server session, and exposes session-only SkyCrystalsDiscovered/LastSkyCrystal attributes. No currency, persistent quest state or remote trust introduced.
- GitHub connector write confirmed. No CI, live Roblox or mobile runtime test confirmed for this change. No external asset imported; Model ID 104852877755332 remains distinct from MeshPart IDs.
- Next: inspect CI/publish results; connect discoveries to validated persistent quest progression and visual feedback; verify touch/gamepad interaction in Roblox.

## 2026-11-09 — Crystal discovery security and lifecycle hardening
- Added pure `src/shared/CrystalRules.luau` with finite distance / index bounds, duplicate and profile-readiness checks (commit `04f9e95`).
- Added four unit cases in `tests/CrystalRulesSpec.luau` and registered in `tests/run.luau` (commits `1e7eea4`, `eaa9920`).
- Updated `StarterWorld.server.luau` (commit `6e16aa2`) to reject dead/unloaded players, enforce profile-ready, track crystal discoveries in a bounded per-user table, clean it on PlayerRemoving, and recompute count from validated keys rather than trusting a client-facing attribute.
- Crystal discoveries remain session-only; do NOT claim persistent quest/currency rewards. All objects remain native 3D Roblox Parts/Models; no new GLB or asset IDs.
- Source commits confirmed. CI and Open Cloud Published status for these commits NOT verified; Studio/Android runtime and actual imported cloud Model appearance NOT verified. Keep launch/3D checklist acceptance unchecked.
- Next: check push-triggered CI and publish logs, implement persistent discovery with a schema migration and tests, and add playable world/boss logic.

## 2026-11-09 — persistent crystal discoveries (source-only checkpoint)
- Implemented persistent `crystals` index set in ProfileCore schema v3, migration/sanitization for indices 1–18, and server-authoritative `ProfileStore.DiscoverCrystal` with duplicate rejection. StarterWorld prompts now read the loaded profile rather than session-only discovery table. Two profile roundtrip/sanitization tests added to `tests/run.luau`.
- Commits: `8e89241a`, `a7c45758`, `acc4fbd5`, `5c774323`. No new assets or 2D world geometry; existing SkyCrystal3D is native Roblox Model/Parts. Imported cloud `104852877755332` is a Model asset, not a MeshPart MeshId.
- **Unverified:** CI execution, auto-publish result, real DataStore save/rejoin, mobile prompt UX, runtime and 3D model load. Do not check launch acceptance yet. Next: inspect push-triggered workflow logs and repair any failing Luau tests; test actual persistence on Roblox before claiming complete.


## 2026-11-10 — Crystal discovery economy integration (source only)
- Added fixed 10 Coins and 5 XP for each first-time SkyCrystal3D discovery, awarded server-side inside `ProfileStore.DiscoverCrystal` only after persistent duplicate guard. Wallet, XP and level player attributes refresh immediately. `CrystalRules.reward` rejects duplicate/invalid IDs. Commits: `f76cdaea`, `f0a15096`, `b39f3fb2`.
- Added two pure CrystalRules reward tests. Crystal visuals remain native Roblox Model/Part with ProximityPrompt; HUD ScreenGui remains permitted. No new GLB, Model ID, MeshId, or third-party license. `ASSET_REGISTRY.md` requires no new asset entry.
- Verification pending: CI execution, push-triggered publish outcome, Roblox Android runtime, rejoin persistence and wallet/level display. Do not mark checklist acceptance complete based on commits. Next: inspect push workflow, verify reward persistence, build playable world/boss systems and finish imported 3D asset QA.

## 2026-11-10 — CI regression repair (verification pending)
- Investigated failed push Auto Publish run [42709746422](https://github.com/carlospeter582011-prog/Roblox-game/actions/runs/42709746422): 82 Luau tests, 1 failure in legacy v1 migration assertion (`expected 2, got 3`); publish step was **skipped**, not successful. The `os.exit` nil traceback is a secondary test-runner symptom after failure.
- Commit [12a9a858](https://github.com/carlospeter582011-prog/Roblox-game/commit/12a9a858667d01887e8fb71286bce619151f100b) updates test to assert `ProfileCore.SCHEMA_VERSION` and checks that migrated v1 profiles initialize an empty crystal discovery table. No production save schema was downgraded.
- New gated push run [42718188577](https://github.com/carlospeter582011-prog/Roblox-game/actions/runs/42718188577) was queued at inspection; inspect final result and logs before claiming tests or publication passed. Roblox runtime/mobile verification remains unavailable; all 3D-only acceptance checkboxes remain open.
- Next: if gate passes inspect Published upload evidence; then review gameplay integration, mobile controls and 3D-only world audit without treating Model IDs as MeshPart IDs.

### 2026-11-10 follow-up on gate
- Run [42718188577](https://github.com/carlospeter582011-prog/Roblox-game/actions/runs/42718188577) failed: 82 tests, one failure because the added assertion inspected the sparse raw stored record instead of sanitized `result.data.crystals`. Publish skipped again. Corrected the assertion in commit [5a1f8ee](https://github.com/carlospeter582011-prog/Roblox-game/commit/5a1f8ee65ac1e2932a590de3c8f0bd7dd0d0f8a4). Await a new completed push run before claiming green CI/publish.

## 2026-11-10 — Crystal usability / glare feedback
- User reports crystal interaction does not work and crystals are excessively shiny; also reports a long central stick and tools lacking satisfying utility.
- Commits d94da7f and 2bfa984: crystal prompts now anchor above primary shard with 16-stud activation, visible indicators and AlwaysShow; server records success feedback attribute. Crystal fallback shards changed from Neon to Glass with dimmer PointLights. These are source fixes, **not runtime verified**.
- Central stick identity remains unverified; do not remove arbitrary world geometry until source or screenshot identifies it. Existing tools have range/cooldown/coin modifiers but need meaningful active gameplay and UI feedback. Audit pending.
- Next: CI/publish status, Android prompt test, visible discovery feedback HUD, identify/remove central obstruction, meaningful tool actions, gameplay progression, tests and 3D-only asset QA.

## 2026-11-10 — Player feedback follow-up: HUD and central sightline
- Commit `b8c47ce`: mobile Catch HUD now shows the equipped tool's actual range bonus and displays 3-second crystal reward/discovery feedback with 0–18 count, based on server player attributes. This improves visibility of existing tool bonuses but does **not** constitute unique active tool abilities.
- Commit `adb634f`: removed the center x=0 lantern post from the spawn approach; four real 3D lanterns remain. **Unconfirmed** whether this was the exact long stick the owner reported; screenshot/runtime check still needed.
- Previously committed crystal ProximityPrompt/glare fixes still require Android runtime verification. No new GLB or Mesh IDs; existing Roblox Model ID is not a MeshPart ID.
- Outstanding: genuinely distinct tool abilities (magnet pull, vacuum multi-target, traps), rewarding quests/bosses, 3D audit, latest GitHub Actions publish evidence and mobile playtest. No runtime or publish success claimed.

## 2026-11-10 — Storm Vacuum active gameplay
- `a3739a3`: Storm Vacuum now performs a server-authoritative burst of up to 3 clouds per activation (target plus 2 closest in tool range). Existing unlock, ownership, cooldown, range, persistence and rewards still apply. Each captured cloud is removed only after ProfileStore.AddCatch succeeds; replacements respawn after five seconds. No new RemoteEvent or client-controlled batch list.
- `f9825c9`: tool picker explicitly labels its `3-cloud burst` ability.
- Source implemented, **NOT verified** by CI or Roblox runtime; potential race and balance need live testing. Follow-up: add deterministic pure targeting tests, additional distinct tools, inspect auto-publish, test on Android. No 3D assets or Model/Mesh IDs changed.

## 2026-11-10 — Storm Vacuum burst correctness and tests
- Commits `3ddc0a5`, `947116f`, `01605a4`: moved multi-target selection to pure `CatchRules.selectBurstTargets`, reused by server for Storm Vacuum; deterministic nearest-first order, stable tie-breaking, duplicate/invalid candidate filtering, max 3 targets. Added two CatchRulesSpec tests for ordering and limits. No client-supplied target lists or new RemoteEvents.
- **Unverified**: CI test execution, Open Cloud Published acceptance, Android runtime/balance. GitHub commit-workflow lookup only exposes PR runs and cannot establish push auto-publish status. Check Actions push workflow separately. No new assets; ASSET_REGISTRY inventory unchanged.
- Next: inspect CI/publish, test 3-cloud burst in multiplayer, add meaningful Cloud Magnet ability and bosses, maintain 3D-only audit.

## 2026-11-10 — Catch runtime bug fix and Cloud Magnet ability
- Fixed a confirmed source-level runtime bug in Storm Vacuum: `visuals[target.id]` indexed nonexistent `target`, causing an error after successful catch. Commit `bf44e497`. This may have broken both ordinary and burst catches after profile reward; needs Android verification.
- Added Cloud Magnet active extended-range catch field (+12 studs beyond its existing tool bonus), checked only against server-resolved equipped/owned tool and valid finite distance: pure policy `bceb1dc`, server integration `0b14af4`, policy tests `678feed`, UI label `feaa681`. Catch button still selects nearest server-replicated cloud; server validates reach and awards via ProfileStore. No new 3D asset.
- Tests committed but CI execution/Published upload and Roblox runtime remain **unverified**. Next: inspect push Actions via available API, test catching on Android, verify tool ability balance, implement physical magnet effect and next world/boss gameplay. ASSET_REGISTRY unchanged because no assets added.

## 2026-11-10 — Catch reliability and early-game density
- Fixed **second** undefined `target` variable reference in `CloudCatch.server.luau` (`visuals[target.id] = nil`) after prior partial fix; commit `b220b5a`. This was a real source-level error affecting successful catches; no Roblox runtime verification yet.
- Doubled simultaneous real 3D cloud population from 6 to 12 and reduced random spawn bounds from ±72 to ±55 studs around origin to improve early-game activity; commit `6f51b26`. Models remain real 3D Roblox Parts/Models; no GLB/asset IDs changed.
- Mobile Catch label shortened to `Catch +N`, and client avoids requests to clouds beyond 48 studs with clear move-closer feedback; commit `d02cd0c`. Server remains authoritative for catch reach, ownership and rewards.
- TODO: CI and Published upload evidence, Roblox Android catch and UI playtest, verify cloud spawn is reachable from islands, balance population and implement quests/bosses. ASSET_REGISTRY unchanged (no new assets).

## 2026-11-10 02:13 Cairo — reachable-target mobile catch fix
- `d031e77`: mobile Catch button now picks the nearest cloud **within actual species catch radius + server-catalog tool range**, including Cloud Magnet's +12 field. Previous nearest-only + arbitrary 48-stud guard could choose an unreachable species despite another catchable cloud being available. Server still enforces all ranges/ownership/cooldown; client is only UX targeting.
- `afc8bb9`: ASSET_REGISTRY.md documents a partial 3D source audit of invisible Part hitboxes plus real 3D cloud Model assemblies, HUD exemption and Model-vs-Mesh ID distinction. No external assets added; full 3D runtime audit remains open.
- Workflow evidence: GitHub Actions run 42718188577 returned completed/failure (historical, not this commit). Connector's commit-workflow lookup only returns PR-triggered runs; current push auto-publish success **not verified**. Do not mark published. CI and Roblox Android playtest remain open.
- Next: inspect current push Actions in browser/with capable API; verify 3D cloud spawn accessibility and touch HUD; build more substantive world content and quest/boss systems.

## 2026-11-10 03:14 Cairo — catch cooldown correctness and real 3D feedback
- Commit `1afdd53`: moved catch cooldown consumption *after* valid active cloud, live character and server-authoritative range checks. Stale IDs/out-of-range targets no longer burn the cooldown; successful attempts retain the existing tool cooldown.
- Commit `493fcfa`: successful catches now spawn a brief server-replicated, original Roblox `Part`/ForceField pulse, with TweenService fade/expansion and Debris cleanup (0.45s). Magnet catches get cyan pulse. No Canvas/2D in-world substitute or external asset ID.
- `45266dd`: registered 3D catch pulse in ASSET_REGISTRY.md. This is source implementation only, not Studio visual verification.
- Historical GitHub Actions run [42718188577](https://github.com/carlospeter582011-prog/Roblox-game/actions/runs/42718188577) inspected: build-and-publish failed at static-analysis/unit-test release gate, build/artifact/publish all skipped. **This historical failure is not a result for today's commits**. Current push CI and Published upload cannot be confirmed with available commit workflow lookup; do not claim deployed.
- Next: inspect latest push workflow in GitHub Actions with capable endpoint, diagnose any current gate failures, Android multiplayer playtest, 3D-only audit of remaining world objects, improve missions/world progression and verify live visuals.

## 2026-11-10 04:20 Cairo — Third playable 3D region and spawn rotation
- Built **Thunderhead Ridge** as a third connected, walkable original 3D island at x=315, with real Part bridge overlapping Eastwind Outlook, 9 slate spires with glass crowns, arch, lanterns and floating bedrock; commit [73e85c4](https://github.com/carlospeter582011-prog/Roblox-game/commit/73e85c4ac34f6a8b2e72b068b75a3c2ec166df0c). This is substantive world expansion, not an in-world 2D Canvas. Bridge geometrically overlaps the Eastwind floor (ends x=213–267; Eastwind ends x=220; Ridge starts x=260).
- Clouds now spawn on all three islands; moved bounds/rotation to pure `SpawnRules.regionBounds` and stamped `SpawnRegion` attribute on the server cloud hitbox. Commits [136099a](https://github.com/carlospeter582011-prog/Roblox-game/commit/136099a7206d076b4e3613ce54dd4f98fdca3440), [1fe135a](https://github.com/carlospeter582011-prog/Roblox-game/commit/1fe135a8685e08de636603817320f5c56e484158), [ccf12c2](https://github.com/carlospeter582011-prog/Roblox-game/commit/ccf12c26ac930b41abdb360ce9d264fc7c93f3ee). Spawn schedule 3/5 starter, 1/5 Eastwind, 1/5 Ridge.
- Added a pure Luau test for region rotation, input validation and floor bounds: [a0ec28f](https://github.com/carlospeter582011-prog/Roblox-game/commit/a0ec28f8633379aba80489633f1a6b0dad14cdc5). Added original assets row and fixed malformed Markdown row separator in [ASSET_REGISTRY.md](https://github.com/carlospeter582011-prog/Roblox-game/blob/main/ASSET_REGISTRY.md), commit [940b65b](https://github.com/carlospeter582011-prog/Roblox-game/commit/940b65ba0e13a6c0b49379ed4902b9f12329d98c).
- **Verification:** Re-fetched five modified files from GitHub main and confirmed expected source content. Tests **not executed** in this run. Current push GitHub Actions workflow status, Open Cloud upload/publish and actual Roblox mobile/Studio runtime **unverified**; connector only exposes PR-filtered commit workflow lookup, not a current push-run listing. Do not mark live/published/visually verified.
- **Next:** obtain latest push-run gate/build/upload evidence; Roblox Android check bridge walkability and new spires, clouds, catching; continue 3D-only world audit, implement progression gates, boss encounter and gameplay beyond three regions. No new external GLB or unverified Mesh/Model IDs integrated.

## 2026-11-10 05:07 Cairo — Three-world fast-travel gameplay milestone
- Added persistent-capture-based fast travel thresholds to pure `SpawnRules`: Starter open, Eastwind at 25 catches, Thunderhead Ridge at 75 catches ([rules commit](https://github.com/carlospeter582011-prog/Roblox-game/commit/d16aa1397b46d7d1d9acf73f70241627e773b25e)). No new DataStore schema; thresholds derive from saved capture total.
- Added five server-owned native Roblox 3D beacon stations with `Part` platform and glass beacon, `ProximityPrompt`, server-side distance/health/profile validation, 2-second throttle, CFrame teleport and return stations ([implementation](https://github.com/carlospeter582011-prog/Roblox-game/commit/6a669cb895394a86e8a6c7182108ab497cdc6aee), [hub placement](https://github.com/carlospeter582011-prog/Roblox-game/commit/794f35d0120a3f7ca874469eccd69612fb586559)). Walkable bridges remain accessible; this is a progression-based shortcut, not a hard island lock.
- Added HUD arrival/lock feedback ([commit](https://github.com/carlospeter582011-prog/Roblox-game/commit/cd3997f4f9cd16299e67eb703a3b051cef0dd46f)) and pure unit tests for unlock boundaries and invalid input ([commit](https://github.com/carlospeter582011-prog/Roblox-game/commit/81bc63a0d5781c5ae676fe8fe89957963f59cd0a)). `default.project.json` maps `src/server` into ServerScriptService, so the new server script is included by Rojo mapping in source.
- Updated [ASSET_REGISTRY.md](https://github.com/carlospeter582011-prog/Roblox-game/blob/main/ASSET_REGISTRY.md): original 3D Parts, no third-party GLB, no Roblox Model/Mesh IDs. HUD ScreenGui remains intentionally 2D. This is source-only 3D audit.
- **Unverified:** current GitHub Actions push run, Luau test results, Rojo build, Open Cloud Published acceptance, Studio/Android travel functionality and 3D visual placement. GitHub connector exposes PR commit runs only; do not claim success. Next: obtain current Actions evidence, fix failures, runtime test beacon placement, expand quests and bosses and complete all-object 3D audit.

## 2026-11-10 06:15 Cairo — 3D fast-travel portal geometry and landing safeguards
- Added five original native 3D portal arches (two pillars and one lintel per station) to WorldTravel.server.luau, avoiding Canvas/2D in-world stand-ins. On successful travel, clear linear/angular velocity before PivotTo to prevent carrying bridge momentum into arrival. Locked travel attempts no longer consume the successful-travel throttle. Commit [482089e](https://github.com/carlospeter582011-prog/Roblox-game/commit/482089e7e8ea3a440920954e97484a8541d4d5ec).
- Added pure-Luau unit test asserting all three travel landing positions are within their corresponding actual walkable floor dimensions and safe Y bounds: [86d7285](https://github.com/carlospeter582011-prog/Roblox-game/commit/86d7285a350bfb0dd1d4ba9876a009e8f7b1cdfc).
- Asset inventory records portal arches as project-owned Roblox Parts; no new external GLB, Model asset ID or MeshPart.MeshId: [c057e9a](https://github.com/carlospeter582011-prog/Roblox-game/commit/c057e9a7210e2a1103cdd084f26c86569ff088d3).
- Historical [Actions run 42718188577](https://github.com/carlospeter582011-prog/Roblox-game/actions/runs/42718188577) rechecked through GitHub connector: completed/failure. This is **not** evidence about current push. Connector exposes no general push-run listing; latest CI, Rojo build, artifact upload and Roblox Published upload are **unverified**. Unit test added, not observed passing. No Roblox Studio or Android runtime verification.
- Next: obtain actual current push-run evidence; verify station geometry and travel on Android, audit all remaining world objects; build playable world-specific boss encounters and progression, not just catalog entries.

## 2026-11-10 07:14 Cairo — Three playable boss catch trials (source only)
- Added pure `BossChallengeRules.luau`: Meadow Warden (0 catches unlock, catch 3 clouds/90s), Wind Guardian (25 catches, 5/120s), Stormheart Titan (75 catches, 7/150s); stable progress/status and timeout semantics. Commit `d50c3dc`.
- Added `BossTrials.server.luau` with three original **native 3D** anchored Roblox Model/Part boss statues and arenas on existing walkable islands. ProximityPrompt starts a server-authoritative timed trial; catches are read from `ProfileStore` (no client-trusted progress), cooldown on win/timeout, win counter session-only. Commit `5b8c279`. This is a timed catch challenge, **not** a combat AI boss and does **not** grant new currency/XP beyond normal catches. The win counter is not persisted; do not advertise permanent boss progression.
- Added three pure tests (`tests/BossChallengeSpec.luau`) and registered in `tests/run.luau`: commits `e3c3f40`, `a64b5a7`. HUD displays server-reported progress/feedback: `9e519e2`.
- Updated `ASSET_REGISTRY.md` for project-authored 3D boss assets: `43deb8c`. No external GLB or Roblox Model/Mesh IDs integrated. No in-world Canvas/2D replacements; existing ScreenGui HUD retained.
- **Unverified:** latest push CI, Rojo build, GitHub Actions artifact upload, Open Cloud Published acceptance and Roblox/Android runtime. Connector only exposes PR-filtered commit workflow runs, so an empty result cannot establish push status. No Studio screenshots or multiplayer evidence.
- Next: verify push workflow by GitHub Actions UI/API, inspect errors and fix if necessary; Android boss prompt/arena collision and actual cloud catch trial; persist boss completion via safe schema migration if desired; build distinct attack/phase AI, richer rewards, quests and remaining worlds. Full 3D audit still incomplete.

## 2026-11-10 08:12 Cairo — Boss trial phase progression
- Added 3-stage deterministic catch-trial phase calculation and stage messages in `BossChallengeRules.luau` (`95bf9f6`), server `BossChallengePhase` replication and feedback on phase changes in `BossTrials.server.luau` (`78ebd0a`), plus two tests in `BossChallengeSpec.luau` (`a10ed25`). Bosses remain timed catch trials, not AI combat or persistent rewards.
- Source-only 3D audit for this change: no new world objects, meshes, or 2D stand-ins; existing boss geometry uses native Roblox Model/Part. No external asset/Model/Mesh IDs introduced. ASSET_REGISTRY unchanged in content aside from this checkpoint.
- Tests written but not executed in this session; latest push CI, Rojo artifact and Open Cloud Published upload unverified. Runtime/Android multiplayer and boss phase UX unverified. Next: verify CI and publish via full Actions runs, make boss rewards durable, add distinct encounter mechanics and audit full world geometry.

## 2026-11-10 09:15 Cairo — Persistent boss trial currency/XP rewards
- Added catalog reward values for three existing catch trials (Meadow 75 coins/40 XP; Eastwind 175/85; Ridge 350/150) with `BossChallengeRules.reward` pure lookup: commit `c41a8d6`. `ProfileStore.AwardBossTrial` credits existing persistent `coins`/`xp` and replicates HUD attributes (no schema change): `61b9f44`. Server completion removes active trial before rewarding and only counts win on successful reward; expiry resets phase: `e18f830`. Pure unit test verifies known/unknown boss rewards and bounds: `16a0dd8`.
- GitHub Actions: PR-only commit workflow lookup returned empty for `16a0dd8` (not proof of push run outcome). Historical run 42718188577 had failed static/unit gate, skipped build, artifact and publish. **Current tests, Rojo build, artifact upload, Published acceptance, Studio/Android gameplay are NOT verified.**
- 3D-only source checkpoint: no new geometry or external assets in this reward change; existing boss arenas use native Roblox Parts/Models and ProximityPrompt. `ASSET_REGISTRY.md` updated. Original cloud asset 104852877755332 remains Model asset, not MeshPart MeshId.
- Remaining: inspect actual current push Actions and Open Cloud publish result, runtime test boss reward persistence/rejoin and cross-server multiplayer, add distinct boss mechanics and persistent victories, complete full-world 3D audit and professional licensed mesh integration.

## 2026-11-10 — Economy use and compact HUD (player-requested)
- Replaced oversized single-line Coins/XP/Level HUD with a narrow 150x90 left-aligned vertical stack of Coins, XP-to-next-level and Caught; commit `1fc4371`. Mobile shop remains at y=144, wallet y=46–136.
- Implemented permanent **Range Training** Coin sink: +2/+4/+6 studs cumulative range, costing 100/250/500 Coins, gated by XP Levels 2/4/6 respectively. Server-owned `ProfileStore.BuyRangeTraining` updates `data.rangeTraining` within existing session-lock persistence and replicates `RangeTraining` attribute; commits `bb53abf`, `4769f43`. Existing tool purchases remain available; the shop now clearly offers upgrades at the top (`764237c`), and catch client uses same range bonus (`65f9eab`). No Robux, randomness, or external assets.
- IMPORTANT: new profile field defaults to 0 for old saves; verify ProfileCore normalizes/preserves unknown fields, test persistence across rejoin and concurrent purchase in Roblox. Test and CI/Published upload **not verified** this run. Need add unit tests and improve richer progression/economy sinks next.

## 2026-11-10 10:08 Cairo — Persistent boss victory progression and Boss Journal
- Implemented persistent per-boss victory history for Meadow Warden, Wind Guardian and Stormheart Titan. ProfileCore default/sanitization allow only three recognized boss IDs and bounded nonnegative integer counts (commit `1370e2b`); ProfileStore credits a victory atomically with existing reward mutations, replicates individual and total win attributes on join and award (`746c196`). BossTrials removes prior duplicate session-only increment (`f394b73`). This is a saved achievement history, not yet combat AI or unique boss mechanics.
- Added accessible compact `Boss Journal` ScreenGui toggle displaying saved victories per boss (`af1c2c8`). New UI is HUD only; no in-world 2D stand-ins. Added fake-DataStore save/rejoin and malicious-field regression test (`f9668c9`). Tests are source committed, NOT executed/confirmed passing in this run.
- GitHub PR-filtered commit workflow lookup for `f9668c9` returned no runs. This cannot verify push CI, Rojo build, artifact upload, Open Cloud Saved or Published status. Roblox Studio/Android gameplay, persistence and visual layout remain unverified.
- Next: inspect real push Actions/Roblox evidence; run Luau tests and UI on Android; implement boss-specific interactive mechanics and first-clear achievements; continue 3D-only full world audit and remaining launch milestones.

## 2026-11-10 11:15 Cairo — Real 3D cloud companions (source checkpoint)
- New gameplay system: catch any species to automatically unlock a **visible personal 3D cloud companion**, then cycle among owned species using a touch-friendly button in the existing scrollable Shop. The selected species persists across rejoin and server revalidates ownership. Companion follows player as a non-colliding animated original 3D Model of Roblox Parts; no Canvas world stand-in or unverified external mesh IDs. Pure ownership/cycle rules: [435b22a](https://github.com/carlospeter582011-prog/Roblox-game/commit/435b22a3d66d0b77608a0a17aa64ec4871917f34); profile sanitation: [7c466a9](https://github.com/carlospeter582011-prog/Roblox-game/commit/7c466a95d47d35cff62dc019434bcff7d3d7a9c1); profile integration: [4dbcb8d](https://github.com/carlospeter582011-prog/Roblox-game/commit/4dbcb8d2fd253090a5e2c80da64a9c3195589699); server 3D model: [7fcdc25](https://github.com/carlospeter582011-prog/Roblox-game/commit/7fcdc252cf13124a59527957f289bebc9be0a38a); shop UI: [919a0fe](https://github.com/carlospeter582011-prog/Roblox-game/commit/919a0fe4ef630dd821211bf1155999fe4fdaa69d).
- Added fake-DataStore rejoin, unauthorized species, deterministic cycling and invalid selection regression tests: [f441042](https://github.com/carlospeter582011-prog/Roblox-game/commit/f441042f24e4d72679a86f5f156f82b6a14f34b3). **Not executed**, GitHub PR-filtered workflow lookup returned no runs; does not prove push CI. Rojo build, Open Cloud publish, Roblox Studio/Android visual and multiplayer runtime all unverified.
- Follow-up: actual in-game test for 3D positioning, server update performance and UI touch overlap; add cloud bond/leveling, abilities and care (current companion is visual, not functional gameplay power); continue all 10 worlds, quest/boss content and full 3D audit. Source changes are not full-game acceptance.

## 2026-11-10 — Companion bonding gameplay (automation run)
- Implemented earned per-species Companion Bond progression: each successful server-authoritative catch while an owned companion is equipped advances its Bond by 1; thresholds at 10/40/100 catches unlock Bond levels 1/2/3 and +2%/+4%/+6% bonus Coins on future catches. Bonus is calculated server-side from the catch base Coin amount and is capped by level. No paid boost, no random purchase.
- Persistence: `ProfileCore.defaultData/sanitize` now includes `companionBond` map with bounded integer values and safe species IDs, automatically migrating old records without a destructive schema reset. `ProfileStore` publishes `CompanionBondLevel` and `CompanionBondPoints` attributes on login/catch/switch; owned species are verified before earning.
- New unit test covers thresholds, cap, malformed values and save/rejoin. Commits: 5ef3e9e, 4139648, 8ae6cff, 76b88bb. CI workflow: https://github.com/carlospeter582011-prog/Roblox-game/actions/runs/42797257063 (queued when inspected; **not yet passed**).
- This is a partial companion gameplay system, NOT completed cloud raising/evolution/fusion. Roblox Studio/mobile appearance and live DataStore behavior remain unverified. Next: validate CI and publish; build visual Bond UI and meaningful companion abilities; continue distinct worlds/story and runtime QA.

- CI follow-up: [run 42797257063](https://github.com/carlospeter582011-prog/Roblox-game/actions/runs/42797257063) completed SUCCESS for 76b88bb; `build-and-publish` steps for static analysis/unit tests, Rojo build and `Publish to existing Roblox Place` all reported success. This is CI/publish-step evidence only, not proof of Roblox runtime appearance or DataStore persistence.


## 2026-11-10 — Companion follow smoothing and teleport recovery
- Commit `3016d4863a5190fbdc10ef3eaf489e53764d3216` updates `CloudCompanions.server.luau`: interpolates the real 3D Model companion pivot for smoother following, snaps immediately when the destination is 30+ studs away (fast travel/teleport), and resets smoothing on missing character, despawn, selection change and player leave. No Canvas world assets introduced.
- Verified by rereading source through GitHub connector. **No Roblox runtime, visual/mobile test, CI result or publish outcome verified in this run.** The change still requires CI and an Android fast-travel/respawn play-test; it is not a finished companion gameplay milestone.
- Next: inspect Actions status for this commit, test companion movement/teleports in Roblox, then implement distinct companion abilities and extend progression toward the complete design.

## 2026-11-10 — Elemental Companion Resonance (source implementation)
- Implemented a new gameplay ability for genuinely owned equipped cloud companions: after Bond level 1, catching another cloud with the **same element** grants +5%/+10%/+15% catch XP at Bond levels 1/2/3. Server resolves both species from CloudCatalog and validates ownership; mismatched elements, unknown species, unowned companions and malformed XP grant zero. Only catch XP is boosted; quest and boss rewards are unaffected. First-ever catch doesn't grant free resonance.
- Source commits: [rules 155a491](https://github.com/carlospeter582011-prog/Roblox-game/commit/155a491734d523583e8cca8b20760251557c535b), [ProfileStore 454f8e5](https://github.com/carlospeter582011-prog/Roblox-game/commit/454f8e5cb0214c4b461a22cef5091b43e246ddc4), [regression tests 1491161](https://github.com/carlospeter582011-prog/Roblox-game/commit/1491161bc9655f67675d15a835075fc10a3a0b91). New tests cover thresholds, cross-element rejection, ownership and invalid XP.
- [GitHub Actions run 42813189825](https://github.com/carlospeter582011-prog/Roblox-game/actions/runs/42813189825) was queued on inspection; CI/publish not yet verified for this change. Previous run 42805914177 passed for an older commit only. Roblox Studio/Android rendering, profile persistence and actual gameplay remain unverified.
- Asset audit: no new 3D asset, Canvas world object, MeshPart ID, or third-party license. Existing procedural Part/Model companion is unchanged. Next: confirm latest Actions and Open Cloud step logs; playtest resonance in Roblox, show readable bond/element/XP feedback in mobile HUD, add species-specific companion abilities and continue quests/worlds/bosses.

- CI follow-up: [run 42813189825](https://github.com/carlospeter582011-prog/Roblox-game/actions/runs/42813189825) completed **success** for test commit `1491161`; job `build-and-publish` reports success for static/unit test gate, Rojo build, artifact upload, and `Publish to existing Roblox Place` step. This is GitHub workflow-step evidence, **not** live Roblox Studio/Android gameplay or persistence verification. Documentation-only commits after `1491161` are not part of that run.

## 2026-11-10 15:10 Cairo — Air companion field ability
- Added server-authoritative Air companion catch reach: +1/+2/+3 studs at Bond 10/40/100; only owned, equipped Air companion qualifies. Calculated by `CompanionRules.airReachBonus` from saved server profile; integrated into `CloudCatch.server.luau` alongside permanent training. No client-controlled range values.
- Added `tests/CompanionAbilitySpec.luau` and registered in `tests/run.luau`: Bond progression/cap, unowned/unknown/non-Air/invalid data.
- Commits: [rules](https://github.com/carlospeter582011-prog/Roblox-game/commit/f41f610504d73b5868b8e4cd075e3cece2a51045), [catch integration](https://github.com/carlospeter582011-prog/Roblox-game/commit/10e6673c66eca9675860344f4d80fba4eda869ff), [test](https://github.com/carlospeter582011-prog/Roblox-game/commit/fcf0e92c12ce2ed9703e6517fcb090ff725fbe7b), [registration](https://github.com/carlospeter582011-prog/Roblox-game/commit/295d1f4d2d3e9c858939c41e05c15a89edeae049).
- CI status at inspection: [latest auto-publish run 42822233074](https://github.com/carlospeter582011-prog/Roblox-game/actions/runs/42822233074) PENDING; prior partial runs cancelled/in progress. **No verified CI success or Roblox publish for final commit; no Studio/Android runtime test.**
- Next: inspect final workflow test/build/publish jobs, fix any failures, visually test companion range on Android, and keep expanding distinct gameplay systems and full launch content. Existing 3D procedural models unchanged; no new assets or IDs.

## 2026-11-10 17:07 Cairo — Crystal constellation milestones (PR #30, draft)
- Branch `feature/crystal-constellation-milestones` from fresh main c135990. Added server-authoritative, one-time rewards on the sixth, twelfth and eighteenth unique crystal discovery: 150/400/900 Coins and 75/200/450 XP. Reuses the saved immutable crystal set as receipt; no extra schema or client-provided counts. Existing 3D ProximityPrompt path wired; feedback distinguishes milestones.
- Pure Luau regression cases cover milestone crossing, duplicates, invalid counts. [Draft PR #30](https://github.com/carlospeter582011-prog/Roblox-game/pull/30). No merge or publication. CI and Roblox runtime evidence pending; all launch checklist boxes remain unchecked.
- Concurrency: separate feature from open catching, bosses, quests, weather, travel and companion PRs. Before merging reconcile latest main and rerun CI. Verify 3D crystal reachability and mobile UI feedback in Roblox.
