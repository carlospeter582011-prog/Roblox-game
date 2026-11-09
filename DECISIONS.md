# Decisions

| Date | Decision | Reason | Alternatives considered |
|---|---|---|---|
| 2026-11-09 | Put game rules in pure Luau modules tested by the plain Luau CLI in CI | No Roblox Studio/runtime is available to the agent; this is the only automated test path | Wait for Studio playtests only (no regression safety); TestEZ (needs a Roblox runtime) |
| 2026-11-09 | Session lock stored inside the profile record (jobId + timestamp, 300s stale timeout) | Prevents two servers overwriting one player's data without external services; autosave refreshes the lock | ProfileService/ProfileStore library (third-party dependency to vet); no locking (data loss) |
| 2026-11-09 | Kick the player when the profile cannot load or the lock is lost | Playing on an unsavable profile loses progress | Let them play un-persisted (silent progress loss) |
| 2026-11-09 | Baseline preserved as branch `baseline/house-car-prototype` | The session's git proxy refuses tag pushes (HTTP 403) | Tag (not possible here) |
| 2026-11-09 | Removed the house-and-car prototype from the new game | It is a proof of concept, not the approved design; the car asset's license/source is unrecorded | Keep the car as a vehicle (blocked until license is established) |
| 2026-11-09 | Publish workflow runs the unit-test gate before publishing | Rules forbid publishing known-broken builds | Publish on build success only |
| 2026-11-09 | Q83 (collaborative island building) stays owner-only until the owner decides | Unanswered design question | Allow visitors/co-owners editing |
