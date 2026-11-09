# Catch a Cloud — Agent Handoff

Updated: 2026-11-09 — CatchRules extraction + Luau pin checkpoint
Notion: https://app.notion.com/p/413edc0cac2381a4b42bd36df3e25183 (read the "CANONICAL LATEST HANDOFF" section)
PR: https://github.com/carlospeter582011-prog/Roblox-game/pull/11 (open, unmerged)
Branch: feature/catch-a-cloud-foundation
Latest implementation commit: d7434f74ef3cb2c3b17b873cbd7533e138d163d8 (profile hardening was 67052d6f5c2444e2ec5fd7a707b68805416879e1)
Latest CI (both success for d7434f7): push run 42577681481, PR run 42577686783
  - `luau-tests` job (Luau pinned to release 0.746): luau-analyze on ProfileCore + CatchRules, `luau tests/run.luau` = 27 tests, 0 failed
  - `build` job: Rojo 7.4.4 build + XML validation + artifact upload

## Implemented in branch (NOT Studio/runtime verified unless stated)
- Procedural starter floating island with trees, crystals and spawn.
- Original multi-part cloud shapes with lightweight bobbing animation.
- Starter cloud spawning and server-authoritative distance/cooldown catch requests.
- Touch/desktop catch button.
- `QuestCatalog.luau`: 2 chapter-one quests, integrated into server profile updates and client tracker.
- `CatchToolCatalog.luau` (5 tools, server-enforced range/cooldown/reward) + `CloudTools.client.luau` picker.
- **Profile persistence rewrite (commit 67052d6):**
  - `src/server/ProfileCore.luau` — pure logic, no Roblox globals: cross-server session lock (jobId + timestamp, 300s stale timeout), v2 envelope `{version, data, lock, savedAt}`, v1 flat-record migration, field validation (NaN/inf/negative/huge/unknown-quest rejected), refuses records from a newer schema, save only while lock is owned (`lost_lock` never overwrites the new owner), linear-backoff retry helper.
  - `src/server/ProfileStore.luau` — wires the core to DataStore/Players: load retries while another server releases the lock (5 tries, 3/6/9/12s), kick on locked/failed load, saves serialised per player, lost-lock => stop writing + kick, rejoin-on-same-server waits for the final save, player-left-during-load frees the lock, BindToClose saves in parallel (25s cap), autosave every 90s refreshes the lock. Same DataStore name (`CatchACloudProfiles_v1`) so existing v1 records migrate in place.
  - `tests/run.luau` — 14 tests against a fake DataStore (CI-verified, see above).
  - `.github/workflows/build.yml` — new `luau-tests` job; workflow now also runs on pushes to `feature/**`.
- **Catch rules extracted (commit d7434f7, behaviour-preserving):** `src/shared/CatchRules.luau` is pure (catalogs passed in): `resolveTool`, `canEquip`, `isInRange`, `coinReward`, `questProgress`, `applyCatch` (XP_PER_CATCH = 10, quest completion + rewards, sorted completed ids). `ProfileStore.AddCatch` and `CloudCatch.server.luau` now call it. `tests/CatchRulesSpec.luau` adds 13 tests, including data-integrity checks on the real species/tool/quest catalogs (ids match keys, numeric fields, quests reference real species, starter net always unlocked).
- Design/roadmap/handoff in Notion; `docs/game-design.md`.

## What is and is not verified
- VERIFIED (CI evidence): Rojo build, XML validity, static analysis of ProfileCore + CatchRules, 27 pure-logic unit tests (profile lock/migration/retry against a fake DataStore; catch/reward/quest rules; catalog integrity).
- NOT VERIFIED: anything in Roblox Studio or a live server. Specifically the real `UpdateAsync` cancel-on-nil behaviour, DataStore request budgets, `BindToClose` timing, Players event ordering, kick flow, client UI, mobile, multiplayer, art.
- `ProfileStore.luau`, `CloudCatch.server.luau` and everything under `src/client` have no automated tests (they depend on Roblox services).

## Known limitations / blockers
- PR #11 remains unmerged; no completed game URL exists. Deployment workflow is manual **Saved** only, not Published.
- If a final release-save fails after retries, the lock stays until the 300s timeout; the player may be kicked with "still open on another server" if they rejoin inside that window. Data from the failed final save is lost (autosave limits the loss to <= 90s).
- A corrupt in-memory field is reset to 0 on save by `sanitize` (progress loss rather than rejection); revisit if the profile grows.
- The refactor moved existing rules verbatim; the server wiring (`CloudCatch.server.luau`, `ProfileStore.luau` calling `CatchRules`) is still untested outside CI's build/XML check.
- Cloud visuals are procedural primitive art, not professional final assets.
- Content far from launch targets: 2/150+ species, 5/15+ tools, 2/100+ quests, 0/10 worlds beyond the starter island, 0/10 bosses, no islands/trading/guilds/travel/economy/localization.

## Exact next actions
1. Data-model step for scale: design the species data schema (spawn rules, rarity weights, mutations) as pure, tested modules before adding species; add a deterministic spawn-roll function with an injected RNG.
2. Add leveling/XP curve as a pure module with tests (XP currently only accumulates).
3. Roblox Studio runtime + mobile + 2-server lock playtest of the profile flow (needs the owner's Studio; preserve evidence).
4. Expand content in dependency order (species data model -> 15 tools -> quest engine -> world 1), each with acceptance tests; do not count placeholders.
5. Merge/publish only after verified integration, security review and release readiness; update Notion and this file with commit SHAs and test evidence.

No background agent has been scheduled. Continue in an active session or configured automation.

## Agent restart instructions — canonical
1. Read the Notion Project Hub's CANONICAL LATEST HANDOFF section and launch checklist; all checklist boxes stay unchecked until runtime-verified.
2. Read this file, PR #11 and the branch code; do NOT repeat the 82-question design interview.
3. Existing code is partial, not a launch. Do not merge/publish without integration/runtime/security validation.
4. CI proves build packaging and pure-logic tests only; it is not gameplay proof.
5. Sandbox cannot reach the Luau/Rojo hosts; tests run on GitHub's runner. Push to the branch and read the run (`gh run list/view -R carlospeter582011-prog/Roblox-game`).
6. After each milestone update this file and the same Notion hub with commit SHA and test evidence.
