#!/bin/bash
# test-calvin-remind.sh — regression tests for calvin-remind.sh. Runs in a throwaway dir via
# HOOK_STATE_DIR; real markers are untouched. Usage: hooks/test-calvin-remind.sh  (exit 1 on any failure)
H=$(cd "$(dirname "$0")" && pwd)
Q=$(mktemp -d "${TMPDIR:-/tmp}/calvin-remind-test.XXXX") && [ -d "$Q" ] || { echo "FAIL setup: mktemp"; exit 1; }
trap 'rm -rf "$Q"' EXIT
fail=0
check() { if eval "$2"; then echo "PASS $1"; else echo "FAIL $1"; fail=1; fi; }
fresh() { mktemp -d "$Q/st.XXXX"; }
# A missing state dir would send markers to the real one; print to stdout so every check on this call fails.
calvin() { [ -d "$3" ] || { echo "setup failed: no state dir"; return; }
  printf '{"session_id":"%s","tool_input":{"file_path":"%s"}}' "$1" "$2" | HOOK_STATE_DIR=$3 "$H/calvin-remind.sh"; }

S=$(fresh)
o=$(calvin s1 /x/implementation-plan.md "$S" 2>"$Q/stderr"); r=$?
check "plan → exactly one PostToolUse additionalContext naming /claude-mem:do, exit 0, no stderr" \
  '[ $r = 0 ] && [ ! -s "$Q/stderr" ] && printf "%s" "$o" | jq -se "length == 1 and .[0].hookSpecificOutput.hookEventName == \"PostToolUse\" and (.[0].hookSpecificOutput.additionalContext | contains(\"/claude-mem:do\"))" >/dev/null'
check "same file again in session → silent" '[ -z "$(calvin s1 /x/implementation-plan.md "$S")" ]'
check "same file, new session → fires again" '[ -n "$(calvin s1b /x/implementation-plan.md "$S")" ]'
check "same session, other file → fires again" '[ -n "$(calvin s1 /x/other-plan.md "$S")" ]'
for f in plan.md claude-code-integration-plan.md PLAN.MD plans.md my_plan_v2.md; do
  check "$f → plan message" '[ -n "$(calvin s2 "/x/$f" "$(fresh)" | grep claude-mem:do)" ]'
done
for f in api-spec.md design.md prd.md brief.md shape.md rfc-12.md specification.md specifications.md; do
  check "$f → spec message" '[ -n "$(calvin s3 "/x/$f" "$(fresh)" | grep Spec-shaped)" ]'
done
for f in explanation.md airplane.md planet.md inspection.md notes.md plan.txt; do
  check "$f → silent" '[ -z "$(calvin s4 "/x/$f" "$(fresh)")" ]'
done
check "name ending in a newline (plan.md\\n) → silent" '[ -z "$(calvin s4 "/x/plan.md\\n" "$(fresh)")" ]'
o=$(printf '{"session_id":"s4","tool_input":{"file_path":5}}' | HOOK_STATE_DIR=$(fresh) "$H/calvin-remind.sh" 2>&1); r=$?
check "non-string file_path → exit 0, no output" '[ $r = 0 ] && [ -z "$o" ]'
repo=$(cd "$HOME/.claude/skills/calvin" 2>/dev/null && pwd -P)
if [ -n "$repo" ]; then
  check "calvin repo (via ~/.claude/skills/calvin) skipped" '[ -z "$(calvin s5 "$repo/plan.md" "$(fresh)")" ]'
  check "calvin repo through the ~/.claude/skills/calvin link itself skipped" '[ -z "$(calvin s5 "$HOME/.claude/skills/calvin/PLAN.md" "$(fresh)")" ]'
else
  echo "SKIP calvin repo skip checks (~/.claude/skills/calvin not installed)"
fi
mkdir "$Q/real" && ln -s "$Q/real" "$Q/alias" || { echo "FAIL setup: alias dir"; exit 1; }
S=$(fresh); calvin s8 "$Q/real/plan.md" "$S" >/dev/null
check "same file through a symlinked dir → one marker, silent" '[ -z "$(calvin s8 "$Q/alias/plan.md" "$S")" ]'
o=$(calvin s8 "$Q/alias/plan.md" "$(fresh)")
check "message shows the path as written" 'printf "%s" "$o" | grep -q "$Q/alias/plan.md"'
o=$(printf 'not json' | HOOK_STATE_DIR=$(fresh) "$H/calvin-remind.sh" 2>&1); r=$?
check "garbage input → exit 0, no output" '[ $r = 0 ] && [ -z "$o" ]'
mkdir "$Q/bin" && printf '#!/bin/sh\necho boom >&2\nexit 1\n' > "$Q/bin/shasum" && chmod +x "$Q/bin/shasum" || { echo "FAIL setup: shasum stub"; exit 1; }
S=$(fresh); o=$(printf '{"session_id":"s9","tool_input":{"file_path":"/x/plan.md"}}' | PATH="$Q/bin:$PATH" HOOK_STATE_DIR=$S "$H/calvin-remind.sh" 2>&1); r=$?
check "failing shasum → exit 0, no output, no stderr, no marker" '[ $r = 0 ] && [ -z "$o" ] && [ -z "$(ls -A "$S")" ]'
o=$(calvin s6 '/x/my \"odd\" plan.md' "$(fresh)")
check "quotes in path → valid JSON" 'printf "%s" "$o" | jq -e .hookSpecificOutput >/dev/null'
S=$(fresh); m="$S/calvin-remind-$(printf '%s' "s7/x/plan.md" | shasum | cut -c1-12)"
ln -s "$Q/symlink-target" "$m" && [ -L "$m" ] || { echo "FAIL setup: planted symlink"; exit 1; }
o=$(calvin s7 /x/plan.md "$S")
check "dangling-symlink marker → silent, nothing created at target" '[ -z "$o" ] && [ ! -e "$Q/symlink-target" ]'
check "syntax" 'bash -n "$H/calvin-remind.sh"'

[ $fail = 0 ] && echo "ALL PASS" || { echo "FAILURES"; exit 1; }
