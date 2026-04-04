---
name: flatpak-repo-manager
description: Manage, package, and deploy Flatpak applications to a personal repository using GitHub Actions.
---
# Flatpak Repository Manager

## Runtime Version Detection (CRITICAL)
Always check for the latest stable, non-EOL runtimes before creating a manifest.
- **Command**: `flatpak remote-ls flathub --user | grep -E "org.gnome.Platform|org.freedesktop.Platform"`
- **Current Standard (as of Apr 2026)**:
  - `org.gnome.Platform` branch: `50`
  - `org.freedesktop.Platform` branch: `25.08`
- **Rule**: If a runtime branch is EOL, upgrade immediately to the latest available numeric branch.

## Naming Conventions
Follow the Reverse Domain Name Notation (RDNN).
- **GitHub Projects**: Use `io.github.<username>.<ProjectName>`. Replace hyphens in the username or project name with underscores.
- **Constraint**: Hyphens (`-`) are ONLY allowed in the final segment of the Application ID.

## Core Workflow
1. **Research & Prepare**:
   - Clone target repo outside `ai-flatpak-repo`.
   - Check `README.md` and `.github/workflows/` for build commands.
   - **Check latest runtimes** using the command above.
2. **Create App Folder**: Name the directory after the App ID (e.g., `io.github.id_root.Synapse`).
3. **Create Required Files**:
   - `AppID.yaml`: Flatpak manifest. Ensure it uses the latest runtime versions.
   - `AppID.metainfo.xml`, `AppID.desktop`, `icon.png`.
   - **Icon Path**: If non-standard size, install to `hicolor/scalable/apps/`.
4. **Commit & Push**: Push to GitHub.
5. **Monitor & Verify**: Use `gh run list --limit 1` and `gh run view --log-failed`. Confirm `.flatpak` bundle exists in artifacts.

## Technology-Specific Guides
- **Node.js/Electron**: See [references/nodejs.md](references/nodejs.md).
- **Wails (Go + Frontend)**: See [references/wails.md](references/wails.md).

## Deployment
Uses `ghcr.io/flathub-infra/flatpak-github-actions:freedesktop-25.08`. Never hardcode paths in `build.yml`.
