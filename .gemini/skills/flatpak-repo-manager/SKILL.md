---
name: flatpak-repo-manager
description: Manage, package, and deploy Flatpak applications to a personal repository using GitHub Actions.
---
# Flatpak Repository Manager

## 1. Runtime Version Detection (CRITICAL)
Always check for the latest stable, non-EOL runtimes before creating or updating a manifest.
- **Detection Command**: `flatpak remote-ls flathub --user | grep -E "org.gnome.Platform|org.freedesktop.Platform"`
- **Selection Rule**: If a runtime branch is marked as EOL or nearing it, upgrade immediately to the latest available numeric branch (e.g., GNOME 47 -> 50).
- **Current Standard (as of Apr 2026)**:
  - `org.gnome.Platform` branch: `50`
  - `org.freedesktop.Platform` branch: `25.08`

## 2. Version & Source Control (MANDATORY)
Every application MUST have a version displayed in the repository.
1. **Find Latest Version**: Use `gh release view --repo <URL>` or `git ls-remote --tags <URL>` to find the latest stable tag.
2. **Lock Source**: In the manifest (`.yaml`), use the exact `tag` or `commit` hash. **NEVER** use `branch: main` for stable releases.
3. **AppStream Release Tag**: You MUST add a `<releases>` section to the `AppID.appdata.xml` file.
   ```xml
   <releases>
     <release version="1.2.3" date="2026-04-04" />
   </releases>
   ```
4. **Metadata Placement**: Ensure the appdata file is installed to `/app/share/metainfo/AppID.appdata.xml`.

## 3. Naming Conventions (RDNN)
- **GitHub Projects**: Use `io.github.<username>.<ProjectName>`. 
- **Rule**: Replace hyphens in username/project with underscores. Hyphens (`-`) are **ONLY** allowed in the final segment of the Application ID.

## 4. Core Workflow
### Local Preparation
1. **Research**: Clone target repo outside `ai-flatpak-repo`, identify build commands and dependencies.
2. **Setup**: Create folder named after App ID. Add `AppID.yaml`, `AppID.appdata.xml`, `AppID.desktop`, and `icon.png`.
3. **Validate**: Ensure icon is 512x512 or scalable.

### CI/CD Architecture (4-Job Pipeline)
To ensure robust AppStream indexing and Version support, the repository uses:
1. **discover**: Automatically detects apps by searching for `.yaml` files.
2. **build**: Parallel matrix build producing `.flatpak` bundles.
3. **reconstruct**: Uses `freedesktop-25.08` container to merge all bundles and generate the `appstream` branch via `flatpak build-update-repo`.
4. **deploy**: Publishes the final repo to GitHub Pages.

## 5. Technology-Specific Guides
- **Node.js/Electron**: See [references/nodejs.md](references/nodejs.md).
- **Wails (Go + Frontend)**: See [references/wails.md](references/wails.md).

## 6. Deployment Standard
Always use `ostree init --repo=repo --mode=archive-z2` and `flatpak build-update-repo --generate-static-deltas repo` in a modern container to maintain full metadata and version visibility.
