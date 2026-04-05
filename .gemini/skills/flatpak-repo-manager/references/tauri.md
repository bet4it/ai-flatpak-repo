# Tauri Application Packaging Guide

## Architecture Requirements
Tauri apps require both Node.js (frontend) and Rust (backend) SDK extensions.

```yaml
sdk-extensions:
  - org.freedesktop.Sdk.Extension.rust-stable
  - org.freedesktop.Sdk.Extension.node24 # Use the latest stable
```

## Build Environment
Configure paths and environment variables in `build-options`:

```yaml
build-options:
  append-path: /usr/lib/sdk/rust-stable/bin:/usr/lib/sdk/node24/bin:/app/bin
  env:
    CARGO_HOME: /run/build/app-id/cargo
    PNPM_HOME: /run/build/app-id/pnpm
```

## Key "Gotchas" & Solutions

### 1. Global Tools Installation (npm/pnpm)
The `/usr` filesystem is read-only. Install global tools to `/app`:
```bash
npm install -g pnpm --prefix=/app
```

### 2. Network Access
Enable network per module if you need to fetch dependencies during build (not recommended for Flathub, but necessary for quick repo updates):
```yaml
build-options:
  build-args: ["--share=network"]
```

### 3. Locating the Binary
Binary paths in Rust/Tauri can vary (especially with nested directories). Use a robust find command:
```bash
BIN_PATH=$(find . -name binary-name -type f -executable | grep release | head -n 1)
install -Dm755 "$BIN_PATH" /app/bin/binary-name
```

### 4. Bundled Resources
Explicitly list metadata files in `sources` to ensure they are present in the build sandbox:
```yaml
sources:
  - type: git
    url: ...
  - type: file
    path: io.github.user.App.desktop
```
