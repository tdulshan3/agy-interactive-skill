# Interactive Narration Skill (`agy-interactive`)

Give Google Antigravity (`agy`) and `dsh` the interactive, step-by-step feel of **Claude Code**.

By default, `agy` and `dsh` often chain tool calls silently in a single turn and only write a message after everything is finished. `agy-interactive` installs an always-on rule block into their global `AGENTS.md` files (and links the skill into their skill directories) so they narrate what they are doing in real time with **short, scannable one-liners**.

---

## What It Changes

- **Keep updates ultra-short**: Every step narration, finding, and summary stays brief and scannable (1 short sentence per step; no walls of text).
- **Narrate before acting**: Never chains silent tool calls. Before reading files, running commands, or editing code, the agent outputs a single short line stating what it is doing and why.
- **Compact upfront plan**: Starts multi-step tasks with 3–4 short one-line bullets so you see the plan immediately.
- **Brief mid-stream findings**: Shares key discoveries in 1–2 lines before moving to the next step.
- **Check in on decisions**: Pauses and asks briefly when there is a non-trivial trade-off instead of guessing.
- **Concise completion summary**: Finishes with a compact bulleted list of what changed, how it was verified, and clickable `file://` links.

---

## Harness Support

`./install.sh` automatically detects and configures both harnesses:

| Harness | Skill Link | Always-Loaded Rules File |
|---|---|---|
| **Antigravity (`agy`)** | `~/.gemini/config/skills/agy-interactive` | `~/.gemini/config/rules/AGENTS.md` |
| **`dsh`** | `~/.agents/skills/agy-interactive` | `~/.dsh/AGENTS.md` |

Claude Code (`~/.claude`) and Codex (`~/.codex`) are untouched.

---

## Quick Start

```bash
git clone https://github.com/tdulshan3/agy-interactive-skill.git
cd agy-interactive-skill

./install.sh              # link skill + add managed rule block to Antigravity and dsh
./install.sh --status     # verify skill links and rules block status
./install.sh --uninstall  # cleanly remove skill links and rule blocks
```

---

## Repository Layout

```text
agy-interactive-skill/
├── install.sh                 # Idempotent installer (--install, --status, --uninstall)
├── README.md
└── agy-interactive/
    └── SKILL.md               # Skill instructions and good/bad narration examples
```

---

## How the Installer Works

`./install.sh` manages a fenced block between `<!-- agy-interactive:begin -->` and `<!-- agy-interactive:end -->` inside `~/.gemini/config/rules/AGENTS.md` and `~/.dsh/AGENTS.md`. Everything else in those files (including `agent-memory` blocks) is preserved untouched. Re-running `./install.sh` updates the block in place, and `./install.sh --uninstall` removes only that block.
