# Antigravity Interactive Narration Skill (`agy-interactive`)

Give Google Antigravity (`agy`) the interactive, step-by-step feel of **Claude Code**.

By default, Antigravity chains tool calls silently in a single turn and only writes a message after everything is finished. `agy-interactive` installs an always-on rule into `~/.gemini/config/rules/AGENTS.md` (and links the companion skill into `~/.gemini/config/skills/agy-interactive`) so `agy` narrates what it is doing in real time with **short, scannable one-liners**.

---

## What It Changes

- **Keep updates ultra-short**: Every step narration, finding, and summary stays brief and scannable (1 short sentence per step; no walls of text).
- **Narrate before acting**: Never chains silent tool calls. Before reading files, running commands, or editing code, `agy` outputs a single short line stating what it is doing and why.
- **Compact upfront plan**: Starts multi-step tasks with 3–4 short one-line bullets so you see the plan immediately.
- **Brief mid-stream findings**: Shares key discoveries in 1–2 lines before moving to the next step.
- **Check in on decisions**: Pauses and asks briefly when there is a non-trivial trade-off instead of guessing.
- **Concise completion summary**: Finishes with a compact bulleted list of what changed, how it was verified, and clickable `file://` links.

Scoped strictly to **Antigravity (`~/.gemini/config/`)** — leaves Claude Code, Codex, OpenCode, and other harnesses untouched.

---

## Quick Start

```bash
git clone https://github.com/tdulshan3/agy-interactive-skill.git
cd agy-interactive-skill

./install.sh              # link skill + add managed rule block to ~/.gemini/config/rules/AGENTS.md
./install.sh --status     # verify skill link and rules block status
./install.sh --uninstall  # cleanly remove skill link and rule block
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

`./install.sh` manages a fenced block between `<!-- agy-interactive:begin -->` and `<!-- agy-interactive:end -->` inside `~/.gemini/config/rules/AGENTS.md`. Everything else in your `AGENTS.md` is preserved untouched. Re-running `./install.sh` updates the block in place, and `./install.sh --uninstall` removes only that block.
