# Packaging Node.js & Electron Projects

## Environment Setup
Always use `org.electronjs.Electron2.BaseApp`.

**Node Version for Vite**: Modern Vite (with `rolldown` or `esbuild`) requires Node.js **20.19+** or **22.12+**. Use Node.js v22.x LTS.

## Compiling Native Modules
For GitHub Actions with network access (`--share=network`):
1. **Node.js Headers**: Download `node-vXX.XX.X-headers.tar.gz` as an `archive` source.
2. **Set `npm_config_nodedir`**: Point this to extracted headers for offline native module compilation.

## The TAR_OPTIONS and Permissions Fix
Flatpak sandboxes block `fchown`. 
- **Fix**: Use the YAML block scalar `|` to ensure environment variables persist. For `pnpm`, use **Double Insurance**:
  1. **Config Set**: `pnpm config set nodedir /app/etc/node-headers` and `pnpm config set unsafe-perm true`.
  2. **Env Vars**: Set `export TAR_OPTIONS="--no-same-owner"` and `export npm_config_unsafe_perm=true`.

```yaml
    build-commands:
      - |
        set -e
        pnpm config set nodedir /app/etc/node-headers
        export TAR_OPTIONS="--no-same-owner"
        pnpm install
```
