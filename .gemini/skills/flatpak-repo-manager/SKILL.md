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
