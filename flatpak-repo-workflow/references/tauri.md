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
