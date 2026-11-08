# Sports car import staging

This branch prepares a real GLB 3D asset import using Roblox Open Cloud (not InsertService at runtime).

Prerequisites:
1. Place a legitimately licensed sports-car model at `assets/sports-car.glb`.
2. Set GitHub repository variable `ROBLOX_CREATOR_USER_ID` to the Roblox user ID that owns the experience.
3. Ensure secret `ROBLOX_API_KEY` has Open Cloud asset:write permission for that creator.
4. Run the manual workflow **Import 3D Sports Car (staging only)**.
5. Verify the uploaded asset ID and permission to use it in the experience before updating gameplay code.

The workflow intentionally does not publish the live game or silently fall back to a primitive car. Importing a model via the API is not equivalent to having a usable mesh ID in a Rojo place file; that integration needs verification.
