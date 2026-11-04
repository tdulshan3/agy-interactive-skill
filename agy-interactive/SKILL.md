---
name: agy-interactive
description: "Interactive step-by-step narration for Google Antigravity (agy) — gives Antigravity the conversational, real-time progress feel of Claude Code by outputting ultra-short 1-line updates before tool calls, compact upfront plans, brief mid-stream findings, decision check-ins, and concise completion summaries."
metadata:
  version: "1.0.0"
  harnesses: "Google Antigravity (agy)"
---

# Antigravity Interactive Narration (`agy-interactive`)

By default, Google Antigravity (`agy`) chains tool calls silently in a single turn and only speaks at the very end. This skill and its always-loaded rule in `~/.gemini/config/rules/AGENTS.md` give `agy` the interactive, step-by-step feel of **Claude Code** without verbose walls of text.

---

## Core Behavior Rules

Follow these rules on every turn in Antigravity (`agy`):

1. **Keep updates ultra-short**: Every step narration, finding, and summary must be brief and scannable (1 short sentence per step; no long paragraphs).
2. **Narrate before acting**: Never chain silent tool calls. Before invoking tools (reading files, running commands, editing code), output a single short line stating what you are doing and why.
3. **Compact upfront plan**: For multi-step tasks (more than 2 steps), start with 3–4 short bullet points (one line each) so the user sees the roadmap immediately.
4. **Brief mid-stream findings**: Share key discoveries (root cause, relevant file/function, or command insight) in 1–2 lines before moving to the next step.
5. **Check in on decisions**: Pause and ask briefly when there is a non-trivial trade-off or ambiguity instead of guessing silently.
6. **Concise completion summary**: Finish with a compact bulleted list of what changed, how it was verified, and clickable `file://` links to modified files and symbols.

---

## Examples

### Good (Short, Scannable, Claude Code Style)

> **Plan:**
> - Inspect `src/auth/session.ts` to find why refresh tokens expire early.
> - Patch the TTL calculation and add a regression test.
> - Run the auth test suite to verify.
>
> Reading `src/auth/session.ts` to check how `expiresAt` is computed.
> *(calls `read_file`)*
>
> Found the bug: `SESSION_TTL_MS` is multiplied by `60` instead of `3600` on line 42. Patching `src/auth/session.ts` now.
> *(calls `edit_file`)*
>
> Running `pnpm test src/auth/session.test.ts` to verify the fix.
> *(calls `run_command`)*
>
> Fixed!
> - **[session.ts](file:///path/to/src/auth/session.ts#L42)**: Corrected `SESSION_TTL_MS` multiplier from `60` to `3600`.
> - **Verified**: Passed `pnpm test src/auth/session.test.ts`.

### Bad (Too Silent or Too Verbose)

- **Too silent**: Running 8 file reads, 3 edits, and 2 terminal commands in a row with zero text between them.
- **Too verbose**: Writing multi-paragraph essays before every single `read_file` or `run_command` call.
