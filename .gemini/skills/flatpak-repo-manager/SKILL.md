---
name: flatpak-repo-manager
description: Manage, package, and deploy Flatpak applications to a personal repository using GitHub Actions.
---
# Flatpak Repository Manager

## Naming Conventions
Follow the Reverse Domain Name Notation (RDNN).
- **GitHub Projects**: Use `io.github.<username>.<ProjectName>`. Replace hyphens in the username or project name with underscores.
  - Example: `https://github.com/spacecake-labs/spacecake` -> `io.github.spacecake_labs.spacecake`
- **Custom Domains**: Use `com.<domain>.<ProjectName>`.
- **Constraint**: Hyphens (`-`) are ONLY allowed in the final segment of the Application ID. All other segments must use underscores (`_`).

## Core Workflow
1. **Prepare Source Code**: Clone the target repository to a directory outside `ai-flatpak-repo` at the same level.
   - **Persistence**: Do NOT delete the source directory; keep it for future maintenance.
   - **Build Research**: Check `README.md` for build instructions and `.github/workflows/` for reliable build commands.
2. **Create App Folder**: Name the directory exactly after the App ID (e.g., `io.github.id_root.Synapse`).
3. **Create Required Files**:
   - `AppID.yaml`: Flatpak manifest. Add `--share=network` if building online.
   - `AppID.metainfo.xml`: AppStream metadata.
   - `AppID.desktop`: Desktop entry.
   - `wrapper.sh`: Sandbox wrapper (e.g., for `--no-sandbox` if needed).
   - `icon.png`: App icon. **WARNING**: Icons in `hicolor/512x512/apps` MUST be exactly or smaller than 512x512. If the icon size is non-standard, install it to `hicolor/scalable/apps/` instead.
   - **Path Context**: If your build involves `cd` into subdirectories, ensure you `cd` back to the root source directory before running the final `install` commands for files provided via `type: file` sources.
4. **Commit & Push**: Push changes to GitHub.
5. **Monitor & Verify**: Use `gh run list --limit 1` and `gh run view --log-failed` to monitor. Verify that the build produced the `.flatpak` bundle in the Action artifacts.

## Technology-Specific Guides
- **Node.js/Electron**: See [references/nodejs.md](references/nodejs.md) for headers and `TAR_OPTIONS`.
- **Wails (Go + Frontend)**: See [references/wails.md](references/wails.md) for environment setup and command grouping.

## Deployment
The repository uses a dynamic GitHub Action workflow that automatically builds all manifests in subdirectories. Never hardcode paths in `build.yml`.
