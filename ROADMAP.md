# Roadmap

Status key: DONE (implemented, integrated, verified to the stated level), PARTIAL, TODO.
"Verified" here means the evidence listed in `TEST_REPORT.md`; nothing is runtime-verified in
Roblox yet.

| Milestone | Scope | Acceptance criteria | Status |
|---|---|---|---|
| M0 | Baseline, docs, CI audit | Baseline branch exists; docs current; CI audited | DONE (baseline: branch `baseline/house-car-prototype` at cb91b2f) |
| M1 | Modular foundation and tests | Pure modules + CI unit tests; server-authoritative profile with session locking | PARTIAL: pure-logic part DONE (CI); no Studio verification |
| M2 | Starter island, first spawn/chase/catch, mobile controls | First catch in < 2 min on an Android tablet; no errors in Studio output | PARTIAL: code exists, unverified on device |
| M3 | Collection, saving, encyclopedia | Species collection persists across sessions and servers; encyclopedia UI | PARTIAL: counts persist (logic tested); no encyclopedia |
| M4 | Growth, habitats, production | Cloud XP/evolution/fusion; habitats produce with offline cap | TODO |
| M5 | First world, boss, story | World 1 art/secrets, boss, quest chain, chapters | TODO |
| M6 | Travel and additional Places | Portals/teleport with failure fallback; cross-Place progression | TODO |
| M7 | Trade, economy, parties, guilds | Atomic trades, anti-dupe, party/guild flows | TODO |
| M8 | Scale content to launch targets | 10 worlds, 150+ species, 15+ tools, 100+ quests, 10 bosses | TODO (2 species, 5 tools, 2 quests today) |
| M9 | Optimization, localization, security, staged release, QA | Arabic RTL, perf budgets, exploit audit, release sign-off | TODO |

## Next actions (in order)
1. Merge the foundation PR once gated CI is green (publishes via `auto-publish.yml`).
2. Owner plays the published build on the Android tablet and reports Studio-less runtime findings
   (the only available runtime verification path).
3. Fix what that finds; then the persistence data model for cloud instances (not just counts).
4. Tool/ability/spawn-rule data model; then World 1 content.
