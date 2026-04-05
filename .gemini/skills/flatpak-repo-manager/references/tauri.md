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
  - pnpm build  # Generates static assets in /dist
  - cargo build --manifest-path tauri/Cargo.toml --release # Embeds assets from /dist
```

## Key "Gotchas" & Solutions

### 1. Bypassing tauri-cli Bundling
`pnpm tauri build` tries to create `.deb`/`.appimage` packages which fail in the sandbox. Use `cargo build --release` directly after `pnpm build`.

### 2. Locating the Binary
Binary paths in Rust can be tricky. Use a robust find command:
```bash
BIN_PATH=$(find tauri/target/release -name binary-name -type f -executable | grep -v "\.d$" | head -n 1)
install -Dm755 "$BIN_PATH" /app/bin/binary-name
```

### 3. CI/CD Submodule Support
Ensure `actions/checkout` has `submodules: true` to prevent build failures.
