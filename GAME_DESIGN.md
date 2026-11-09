# Catch a Cloud — Game Design (approved)

Source of truth for decisions: the Notion Project Hub
(https://app.notion.com/p/413edc0cac2381a4b42bd36df3e25183). The owner approved the design
(82 questions; Q83 collaborative island building is unanswered, provisional = owner-only editing).
Everything below is an approved **target**, not a statement of what is implemented.
See `ROADMAP.md` for status and `docs/game-design.md` for the short slice summary.

## Vision
A magical multiplayer sky adventure. Catch, collect, raise, evolve and fuse living clouds; build a
personal floating archipelago; explore 10 worlds to solve The Great Cloud Mystery (disappearing
clouds, unstable weather).

Version 1.0 targets: 10 worlds, 150+ cloud species, 15+ tools, 100+ quests, 10 bosses, hub,
building, trading, guilds, parties, racing, seasons.

Core loop: explore -> locate a living cloud -> chase and skill-catch -> collect -> bond/evolve/fuse
-> use on the island and while exploring -> unlock story and worlds.

## Systems
- **Catching and discovery:** skill-based chase/timing; beginner/advanced nets, vacuums, lassos,
  automated catchers. Rarity Common -> Secret; mutations (Golden, Rainbow, Electric, weather).
  World/weather/progression-sensitive spawns, fair rare discoveries. Encyclopedia, achievements.
- **Cloud lifecycle:** Cloud XP, evolution, branching elemental/duplicate fusion with previews and
  valuable-cloud protection; three-cloud teams (active/passive/production); personalities,
  bonding, cosmetics; break-friendly care.
- **Worlds and story:** 10 worlds (Sky Meadow, Rainfall Reef, Thunder Peaks, Sunset Dunes, Frost
  Spires, Bloom Gardens, Crystal Belt, Moonlit Isles, Stormheart Citadel, Lost Cloud Kingdom) with
  NPCs, bosses, secrets, puzzles, weather, day/night. No Robux world gates. Map, waypoints,
  gliding, rideable clouds, balloons, skyships, fast travel. Mystery Journal, 100+ quests,
  branching dialogue, solo-completable main plot.
- **Islands:** expandable starter island and archipelago; free placement with optional snap,
  rotate, preview, undo, saved layouts; habitats, jobs, production chains, capped offline
  production; showcases and moderated blueprints with complexity budgets.
- **Multiplayer and competition:** 16-24 players/server (subject to performance); co-op catching,
  parties, guilds, visits, safe trading and marketplace with history and anti-duplication; safe
  communication with filtering/reports; cross-server events; phased bosses, races, ghost replays,
  seasonal leagues, optional non-destructive rebirth.
- **Economy and monetization:** Coins, XP, upgrades, crafting, mastery, monitored sources/sinks.
  Cosmetic purchases and an optional cosmetic-only seasonal pass with a free track. **No** paid
  random loot boxes, pay-to-win, forced Robux world gates or manipulative pressure.

## Player experience and presentation
Luminous clouds, crystals and sky islands; polished adaptive UI. English and Arabic (RTL).
Mobile/tablet/desktop/console; touch and gamepad; third-person, optional first-person, flight,
vehicle and build cameras; LOD/streaming/configurable effects. Weather-responsive licensed audio.
First cloud catchable within 1-2 minutes; short skippable tutorial; safe recovery from falls and
stuck states. Mobile (Android tablet) is the primary test device.

## Release criteria
All essential approved systems implemented and integrated; game genuinely playable; assets
integrated and licensed; mobile controls functional; progression and persistence working; critical
tests passing; blocking bugs resolved; published; runtime behaviour verified as far as tools allow;
limitations and docs current. A passing build is not completion.
