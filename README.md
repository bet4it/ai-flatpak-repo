# AI-driven Automated Flatpak Build Repository

This repository provides automatically built Flatpak applications, primarily focused on AI tools.

## Usage

### 1. Add Repository

Add this repository to your Flatpak remotes:

```bash
flatpak --user remote-add --if-not-exists --no-gpg-verify ai-tools-repo https://bet4it.github.io/ai-flatpak-repo/
```

### 2. Refresh Metadata (MANDATORY for Version Updates)

If you have already added the repo and want to see the latest versions/apps:

```bash
flatpak update --user --appstream ai-tools-repo
```

### 3. List Available Applications

View all applications and their versions in this repository:

```bash
flatpak remote-ls ai-tools-repo
```

### 4. Install Applications

Example (installing AI Toolbox):

```bash
flatpak install ai-tools-repo io.github.coulsontl.ai_toolbox
```

### 5. Run

```bash
flatpak run io.github.coulsontl.ai_toolbox
```

### 6. Update Installed Applications

```bash
flatpak update
```

## Contribution

Refer to the workspace skill in `.gemini/skills/flatpak-repo-manager/` for
packaging standards and workflows.
