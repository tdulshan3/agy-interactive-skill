# Interactive Narration Skill (`agy-interactive`)

Give Google Antigravity (`agy`) and `dsh` the interactive, step-by-step feel of **Claude Code**.

By default, `agy` and `dsh` often chain tool calls silently in a single turn and only write a message after everything is finished. `agy-interactive` installs an always-on rule block into their global `AGENTS.md` files (and links the skill into their skill directories) so they narrate what they are doing and **why they are doing it** in real time with **clear, informative, and scannable updates**.

---

## What It Changes

- **Informative & scannable updates**: Every step narration, finding, and summary stays clear, scannable, and informative (1–2 sentences per step; no walls of text, no bare fragments).
- **Narrate before acting with explicit reasons**: Never chains silent tool calls. Before reading files, running commands, or editing code, the agent outputs a clear statement explaining BOTH **what it is doing** and the **concrete reason why** (intent, hypothesis, or expected verification). Never outputs bare action-only statements like *"Reading file X"* without context.
- **Compact upfront plan**: Starts multi-step tasks with 3–4 concise one-line bullets showing the roadmap and intent immediately.
- **Detailed mid-stream findings**: Shares key discoveries (root cause, relevant file/function, or command insight) and explains why they matter before moving to the next step.
- **Check in on decisions**: Pauses and asks briefly when there is a non-trivial trade-off instead of guessing silently.
- **Concise completion summary**: Finishes with a compact bulleted list of what changed, why it changed, how it was verified, and clickable `file://` links.

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
