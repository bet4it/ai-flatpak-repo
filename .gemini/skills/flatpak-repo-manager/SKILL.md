---
name: flatpak-repo-manager
description: Manage, package, and deploy Flatpak applications to a personal repository using GitHub Actions.
---
# Flatpak Repository Manager

## 1. Runtime Version Detection (CRITICAL)
Always check for the latest stable, non-EOL runtimes before creating or updating a manifest.
- **Detection Command**: `flatpak remote-ls flathub --user | grep -E "org.gnome.Platform|org.freedesktop.Platform"`
- **Current Standard (as of Apr 2026)**: GNOME `50`, Freedesktop `25.08`.

## 2. Version & Source Control (MANDATORY)
1. **Find Latest Version**: Use `gh release view --repo <URL>` or `git ls-remote --tags <URL>`.
2. **Lock Source**: Use exact `tag` or `commit` hash in `.yaml`.
3. **AppStream Release Tag (MANDATORY)**:
   - Use `.metainfo.xml` suffix.
   - The `<id>` inside MUST match the `app-id`.
   - MUST include a `<releases>` section for version visibility.
   ```xml
   <releases>
     <release version="1.2.3" date="2026-04-04" />
   </releases>
   ```
4. **Metadata Placement**: Install to `/app/share/metainfo/AppID.metainfo.xml`.

## 3. Naming Conventions (RDNN)
- **GitHub Projects**: `io.github.<username>.<ProjectName>`.
- **Consistency**: App ID, metadata filename, XML ID, and Desktop filename MUST be identical.

## 4. Core Workflow
1. **Source Analysis & Research (PRIORITY)**:
   - Clone target repo to **parent directory** (sibling to `ai-flatpak-repo`).
   - Identify stack (Electron, Tauri, etc.) and dependencies.
   - **Flathub Research**: Search [github.com/flathub](https://github.com/flathub) for similar apps to see how they handle specific libraries or build complexities.
2. **Setup**: Create folder named after App ID. Add `.yaml`, `.metainfo.xml`, `.desktop`, and `icon.png`.
3. **Commit & Push**: Push changes to repository.
4. **Monitor & Verify (MANDATORY)**:
   - Use **strictly non-interactive** polling.
   - `sleep 10` after push, get Run ID via `gh run list --limit 1 --json databaseId`.
   - Poll status via `gh run view <ID> --json status,conclusion`.
   - **Verification & Run (CRITICAL)**:
     - Once build is successful, run `flatpak update --user --appstream <repo-name>`.
     - **Install and Run**: `flatpak install <repo-name> <AppID>` and `flatpak run <AppID>`.
     - **DEBUG**: If the app fails to launch (e.g., missing `.so`), research solutions on Flathub and update the manifest.
     - **Completion**: Task is ONLY finished when the app launches successfully and UI is visible.
5. **Knowledge Capture (CRITICAL)**:
   - Extract "gotchas" and update `references/` or `SKILL.md`. Every lesson learned from Flathub MUST be documented.

## 5. Technology-Specific Guides
- **Node.js/Electron**: See [references/nodejs.md](references/nodejs.md).
- **Wails (Go + Frontend)**: See [references/wails.md](references/wails.md).
- **Tauri (Rust + Node.js)**: See [references/tauri.md](references/tauri.md).

## 6. Deployment Standard
Always use `ostree init --repo=repo --mode=archive-z2` and `flatpak build-update-repo` in modern containers.
