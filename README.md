# Roblox Game — Android-only development

Build Roblox places on GitHub-hosted Ubuntu without installing Roblox Studio on your tablet.

## Layout
- `default.project.json`: Rojo project mapping
- `src/server`: server Luau scripts
- `src/client`: client Luau scripts
- `src/shared`: reusable shared modules
- `.github/workflows/build.yml`: build and upload artifact
- `.github/workflows/deploy.yml`: separate manual Saved-version deployment

## First build from Android
1. Open the GitHub repository in your tablet browser.
2. Review and merge the infrastructure pull request.
3. Open **Actions → Build Roblox Place → Run workflow** on `main`.
4. Wait for the green check. Open the run and download the **roblox-place** artifact ZIP.
5. Unzip it to get `game.rbxlx`. Building does **not** update Roblox.

The build workflow also checks pull requests, but never deploys. Rojo is pinned to official release v7.4.4; GitHub Actions are major-version pinned.

## Manual Saved deployment (optional, destructive to Saved version)
**Do not use this until you explicitly approve overwriting the existing Saved version of Place 123021373220932.** Published is never requested.
1. Verify that `ROBLOX_API_KEY` is a repository secret with appropriate Open Cloud permissions, and `ROBLOX_UNIVERSE_ID` / `ROBLOX_PLACE_ID` are repository variables.
2. Open **Actions → Deploy Roblox Place (Manual Saved Only) → Run workflow**.
3. Enter a successful build's numeric run ID and type `DEPLOY SAVED`.
4. Review the result. This modifies the existing Place's **Saved** version; it does not publish it.

## Editing from Android
Use GitHub's browser editor to edit files in `src/`, commit to a branch, and open a pull request. A PR triggers a build check. Merge only after reviewing results.

## Limitations
A successful Rojo build validates the project structure and generated XML, not gameplay behavior in Roblox Studio. Automated Luau parsing/linting and runtime playtesting are future enhancements. Never put credentials in code or logs.
