# 3D assets — Android/tablet-first workflow

Catch a Cloud uses Roblox 3D Models/Parts for world geometry. A ScreenGui is appropriate for interactive HUD; it is not a substitute for 3D world art. No Roblox Studio is required to **generate and submit** an original GLB through the existing GitHub Actions workflow, but actual insertion, rendering and gameplay still need Roblox runtime verification.

## Current asset status

- Original procedural trees, crystals, rocks, arches and cloud fallback exist in source. These are 3D Roblox Model/Part assemblies, not external meshes.
- `scripts/generate_cloud_glb.py` creates an original five-puff cloud GLB (no third-party license).
- `.github/workflows/import-original-cloud.yml` validates the GLB and attempts a Roblox Open Cloud **Model** asset upload. Inspect the run and artifact before recording success. API acceptance is not proof of usable in-game geometry.
- **A Model asset ID is not a MeshPart MeshId.** Never paste an uploaded `assets/<id>` Model ID into `MeshPart.MeshId` or the `MeshIds` map.
- Keep the existing procedural fallback until a verified mesh/model insertion path is available and visually tested.

## Tablet-only original model pipeline

1. On GitHub, open Actions > **Import Original Cloud 3D Model** and run the workflow, or inspect the run triggered by a relevant push to main.
2. Check each step: generator, geometry validation, Open Cloud upload and artifact. A green workflow establishes upload acceptance only.
3. Download the `original-cloud-model-asset-id` artifact from a successful run. It contains the uploaded **Model** asset ID, not a MeshPart ID.
4. Record the exact ID, run URL, creator, original generation script, source revision and moderation status in `ASSET_REGISTRY.md`. Do not commit API keys.
5. For actual game use, implement a separate Roblox Model-loading/insertion adapter with ownership/access checks, instance type validation, bounded size/part count, no untrusted scripts, sensible collisions and a procedural fallback. Review whether the asset is accessible in the target experience. Do not silently swap a Model ID into a MeshPart slot.
6. Build and test in CI; independently verify in a Roblox runtime on phone/tablet before claiming visual success. If the loader fails, retain the existing procedural cloud.

## Third-party models (not yet imported)

Candidate sources to research, **not approved or verified imports**:
- Kenney Nature Kit: https://kenney.nl/assets/nature-kit
- Quaternius nature packs: https://quaternius.com/
- Poly Haven models: https://polyhaven.com/models

For each selected model, check its **specific** license and download terms at acquisition time; capture source URL, author, license/version, attribution, file checksum, polygon count and Roblox asset ID in `ASSET_REGISTRY.md`. Avoid assets with unclear ownership. Do not import embedded scripts or blindly trust Creator Store packages. Prefer lightweight geometry for mobile.

## Release gates

CI can validate Luau, Rojo XML, GLB format and upload response; it cannot establish Roblox runtime appearance, touch layout, asset moderation visibility or multiplayer behavior. Do not mark the 3D-art acceptance item complete until the assets are integrated, visible and tested in Roblox. Publishing a place file is not the same as validating its live contents.
