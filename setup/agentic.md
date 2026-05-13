## Agentic AI Setup

### Squad (from https://github.com/bradygaster/squad)
Setup squad using `pnpm`

```bash
pnpm install -D -w @bradygaster/squad-cli
pnpm exec squad init
```

### OpenSpec (from https://github.com/Fission-AI/OpenSpec#quick-start)
Setup using `pnpm`

```bash
pnpm add -g @fission-ai/openspec@latest
```

### Superpower (from https://github.com/obra/superpowers)

#### OpenCode

OpenCode uses its own plugin install; install Superpowers separately even if you
already use it in another harness.

- Tell OpenCode:

  ```
  Fetch and follow instructions from https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/.opencode/INSTALL.md
  ```

- Detailed docs: [docs/README.opencode.md](docs/README.opencode.md)

### Usage

#### Finding Skills

Use OpenCode's native `skill` tool to list all available skills:

```
use skill tool to list skills
```

#### Loading a Skill

```
use skill tool to load superpowers/brainstorming
```

#### Personal Skills

Create your own skills in `~/.config/opencode/skills/`:

```bash
mkdir -p ~/.config/opencode/skills/my-skill
```

Create `~/.config/opencode/skills/my-skill/SKILL.md`:

```markdown
---
name: my-skill
description: Use when [condition] - [what it does]
---

# My Skill

[Your skill content here]
```

#### Project Skills

Create project-specific skills in `.opencode/skills/` within your project.

**Skill Priority:** Project skills > Personal skills > Superpowers skills

### GSD

TBA
