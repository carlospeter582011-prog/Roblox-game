# Catch a Cloud — Agent Handoff

Updated: 2026-11-09
Status: Foundation branch created; no verified Catch a Cloud gameplay release.
Notion: https://app.notion.com/p/413edc0cac2381a4b42bd36df3e25183

## Verified baseline
- Existing private GitHub repository on main; Rojo 7.4.4 build and XML validation workflow.
- Existing deploy workflow is manual Saved-only, not live Published.
- No verified Roblox runtime or visual tests.

## Current milestone
M1: modular cloud catalog and catching foundation; then test and integrate with existing bootstrap.

## Decisions
- Initial owner-supplied game vision and 82-question design summary recorded in Notion.
- Collaborative island editing undecided: provisional owner-only permission.
- Server validates catch requests, distance and cooldown; client never grants inventory.

## Immediate next steps
1. Inspect existing Bootstrap scripts and shared modules before wiring.
2. Add first cloud spawning/catching loop and mobile input.
3. Add executable tests, run CI, inspect failures and fix.
4. Update this file and Notion with actual commit/test evidence.
5. Do not publish to live until runtime validation and release safeguards exist.
