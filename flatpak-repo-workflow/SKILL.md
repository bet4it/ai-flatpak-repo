---
name: flatpak-repo-workflow
description: Manage, package, and deploy Flatpak applications to a personal repository using GitHub Actions.
---
# Flatpak Repository Workflow

## 0. Trigger Conditions & Operating Mode (MANDATORY)
This workflow is not optional when the user asks for Flatpak packaging work in this repository.

- **Trigger phrases** include: "帮我打包", "package", "make a Flatpak", "add to repo", "update Flatpak", "fix Flatpak", or any request to add/update a packaged app in this repository.
- **Default intent**: treat those requests as **full execution requests**, not research-only requests, unless the user explicitly says to only investigate or only explain.
- **Do not stop at analysis**. Once triggered, continue through research, manifest authoring, metadata creation, validation, and a concise summary of blockers/results.
- **Load this workflow first** before exploring files or upstream repos so runtime/version/naming rules shape the whole implementation.
- **For multiple upstream apps in one request**, package each app end-to-end using this workflow; do not stop after packaging just one unless a blocker prevents continuing.

### Mandatory Packaging Preflight
Before writing any manifest, complete all of the following:
1. Run the runtime detection command in Section 1 and use the latest stable, non-EOL runtime unless there is a documented incompatibility.
2. Determine the latest upstream version via `gh release view --repo <owner>/<repo>` or `git ls-remote --tags <repo-url>`.
3. Clone the upstream repository to the parent directory (a sibling of `ai-flatpak-repo`) and inspect the real project files locally.
4. Identify the app stack (GTK, Electron, Tauri, Wails, etc.), package manager, build command, desktop assets, and Linux-specific requirements.
5. Confirm a **source build path** exists and record the exact commands needed to build the Linux app from source inside Flatpak.
6. Search Flathub for similar manifests and check `shared-modules` before inventing custom dependency handling.

### Source-Build Requirement (MANDATORY)
- **Build Flatpaks from upstream source code.** This repository does **not** accept manifests that download or repackage prebuilt upstream release artifacts such as `.deb`, `.rpm`, `.AppImage`, prebuilt tarballs, or already-bundled desktop binaries.
- Acceptable sources are upstream git checkouts, source archives, vendored source tarballs, or dependency/module definitions that still produce the final app by compiling/building inside Flatpak.
- `extra-data` is **not** an acceptable escape hatch for packaging prebuilt upstream applications in this repository.
- If a package seems difficult to build from source, continue investigating the build chain, reusable Flathub modules, native dependency handling, or wrapper strategy. Treat “source build only” as the default constraint, not an optional preference.
- If the upstream project is genuinely impossible to build from source in Flatpak after exhausting reasonable approaches, document the exact blocker instead of silently switching to prebuilt binaries.

### Local vs CI Responsibility (MANDATORY)
- This repository's Flatpak packaging workflow is **GitHub-Actions-first and GitHub-Actions-required**. For packaging requests in this repo, the real Flatpak build must be performed through the repository's GitHub Actions workflow.
- For packaging requests in this repository, **creating the commit and pushing it so GitHub Actions can perform the real Flatpak build is part of the standard workflow and does not require a separate user approval step**.
- Treat **"manifest/metadata ready but not committed/pushed" as an incomplete packaging task**. If the agent stops before commit/push, it has not followed this repository workflow.
- Do **not** ask the user whether to commit, whether to push, or whether to trigger CI once packaging work is ready; in this repository those actions are the default handoff to the authoritative build system.
- After pushing, the agent must immediately switch into GitHub Actions verification mode and fetch a **fresh** remote run status in the same workflow, rather than ending at "push succeeded".
- Local work should focus on: upstream inspection, manifest authoring, metadata/icon preparation, checksum lookup from authoritative upstream metadata, and light validation such as `flatpak-builder --show-manifest` or `appstreamcli validate`.
- Do **not** perform ad-hoc local Flatpak packaging builds as the primary build path for this repository unless the user explicitly asks for a local reproduction/debugging workflow.
- Do **not** download large toolchain archives or upstream release artifacts locally just to prepare packaging work when that download is meant to support the real package build; encode those downloads as manifest sources so GitHub Actions fetches them inside `flatpak-builder`.
- When checksums are needed for manifest sources, prefer authoritative upstream checksum files, release metadata, or other published source metadata over downloading the file locally just to hash it.
- The actual source build path must be encoded in the manifest so GitHub Actions performs the real build in the Flatpak builder container.

