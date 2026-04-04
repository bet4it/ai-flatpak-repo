# GitHub Actions for Flatpak Deployment

## Non-Interactive Commands
Always use non-interactive flags for CLI tools.
- **Run List**: `gh run list --limit 1`
- **Run View**: `gh run view <run-id> --json status,conclusion,jobs`

## Multi-App Matrix Build
The workflow uses a `discover` job and a `build` job with a matrix.

### Infrastructure
- **Checkout**: Use `actions/checkout@v6`.
- **Container**: Use `ghcr.io/flathub-infra/flatpak-github-actions:freedesktop-25.08`.
- **Deployment**: Use `actions/upload-pages-artifact@v4` and `actions/deploy-pages@v5`.

### Repository Reconstruction
Use `ostree init --repo=repo --mode=archive-z2` followed by `flatpak build-import-bundle` and `flatpak build-update-repo` for maximum compatibility with runner environments.

## Troubleshooting
- Check logs: `gh run view --job <job-id> --log-failed`.
- Ensure GitHub Pages source is set to "GitHub Actions".
