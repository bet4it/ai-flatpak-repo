#!/bin/bash
# Automation script: Build applications and update OSTree repository index locally

REPO_DIR="repo"

echo "==> Cleaning old build artifacts..."
rm -rf build-dir/

# Discover all .yaml manifests in subdirectories
MANIFESTS=$(find . -maxdepth 2 -not -path '*/.*' -name "*.yaml")

for manifest in $MANIFESTS; do
    app_id=$(basename "$manifest" .yaml)
    echo "==> Building $app_id..."
    flatpak-builder --user --force-clean --ccache --install-deps-from=flathub --repo=$REPO_DIR --subject="Update $app_id" build-dir "$manifest"
done

echo "==> Updating repository summary..."
flatpak build-update-repo $REPO_DIR

echo "==> Done. You can now serve the '$REPO_DIR' directory via HTTP."
