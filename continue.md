# Catch a Cloud — Agent Handoff (continue.md)

[... previous content preserved in spirit; append new section ...]

## 2026-11-11 — Cloud Raising Rules (feature branch)
- Added pure `src/shared/RaisingRules.luau`: feeding costs 25 coins, adds 10 bond (capped at 1000), evolution ready at 500 bond.
- Tests in `tests/RaisingSpec.luau` cover basic canFeed cases.
- No schema migration, uses existing `companionBond`. Integration into server feed remote and UI pending.
- No external assets, Model/Mesh IDs or 3D geometry changes. ScreenGui for any future HUD only.
- Branch `feature/cloud-raising-rules-20261111`. CI, runtime, publish NOT verified. Do not mark launch tasks complete.
- Next: wire server remote with rate limits, update ProfileStore to persist bond (already does), add HUD feed button with mobile layout check, expand tests, then open PR.
