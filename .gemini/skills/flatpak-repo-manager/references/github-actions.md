# GitHub Actions for Flatpak Deployment

## Global Environment Variables
To ensure all packaging tasks (especially those using `npm`, `pnpm`, or `tar`) work correctly in restricted CI environments:
- **`TAR_OPTIONS: "--no-same-owner"`**: Set this at the top level of `build.yml` to prevent `fchown` errors during dependency installation.
- **`FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: true`**: Silence deprecation warnings for official actions.

## Non-Interactive Commands
Always use non-interactive flags for CLI tools.
- **Run List**: `gh run list --limit 1`
- **Run View**: `gh run view <run-id> --log` or `gh run view --log-failed`

## Multi-App Matrix Build
The workflow uses a `discover` job to find all `.yaml` manifests and a `build` job using a matrix to package them in parallel.

### Infrastructure
- **Container**: Use `ghcr.io/flathub-infra/flatpak-github-actions:freedesktop-24.08`.
- **Deployment**: Uses official `actions/upload-pages-artifact` and `actions/deploy-pages`.

## Troubleshooting
- Check logs: `gh run view --log-failed`.
- Ensure `pages: write` and `id-token: write` permissions are set.
- Ensure GitHub Pages source is set to "GitHub Actions" in repository settings.
