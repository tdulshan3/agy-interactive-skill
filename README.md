# Interactive Narration Skill (`agy-interactive`)

Make Google Antigravity (`agy`) and `dsh` say what they're doing and why before each tool call, instead of chaining tool calls silently.

`agy-interactive` adds a one-line always-on rule to their global `AGENTS.md` files and links the skill into their skill directories.

---

## What It Changes

Before each tool call (or batch of parallel calls), the agent thinks out loud like a teammate—reacting to what it just found, then saying **what's next** and **why** (instead of repeating robotic lines like *"I am going to..."*). It's a single rule line, so it costs very few tokens.

---

## Harness Support

`install.sh` / `install.ps1` automatically detects and configures both harnesses:

| Harness | Skill Link | Always-Loaded Rules File |
|---|---|---|
| **Antigravity (`agy`)** | `~/.gemini/config/skills/agy-interactive` | `~/.gemini/config/rules/AGENTS.md` |
| **`dsh`** | `~/.agents/skills/agy-interactive` | `~/.dsh/AGENTS.md` |

Claude Code (`~/.claude`) and Codex (`~/.codex`) are untouched.

---

## Quick Start

### Bash (Linux, macOS, Git Bash on Windows)

```bash
git clone https://github.com/tdulshan3/agy-interactive-skill.git
cd agy-interactive-skill

./install.sh              # link skill + add managed rule block to Antigravity and dsh
./install.sh --status     # verify skill links and rules block status
./install.sh --uninstall  # cleanly remove skill links and rule blocks
```

### PowerShell (Windows)

```powershell
git clone https://github.com/tdulshan3/agy-interactive-skill.git
cd agy-interactive-skill

.\install.ps1             # link skill + add managed rule block to Antigravity and dsh
.\install.ps1 -Action status     # verify skill links and rules block status
.\install.ps1 -Action uninstall  # cleanly remove skill links and rule blocks
```

---

## Repository Layout

```text
agy-interactive-skill/
├── install.sh                 # Cross-platform bash installer (--install, --status, --uninstall)
├── install.ps1                # Native Windows PowerShell installer
├── README.md
└── agy-interactive/
    └── SKILL.md               # Skill instructions and good/bad narration examples
```

---

## How the Installer Works

`./install.sh` and `install.ps1` manage a fenced block between `<!-- agy-interactive:begin -->` and `<!-- agy-interactive:end -->` inside `~/.gemini/config/rules/AGENTS.md` and `~/.dsh/AGENTS.md`. Everything else in those files (including `agent-memory` blocks) is preserved untouched. Re-running the installer updates the block in place, and uninstall removes only that block.
