# Packaging Node.js & Electron Projects

## Environment Setup
Always use `org.electronjs.Electron2.BaseApp`.

**Node Version for Vite**: Modern Vite (with `rolldown` or `esbuild`) requires Node.js **20.19+** or **22.12+**. Use Node.js v22.x LTS.

## Compiling Native Modules
For GitHub Actions with network access (`--share=network`):
1. **Node.js Headers**: Download `node-vXX.XX.X-headers.tar.gz` as an `archive` source.
2. **Set `npm_config_nodedir`**: Point this to extracted headers for offline native module compilation.
3. **Ship `node-gyp` explicitly when needed**: For Bun/Electron apps with native modules, do not assume the builder image already exposes `node-gyp`. If CI shows `node-gyp: command not found`, add a manifest module that installs `node-gyp` into `/app/bin` before the app build.

## Bun Projects
- **Treat Bun as an app dependency, not a GitHub Actions setup step**: In this repository the authoritative build runs inside `flatpak-builder`, so install Bun in the manifest as a module that places `bun` in `/app/bin`.
- **Keep Node available alongside Bun**: Many Bun-based desktop apps still rely on Node tooling, Tauri helpers, or transitive packages that assume `node` exists. Prefer the `org.freedesktop.Sdk.Extension.node24` SDK extension for build-time Node.
- **Runtime Node is separate**: SDK extensions are build-time only. If the packaged app launches Node at runtime, such as a Tauri sidecar script, ship a Node runtime in `/app/bin` as a regular manifest module.
- **Cache Bun explicitly**: Set `BUN_INSTALL_CACHE_DIR` to a writable build directory such as `/run/build/<module>/bun-cache`.
- **Native Bun dependencies follow the same header rules**: If `bun install` triggers native rebuilds, use vendored Node headers and add `node-gyp` explicitly just like pnpm/npm builds.

## The TAR_OPTIONS and Permissions Fix
Flatpak sandboxes block `fchown`.
- **Fix**: Use the YAML block scalar `|` to ensure environment variables persist. For `pnpm`, use **Double Insurance**:
  1. **Config Set**: `pnpm config set nodedir /app/etc/node-headers` and `pnpm config set unsafe-perm true`.
  2. **Env Vars**: Set `export TAR_OPTIONS="--no-same-owner"` and `export npm_config_unsafe_perm=true`.
- **Why vendoring headers matters**: in this repo, native rebuilds have failed when `node-gyp` downloaded headers dynamically and tar attempted ownership operations during extraction (`TAR_ENTRY_ERROR EINVAL`, `fchown`). Vendoring the exact headers tarball as a manifest source and unpacking it under `/app/etc/node-headers` avoids that failure mode.

```yaml
    build-commands:
      - |
        set -e
        pnpm config set nodedir /app/etc/node-headers
        export TAR_OPTIONS="--no-same-owner"
        pnpm install
```
