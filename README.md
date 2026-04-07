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

### 5. Force Update or Reinstall

If you see "already installed" but want to force the latest version (e.g., after a fix):

**Option A: Standard Update**
```bash
flatpak update --user io.github.coulsontl.ai_toolbox
```

**Option B: Force Reinstall (Recommended for debugging fixes)**
```bash
flatpak install --user --reinstall ai-tools-repo io.github.coulsontl.ai_toolbox
```

### 6. Run

```bash
flatpak run io.github.coulsontl.ai_toolbox
```

### 7. Update All Installed Applications

```bash
flatpak update
```

## Contribution

Refer to the workspace skill in `flatpak-repo-workflow/` for
packaging standards and workflows.