### Minimum Completion Standard
A packaging task is not complete unless the agent has attempted all applicable steps below:
- Created or updated the app directory named after the final app ID.
- Added the manifest, desktop file, metainfo/appdata, and icon asset (or documented the exact missing upstream asset blocker).
- Performed local validation relevant to the stack.
- Created the repository commit that contains the packaging changes.
- Pushed that commit so GitHub Actions can run the authoritative Flatpak build.
- Reported concrete outcomes and blockers, not just findings.
- Followed the GitHub Actions build through to a current remote result; do not treat a stale earlier status check as active monitoring.

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
- **Reverse-DNS Required**: Use a valid reverse-DNS application ID that follows Flatpak/D-Bus naming rules.
- **Final Segment Must Name the App**: The final component should identify the specific software/project, not a generic platform or packaging label.
- **Avoid Weak Trailing Segments**: Do not choose IDs ending in generic tails such as `.desktop`, `.Desktop`, `.app`, or `.linux` for normal applications.
- **Repetition Is Acceptable**: If the cleanest valid ID repeats the app name in the last segment, that is acceptable and preferred over a weak generic ending (for example, `io.github.foo.foo` is better than `io.github.foo`).
- **Canonical Upstream IDs Win Only If They Are Good IDs**: Reuse the upstream reverse-DNS ID when upstream already defines a good canonical ID. If the upstream ID uses a weak generic trailing segment, normalize it to a stronger app-identifying final segment instead of preserving it blindly.
- **GitHub Projects**: When upstream does not already define a good canonical reverse-DNS application ID, prefer `io.github.<username>.<appname>` or another namespace the project actually controls.
- **Consistency**: App ID, package directory name, manifest filename, metadata filename, XML `<id>`, desktop ID, icon ID, and any WM class tied to the Flatpak identity MUST be identical.

