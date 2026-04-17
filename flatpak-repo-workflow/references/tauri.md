# Tauri Application Packaging Guide

## Architecture Requirements
Tauri apps require both Node.js (frontend) and Rust (backend) SDK extensions.

```yaml
sdk-extensions:
  - org.freedesktop.Sdk.Extension.rust-stable
  - org.freedesktop.Sdk.Extension.node24
```

## Dependency Management (Standardized)
**NEVER** manually define common libraries like `libappindicator`. Use the Flathub `shared-modules` submodule.

1. Add the submodule: `git submodule add https://github.com/flathub/shared-modules.git`
2. Reference in manifest:
```yaml
modules:
  - ../shared-modules/libappindicator/libappindicator-gtk3-12.10.json
```

## Production Build Workflow
To avoid `Connection refused` (localhost:5173) errors, you MUST perform a production build that embeds assets.

**Manifest Commands:**
```yaml
build-commands:
  - pnpm install
  - pnpm tauri build --no-bundle
```

`pnpm tauri build --no-bundle` is the preferred default for Tauri 2 packaging. It runs `beforeBuildCommand`, compiles the Rust binary, and skips generating `.deb` / `.AppImage` bundles that are not needed for Flatpak.

## Key "Gotchas" & Solutions

### 1. Library Loading at Runtime (CRITICAL)
Even if libraries (like `libappindicator`) are built into `/app/lib`, the application might fail to find them. You MUST:
1. Add `LD_LIBRARY_PATH` to `finish-args`:
   ```yaml
   finish-args:
     - --env=LD_LIBRARY_PATH=/app/lib
   ```
2. (Optional) Provide compatibility symlinks if the app expects a specific name (e.g., Ayatana vs Classic):
   ```bash
   ln -s libappindicator3.so.1 /app/lib/libayatana-appindicator3.so.1
   ```

### 2. Bypassing tauri-cli Bundling
Use `pnpm tauri build --no-bundle` to skip `.deb` / `.AppImage` generation inside Flatpak builds.

Do not assume `cargo build --release` is a safe replacement. On some Tauri 2 projects it can produce a binary that still behaves like a dev webview build and tries to load `devUrl` such as `http://127.0.0.1:5173`.

### 2. Locating the Binary
Binary paths in Rust can be tricky. Use a robust find command:
```bash
BIN_PATH=$(find tauri/target/release -name binary-name -type f -executable | grep -v "\.d$" | head -n 1)
install -Dm755 "$BIN_PATH" /app/bin/binary-name
```

### 3. CI/CD Submodule Support
Ensure `actions/checkout` has `submodules: true` to prevent build failures.

### 4. Choose GNOME runtime when upstream Linux deps imply the WebKitGTK stack
If upstream Linux packaging/dev configuration explicitly depends on libraries like `gtk3`, `libsoup_3`, `webkitgtk_4_1`, or `librsvg`, prefer `org.gnome.Platform` / `org.gnome.Sdk` unless you have already verified the equivalent Freedesktop runtime support.

### 5. Disable Upstream Self-Updaters
If a Tauri app uses `@tauri-apps/plugin-updater` / `tauri-plugin-updater`, disable both automatic and user-triggered updater paths in Flatpak builds.

Flatpak updates must come from the repository remote, not from the app pulling GitHub release feeds such as `latest.json` directly.

### 6. Verify Home-Directory Integrations Before Sandboxing Them Away
Do not assume a Tauri desktop app is already XDG-clean. Many AI/developer workbench apps explicitly resolve `HOME` / `dirs::home_dir()` and read or write paths like `~/.claude`, `~/.codex`, `~/.gemini`, `~/.opencode`, or an app-specific dot-directory.

When those host-home integrations are part of the product, forcing everything into per-app XDG directories without patching the code will break real workflows. Read the actual path-resolution code first, then decide whether the correct packaging move is a wrapper/env remap or `--filesystem=home`.

### 7. Rust bindgen users may need the LLVM SDK extension
If the Rust build pulls in crates that use `bindgen` (for example `whisper-rs-sys`), Flatpak builds can fail late in the Cargo phase with errors like `Unable to find libclang`.

For Freedesktop/GNOME 25.08-era builds, add an LLVM SDK extension such as `org.freedesktop.Sdk.Extension.llvm21`, prepend its `bin` directory to `PATH`, and set `LIBCLANG_PATH` to the extension's `lib` directory.

### 8. Do not rely on shell variables across separate build-commands
Each Flatpak `build-commands` entry is executed independently. If you compute `BIN_PATH=...` in one line and try to use `$BIN_PATH` in a later line, it will be empty unless both actions happen inside the same multiline shell block.

For fixed Rust binary names, prefer direct `install -Dm755 src-tauri/target/release/<binary>` commands, or keep discovery and installation in the same `|` block.

### 9. AI desktop apps that orchestrate host CLIs need an explicit host bridge
Tauri AI workbenches often discover and launch host-installed CLIs such as `codex`, `claude`, `node`, `npm`, or `git`. Granting `--filesystem=home` alone is not enough: the sandbox still cannot execute arbitrary host binaries.

When the product is expected to drive host developer tools, add `--talk-name=org.freedesktop.Flatpak`, install small `/app/bin/host-tools/*` shims that call `flatpak-spawn --host`, and start the app through a wrapper that prepends `/app/bin/host-tools` to `PATH`. If the app also respects `$SHELL`, point it at a matching host-shell shim so spawned shells resolve on the host side instead of inside the sandbox.
