#!/bin/bash
# calvin-remind.sh — Claude Code PostToolUse(Edit|Write) hook: one nudge per spec-like file per session.
# Plans also get pointed at /claude-mem:do, the execution half of make-plan → calvin → do.
# Skips the calvin repo itself (no self-nagging while building calvin).
# Install: ln -sfn ~/projects/calvin/hooks/calvin-remind.sh ~/.claude/hooks/calvin-remind.sh
input=$(cat)
path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null) || exit 0
sid=$(printf '%s' "$input" | jq -r '.session_id // "s"' 2>/dev/null) || exit 0
[ -z "$path" ] && exit 0
repo=$(cd "$HOME/.claude/skills/calvin" 2>/dev/null && pwd -P)
[ -n "$repo" ] && case "$path" in "$repo"/*) exit 0 ;; esac
# Keywords must stand alone in the name, so explanation.md and inspection.md don't match.
name=$(basename "$path" | tr '[:upper:]' '[:lower:]')
case "$name" in *.md) ;; *) exit 0 ;; esac
if printf '%s' "$name" | grep -qE '(^|[^a-z])plans?([^a-z]|$)'; then
  msg="Plan written: $path — run calvin on it before anything implements from it, then execute it with /claude-mem:do (fresh subagent per phase, evidence check after each)."
elif printf '%s' "$name" | grep -qE '(^|[^a-z])(prds?|specs?|specification|designs?|rfcs?|briefs?|shape)([^a-z]|$)'; then
  msg="Spec-shaped file written: $path — run calvin on it before anything implements from it (Calvin questions; the author adjudicates)."
else
  exit 0
fi
out=$(jq -nc --arg m "$msg" '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: $m}}' 2>/dev/null) || exit 0
# mkdir claims the marker atomically and won't follow a planted symlink.
mkdir "${HOOK_STATE_DIR:-${TMPDIR:-/tmp}}/calvin-remind-$(printf '%s' "$sid$path" | shasum | cut -c1-12)" 2>/dev/null || exit 0
# PostToolUse plain stdout only reaches Claude Code's debug log; additionalContext is what Claude sees.
printf '%s\n' "$out"
exit 0
