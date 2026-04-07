---
name: flatpak-repo-workflow
description: Manage, package, and deploy Flatpak applications to a personal repository using GitHub Actions.
---
# Flatpak Repository Workflow

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

## 3. Naming Conventions (RDNN)
- **GitHub Projects**: `io.github.<username>.<ProjectName>`.
- **Consistency**: App ID, metadata filename, XML ID, and Desktop filename MUST be identical.

## 4. Core Workflow
1. **Source Analysis & Research (PRIORITY)**:
   - Clone target repo to **parent directory** (sibling to `ai-flatpak-repo`).
   - Identify stack (Electron, Tauri, etc.) and dependencies.
   - **Flathub Research**: Search [github.com/flathub](https://github.com/flathub) for similar apps.
   - **Shared Modules**: For common dependencies (e.g., `libappindicator`), **ALWAYS** check if they exist in `flathub/shared-modules`. Use the `shared-modules` git submodule.
2. **Setup**: Create folder named after App ID. Add `.yaml`, `.metainfo.xml`, `.desktop`, and `icon.png`.
3. **Commit & Push**: Push changes to repository.
4. **Monitor & Verify (MANDATORY)**:
   - Use **strictly non-interactive** polling.
   - `sleep 10` after push, get Run ID via `gh run list --limit 1 --json databaseId`.
   - Poll status via `gh run view <ID> --json status,conclusion`.
   - Preferred commands:
     - Get latest run for current push:
       - `sleep 10 && gh run list --limit 1 --json databaseId,headSha,status,conclusion,workflowName`
     - Watch a run until it finishes:
       - `gh run watch <RUN_ID> --exit-status --interval 20`
     - Check overall status without streaming:
       - `gh run view <RUN_ID> --json status,conclusion,jobs`
     - Inspect a specific job:
       - `gh run view <RUN_ID> --job <JOB_ID> --log`
     - List recent runs if the latest one is ambiguous:
       - `gh run list --limit 5 --json databaseId,headSha,status,conclusion,workflowName,createdAt`
   - Use `gh run watch <RUN_ID> --exit-status --interval 20` as the default blocking wait command after push.
   - If the workflow fans out into matrix jobs, identify the specific job IDs from `gh run view <RUN_ID> --json jobs` before fetching logs.
   - **Verification & Run (CRITICAL)**: Install and run the app. Task is ONLY finished when UI is visible.
5. **Knowledge Capture (CRITICAL)**:
   - Extract "gotchas" and update `references/` or `SKILL.md`. Every lesson learned from Flathub MUST be documented.

## 5. Technology-Specific Guides
- **Node.js/Electron**: See [references/nodejs.md](references/nodejs.md).
- **Wails (Go + Frontend)**: See [references/wails.md](references/wails.md).
- **Tauri (Rust + Node.js)**: See [references/tauri.md](references/tauri.md).

## 6. Deployment Standard
- **Submodules**: Use `git submodule add https://github.com/flathub/shared-modules.git` to manage common library definitions. Reference them in manifests as `../shared-modules/path/to/module.json`.
- **CI/CD**: Ensure the workflow clones submodules (use `submodules: true` in checkout).
