# 3D Asset Recommendations for Catch a Cloud

Use real MeshParts instead of primitive Part geometry where possible.

## Best free CC0 sources (no attribution required)

1. **Kenney Nature Kit** — https://kenney.nl/assets/nature-kit  
   Trees, rocks, grass, bushes. Low-poly, game-ready. CC0.  
   Import: File > Import 3D in Studio, then copy MeshId.

2. **Quaternius Ultimate Nature Pack** — https://quaternius.com/packs/ultimatenature.html  
   150 low-poly nature models (trees, plants, rocks). CC0.  
   Formats: FBX, OBJ, Blend.

3. **Quaternius Stylized Nature** — https://quaternius.com/packs/ultimatestylizednature.html  
   Textured stylized trees and plants. CC0.

4. **Poly Haven** — https://polyhaven.com/models  
   Higher quality CC0 models (use sparingly for hero pieces).

## Free cloud models (check license per model)

- Sketchfab search "cloud" with CC0 or CC-BY filter.  
  Prefer models under ~20k triangles for Roblox.

## How to use in the game

1. Download the model (FBX/OBJ/GLB).
2. In Roblox Studio: File > Import 3D, select the file.
3. After import, select the MeshPart and copy its MeshId (rbxassetid://...).
4. Paste the MeshId into `src/shared/CloudVisuals.luau` under `MeshIds`.
5. Push and republish. The game will use the MeshPart instead of the multi-part fallback.

## Notes

- Inspect every imported MeshPart for scale, collision, and any embedded scripts. Delete unknown scripts.
- Prefer CC0 assets for commercial release. Record source, license, and MeshId in this file after import.
- Current visual is an improved multi-part fallback until MeshIds are set.
