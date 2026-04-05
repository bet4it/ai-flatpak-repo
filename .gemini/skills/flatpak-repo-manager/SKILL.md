---
name: flatpak-repo-manager
description: Manage, package, and deploy Flatpak applications to a personal repository using GitHub Actions.
---
# Flatpak Repository Manager

## Version & Source Control (MANDATORY)
Every application MUST have a version displayed in the repository.
1. **Find Latest Version**: Use `gh release view --repo <URL>` or `git ls-remote --tags <URL>` to find the latest stable tag/release.
2. **Lock Source**: In the manifest (`.yaml`), use the exact `tag` or `commit` hash. Do NOT use `branch: main` for stable releases.
3. **AppStream Release Tag**: You MUST add a `<releases>` section to the `AppID.appdata.xml` file.
   ```xml
   <releases>
     <release version="1.2.3" date="2024-04-04" />
   </releases>
   ```
4. **Metadata Placement**: Ensure the appdata file is installed to `/app/share/metainfo/AppID.appdata.xml`.

## Naming Conventions
Follow the Reverse Domain Name Notation (RDNN).
- **GitHub Projects**: Use `io.github.<username>.<ProjectName>`. Replace underscores or hyphens appropriately.
- **Constraint**: Hyphens (`-`) are ONLY allowed in the final segment of the Application ID.

## Core Workflow
1. **Source Analysis & Research (PRIORITY)**:
   - Clone the target repository to the **parent directory** (sibling to `ai-flatpak-repo`) for easy access and long-term maintenance.
   - Identify the technology stack (e.g., Electron, Wails, Python, Rust) and build system.
   - Analyze dependencies (check `package.json`, `requirements.txt`, `go.mod`, etc.) and bundled assets.
   - Check `README.md` and `.github/workflows/` for specific build commands and environment requirements.
2. **Determine Runtime & Dependency Versions**:
   - Based on the architecture, find the latest stable, non-EOL Flatpak runtimes (GNOME or Freedesktop).
   - Locate specific versions/tags for necessary standalone dependencies.
3. **Create App Folder**: Name the directory after the RDNN App ID.
4. **Create Required Files**:
   - `AppID.yaml`: Flatpak manifest. Use exact tags/commits for the app and dependencies.
   - `AppID.metainfo.xml`, `AppID.desktop`, `icon.png`.
   - **Icon Path**: Install to standard `hicolor` paths.
5. **Commit & Push**: Push changes to the repository.
6. **Monitor & Verify (MANDATORY)**:
   - Use `gh run list --limit 1` to track the build progress immediately after pushing.
   - Use `gh run view --log-failed` if the build fails to diagnose issues.
   - **Success Condition**: The build must complete successfully, and the `.flatpak` bundle must exist in the artifacts. Do NOT consider the task finished until the remote repository is updated.

## Core Workflow (Multi-Job Architecture)
To ensure robust AppStream metadata indexing, always use the 4-job architecture:
1. **discover**: Find all manifests.
2. **build**: Parallel matrix build of `.flatpak` bundles.
3. **reconstruct**: Run in `ghcr.io/flathub-infra/flatpak-github-actions:freedesktop-25.08`. Download all bundles, `ostree init`, `flatpak build-import-bundle`, and `flatpak build-update-repo`.
4. **deploy**: Publish the reconstructed `repo/` to GitHub Pages.

## Technology-Specific Guides
- **Node.js/Electron**: See [references/nodejs.md](references/nodejs.md).
- **Wails (Go + Frontend)**: See [references/wails.md](references/wails.md).

## Deployment Standard
Always use `ostree init --repo=repo --mode=archive-z2` and `flatpak build-update-repo --generate-static-deltas repo` in a modern container to ensure full metadata support.
