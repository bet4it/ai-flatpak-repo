# AI-driven Automated Flatpak Build Repository

## Usage

### 1. Add Repository

```bash
flatpak --user remote-add --no-gpg-verify ai-tools-repo https://bet4it.github.io/ai-flatpak-repo/
```

### 2. Install Applications

Example:

```bash
flatpak install ai-tools-repo io.github.spacecake_labs.spacecake
```

### 3. Run

```bash
flatpak run io.github.spacecake_labs.spacecake
```

## Contribution

Refer to the workspace skill in `.gemini/skills/flatpak-repo-manager/` for
packaging standards and workflows.
