# Asset Registry

Every asset used by the game is recorded here. Nothing is added to the game without a row.
Priority order: Roblox Creator Store -> licensed external (CC0 preferred) -> original.

| Asset | Source URL | Creator | License | Roblox Asset ID | Ownership / permissions | Integration | Validation |
|---|---|---|---|---|---|---|---|
| Cloud Crafting Workshop (base, pillar, essence orb) | n/a (`src/server/CloudCraft.server.luau`) | Project (original procedural Parts/Model) | Original | none | Project-owned | Server-created anchored Roblox 3D geometry with ProximityPrompt | Source only; CI, Roblox runtime, collisions and appearance unverified |

## 2026-11-12 — Cloud Crafting Workshop provenance
- Original native Roblox `Model` containing `Part` base (Marble), pillar (Neon) and ball orb (Neon) plus `ProximityPrompt`. No external assets, Model IDs, MeshPart IDs or Canvas/ScreenGui world stand-ins. ScreenGui remains reserved for HUD. Full visual/runtime verification pending.

(Full historical registry continues from prior commits on main.)