## 4. Core Workflow
1. **Source Analysis & Research (PRIORITY)**:
    - Clone target repo to **parent directory** (sibling to `ai-flatpak-repo`).
    - Identify stack (Electron, Tauri, etc.) and dependencies.
    - Determine the concrete **source build** invocation that will run inside Flatpak. Do not stop at install/release instructions.
    - **Flathub Research**: Search [github.com/flathub](https://github.com/flathub) for similar apps.
    - **Shared Modules**: For common dependencies (e.g., `libappindicator`), **ALWAYS** check if they exist in `flathub/shared-modules`. Use the `shared-modules` git submodule.
    - **Do not rely only on GitHub README pages or indirect summaries** when packaging details can be verified from the cloned source tree.
2. **Setup**: Create folder named after App ID. Add `.yaml`, `.metainfo.xml`, `.desktop`, and `icon.png`.
    - Prefer `.metainfo.xml` for new work.
    - Keep filenames, XML `<id>`, desktop ID, and manifest `app-id` identical.
    - If upstream does not ship a desktop file, metainfo, or icon, create repository-owned metadata/assets using upstream branding and document the source.
    - If installing a raster icon into a fixed hicolor size directory such as `512x512/apps`, the actual image must not exceed that directory size. Do not place a `1024x1024` PNG into `512x512/apps` and assume export will downscale it.
    - For app-owned state (local databases, UI state, daemon sockets, PID files, tokens, caches, etc.), prefer Flatpak/XDG per-app directories such as `$XDG_DATA_HOME`, `$XDG_CONFIG_HOME`, `$XDG_CACHE_HOME`, or `$XDG_RUNTIME_DIR/app/$FLATPAK_ID` instead of sharing `~/.foo` state with a non-Flatpak installation.
    - If upstream hardcodes a host home dot-directory like `~/.foo`, a wrapper-level environment override (for example setting an app-specific home/state variable to the Flatpak XDG path) is an acceptable packaging fix when it avoids collisions with host-installed copies of the same app.
    - Sharing persistent app state with non-Flatpak installs should be treated as opt-in compatibility behavior, not the default. If you keep it shared, document the reason explicitly.
    - Lock the manifest source to an exact release tag or commit; never leave it floating.
    - The manifest must compile/build the application from source during `flatpak-builder`; do not install upstream prebuilt binaries.
3. **Commit & Push**: Push changes to repository.
   - For packaging work in this repo, do **not** stop to ask whether to create a commit and push after the manifest/metadata work is ready; that commit/push is the handoff required to trigger the authoritative GitHub Actions Flatpak build.
   - If multiple files were touched to complete one packaging request, the agent must still finish the commit/push flow in the same work session; do not hand off an uncommitted packaging tree as "done".
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
    - **Do not claim you are “watching”, “monitoring”, or “still following” a run unless you have either (a) an active blocking `gh run watch` in progress, or (b) you just performed a fresh `gh run view` / `gh run list` check in this turn.**
    - **If the user sends any follow-up while a remote build may still be running or may have finished meanwhile, re-query GitHub Actions immediately before answering.** Never answer from memory or from an earlier status snapshot.
    - A status report about a run must be based on a fresh remote check from the current turn. If enough time has passed that the run could have changed state, check again first.
    - If `gh run watch` exits unexpectedly, fails to stream, or is interrupted by unrelated workflow/job noise, immediately fall back to `gh run view <RUN_ID> --json status,conclusion,jobs` and continue from the fresh result instead of assuming the previous state still holds.
    - Do not pause at “run in progress” summaries when the workflow instruction is to continue until success; keep cycling through: query latest run → inspect failed job log if any → patch → commit → push → re-check.
    - If the workflow fans out into matrix jobs, identify the specific job IDs from `gh run view <RUN_ID> --json jobs` before fetching logs.
    - **Verification & Run (CRITICAL)**: Install and run the app. Task is ONLY finished when UI is visible.
    - Before handing off to CI, run local validation that matches the change scope whenever possible (for example: `flatpak-builder --show-manifest` or `appstreamcli validate`).
    - The authoritative Flatpak build for this repository happens in GitHub Actions. Treat local checks as preflight only.
5. **Knowledge Capture (CRITICAL)**:
    - Extract "gotchas" and document them in the **most specific matching long-term home**: stack-specific details go in the matching file under `references/` (for example: Node/Electron details in `references/nodejs.md`, Tauri details in `references/tauri.md`, Wails details in `references/wails.md`), while cross-stack Flatpak workflow/export/asset rules stay in `SKILL.md`.
    - Keep `SKILL.md` focused on workflow policy, repository-wide rules, and cross-stack execution discipline. Do **not** leave stack-specific implementation gotchas in `SKILL.md` when they belong in a matching technology reference, and do **not** move generic Flatpak rules into a stack-specific reference just because they were discovered while packaging one app.
    - If a new lesson does not fit any existing reference file, either add it to the closest matching reference or create a new reference file, then link it from Section 6.
    - Every lesson learned from Flathub MUST be documented in the correct long-term home, not left only in an ad-hoc workflow note.

## 5. Response Discipline For Packaging Requests
- When the workflow trigger in Section 0 matches, the response should communicate progress in terms of execution phases: preflight, upstream inspection, manifest authoring, validation, blockers.
- Do not present exploratory research as the final result when no manifest/metadata changes were made.
- Do not present "I prepared the files" as the final result when commit/push/CI follow-through is still missing; for this repository that is only a mid-work update.
- If blocked, report the exact missing asset, dependency, runtime issue, or upstream incompatibility and continue with any remaining non-blocked apps in the same request.
- If the user asks to "continue", resume the next pending workflow step rather than re-explaining prior research.

## 6. Technology-Specific Guides
- **Node.js/Electron**: See [references/nodejs.md](references/nodejs.md).
- **Wails (Go + Frontend)**: See [references/wails.md](references/wails.md).
- **Tauri (Rust + Node.js)**: See [references/tauri.md](references/tauri.md).

## 7. Deployment Standard
- **Submodules**: Use `git submodule add https://github.com/flathub/shared-modules.git` to manage common library definitions. Reference them in manifests as `../shared-modules/path/to/module.json`.
- **CI/CD**: Ensure the workflow clones submodules (use `submodules: true` in checkout).
