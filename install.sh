#!/usr/bin/env bash
# install.sh — Install the `agy-interactive` skill and always-on narration rule
# for Google Antigravity (`agy`) and `dsh`.
#
# Usage:
#   ./install.sh              # link skill + add managed block to Antigravity and dsh rules
#   ./install.sh --status     # check installation state
#   ./install.sh --uninstall  # remove skill links + managed blocks

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_NAME="agy-interactive"
SKILL_SRC="${REPO_DIR}/${SKILL_NAME}"

# name | directory whose presence means the harness is installed | skills dir | always-loaded rules file
HARNESSES=(
  "antigravity|${HOME}/.gemini|${HOME}/.gemini/config/skills|${HOME}/.gemini/config/rules/AGENTS.md"
  "dsh|${HOME}/.dsh|${HOME}/.agents/skills|${HOME}/.dsh/AGENTS.md"
)

usage() {
  cat <<EOF
Usage: ./install.sh [--install | --status | --uninstall]

Options:
  --install     Link the skill and install the always-on narration rule in Antigravity & dsh (default)
  --status      Show installation status for Antigravity & dsh
  --uninstall   Remove the skill symlinks and managed rule blocks
EOF
}

ACTION="install"
if [[ $# -gt 0 ]]; then
  case "$1" in
    --install)   ACTION="install" ;;
    --status)    ACTION="status" ;;
    --uninstall) ACTION="uninstall" ;;
    -h|--help)   usage; exit 0 ;;
    *)           echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
fi

find_python() {
  if command -v python >/dev/null 2>&1 && python -c "import sys" >/dev/null 2>&1; then
    echo "python"
    return 0
  fi
  if command -v python3 >/dev/null 2>&1 && python3 -c "import sys" >/dev/null 2>&1; then
    echo "python3"
    return 0
  fi
  if command -v py >/dev/null 2>&1 && py -3 -c "import sys" >/dev/null 2>&1; then
    echo "py -3"
    return 0
  fi
  return 1
}

link_skill() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "${dest}")"
  rm -rf "${dest}"
  if ln -sfn "${src}" "${dest}" 2>/dev/null; then
    echo "  [SKILL] ${dest}"
  else
    cp -r "${src}" "${dest}"
    echo "  [SKILL] ${dest} (copied)"
  fi
}

update_rules() {
  local harness="$1" rules_file="$2" mode="${3:-write}"
  if [[ "${mode}" == "remove" && ! -f "${rules_file}" ]]; then
    return 0
  fi
  mkdir -p "$(dirname "${rules_file}")"

  local py_cmd
  if ! py_cmd="$(find_python)" || [[ -z "${py_cmd}" ]]; then
    echo "Error: Python 3 is required to update rules files but was not found." >&2
    exit 1
  fi

  ${py_cmd} - "${harness}" "${rules_file}" "${mode}" <<'PY'
import re, sys
from pathlib import Path

harness, rules_str, mode = sys.argv[1:4]
rules_path = Path(rules_str)
text = rules_path.read_text(encoding="utf-8") if rules_path.exists() else ""

begin = "<!-- agy-interactive:begin -->"
end = "<!-- agy-interactive:end -->"
block = f"""{begin}
## Interactive Progress & Step-by-Step Narration (`agy` & `dsh`)

- **Informative & scannable updates**: Provide clear, informative step narrations (1-2 sentences) that explain both what you are doing and the concrete reason/intent. Avoid overly terse fragments or multi-paragraph walls of text.
- **Narrate before acting with reasons**: Never chain silent tool calls. Before invoking tools, explicitly explain BOTH what you are doing and why (the specific intent, hypothesis, or what you expect to find/verify). Never output a bare action (e.g., "Reading file X") without the reason.
- **Compact upfront plan**: For multi-step tasks, start with 3-4 short bullet points (one line each) showing the steps and their purpose.
- **Brief mid-stream findings**: Share key discoveries (root cause, relevant file/function, or command insight) in 1-2 lines before moving to the next step.
- **Check in on decisions**: Pause and ask briefly when there is a non-trivial trade-off.
- **Concise completion summary**: Finish with a compact bulleted list of what changed, why it was changed, how it was verified, and clickable file/symbol links.
{end}"""

managed_re = re.compile(re.escape(begin) + r".*?" + re.escape(end), re.S)
legacy_re = re.compile(
    r"^## (?:\d+\.\s*)?Interactive Progress & Step-by-Step Narration \([^\n]*\)\n+(?:- .*\n)+",
    re.M,
)

if mode == "remove":
    new = managed_re.sub("", text)
    new = re.sub(r"\n{3,}", "\n\n", new).rstrip() + "\n" if new.strip() else ""
elif managed_re.search(text):
    new = managed_re.sub(lambda _: block, text)
elif legacy_re.search(text):
    new = legacy_re.sub(lambda _: block + "\n\n", text)
    new = re.sub(r"\n{3,}", "\n\n", new).rstrip() + "\n"
elif "<!-- agent-memory:begin -->" in text:
    new = text.replace("<!-- agent-memory:begin -->", block + "\n\n<!-- agent-memory:begin -->", 1)
else:
    new = (text.rstrip() + "\n\n" if text.strip() else "# Global Agent Rules\n\n") + block + "\n"

if mode == "remove" and not new and text:
    rules_path.unlink()
    print(f"  [REMOVED] {rules_path}")
elif new != text:
    rules_path.write_text(new, encoding="utf-8")
    print(f"  [{'REMOVED' if mode == 'remove' else 'RULES'}] {rules_path}")
else:
    print(f"  [KEEP]  {rules_path}")
PY
}

if [[ "${ACTION}" == "status" ]]; then
  for row in "${HARNESSES[@]}"; do
    IFS='|' read -r name detect skills rules <<<"${row}"
    [[ -d "${detect}" ]] || { echo "=== ${name}: not installed on this machine"; continue; }
    echo "=== ${name}"
    if [[ -L "${skills}/${SKILL_NAME}" && -d "${skills}/${SKILL_NAME}" ]]; then
      echo "  [SKILL]    ${skills}/${SKILL_NAME} -> $(readlink -f "${skills}/${SKILL_NAME}")"
    elif [[ -d "${skills}/${SKILL_NAME}" ]]; then
      echo "  [SKILL]    ${skills}/${SKILL_NAME} (installed directory)"
    else
      echo "  [MISSING]  ${skills}/${SKILL_NAME}"
    fi
    if grep -q "agy-interactive:begin" "${rules}" 2>/dev/null; then
      echo "  [AUTO]     ${rules}"
    else
      echo "  [NO AUTO]  ${rules}"
    fi
  done
  exit 0
fi

if [[ "${ACTION}" == "uninstall" ]]; then
  for row in "${HARNESSES[@]}"; do
    IFS='|' read -r name detect skills rules <<<"${row}"
    if [[ -L "${skills}/${SKILL_NAME}" || -d "${skills}/${SKILL_NAME}" ]]; then
      rm -rf "${skills}/${SKILL_NAME}"
      echo "  [REMOVED] ${skills}/${SKILL_NAME}"
    fi
    update_rules "${name}" "${rules}" remove
  done
  exit 0
fi

for row in "${HARNESSES[@]}"; do
  IFS='|' read -r name detect skills rules <<<"${row}"
  if [[ ! -d "${detect}" ]]; then
    echo "=== ${name}: not installed on this machine, skipped"
    continue
  fi
  echo "=== ${name}"
  link_skill "${SKILL_SRC}" "${skills}/${SKILL_NAME}"
  update_rules "${name}" "${rules}" write
done
