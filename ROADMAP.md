# Roadmap

Status key: DONE (implemented, integrated, verified to the stated level), PARTIAL, TODO.
"Verified" means the evidence in `TEST_REPORT.md`; nothing is runtime-verified in Roblox yet.
Counts are rows in data files, not finished, distinct content.

| Milestone | Scope | Acceptance criteria | Status |
|---|---|---|---|
| M0 | Baseline, docs, CI audit | Baseline branch; docs current; CI audited | DONE (branch `baseline/house-car-prototype`) |
| M1 | Modular foundation and tests | Pure modules + CI unit tests; locked, retried, migrated profile | PARTIAL: logic DONE (67 CI tests); no Studio verification |
| M2 | Starter island, first spawn/chase/catch, mobile controls | First catch in < 2 min on an Android tablet; no Studio output errors | PARTIAL: code published, unverified on device |
| M3 | Collection, saving, encyclopedia | Collection persists across sessions/servers; encyclopedia UI | PARTIAL: counts persist (logic tested); HUD shows species n/total and %; no browsable encyclopedia screen |
| M4 | Growth, habitats, production | Cloud XP/evolution/fusion; habitats produce with offline cap | TODO |
| M5 | First world, boss, story | World 1 art/secrets, boss, quest chain, chapters | TODO (BossCatalog/WorldCatalog are unused data) |
| M6 | Travel and additional Places | Portals/teleport with failure fallback; cross-Place progression | TODO (TravelCatalog unused data) |
| M7 | Trade, economy, parties, guilds | Atomic trades, anti-dupe, party/guild flows | TODO |
| M8 | Scale content to launch targets | 10 worlds, 150+ distinct species, 15+ tools, 100+ quests, 10 bosses | TODO: 86 species rows (no distinct behaviour), 15 tools (numeric variants), 38 catch-count quests, 0 playable extra worlds, 0 boss fights |
| M9 | Optimization, localization, security, staged release, QA | Arabic RTL, perf budgets, exploit audit, sign-off | TODO |

## Next actions (in order)
1. Merge PR #13; confirm publish; owner plays the build on the tablet and reports.
2. Wire data-only catalogs into systems one at a time with pure logic + tests (encyclopedia, world unlock/travel, boss state machine, islands).
3. Species behaviour data model before adding more species.
4. Asset pipeline through Open Cloud (no Studio on the owner's device), recorded in ASSET_REGISTRY.md.
