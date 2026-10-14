#!/bin/bash
# test-calvin-remind.sh — regression tests for calvin-remind.sh. Runs in a throwaway dir via
# HOOK_STATE_DIR; real markers are untouched. Usage: hooks/test-calvin-remind.sh  (exit 1 on any failure)
H=$(cd "$(dirname "$0")" && pwd)
Q=$(mktemp -d "${TMPDIR:-/tmp}/calvin-remind-test.XXXX")
trap 'rm -rf "$Q"' EXIT
fail=0
check() { if eval "$2"; then echo "PASS $1"; else echo "FAIL $1"; fail=1; fi; }
fresh() { mktemp -d "$Q/st.XXXX"; }
calvin() { printf '{"session_id":"%s","tool_input":{"file_path":"%s"}}' "$1" "$2" | HOOK_STATE_DIR=$3 "$H/calvin-remind.sh"; }

S=$(fresh)
o=$(calvin s1 /x/implementation-plan.md "$S")
check "plan → additionalContext naming /claude-mem:do" '[ "$(printf "%s" "$o" | jq -r .hookSpecificOutput.additionalContext | grep -c claude-mem:do)" = 1 ]'
check "same file again in session → silent" '[ -z "$(calvin s1 /x/implementation-plan.md "$S")" ]'
for f in plan.md claude-code-integration-plan.md PLAN.MD plans.md my_plan_v2.md; do
  check "$f → plan message" '[ -n "$(calvin s2 "/x/$f" "$(fresh)" | grep claude-mem:do)" ]'
done
for f in api-spec.md design.md prd.md brief.md shape.md rfc-12.md specification.md; do
  check "$f → spec message" '[ -n "$(calvin s3 "/x/$f" "$(fresh)" | grep Spec-shaped)" ]'
done
for f in explanation.md airplane.md planet.md inspection.md notes.md plan.txt; do
  check "$f → silent" '[ -z "$(calvin s4 "/x/$f" "$(fresh)")" ]'
done
repo=$(cd "$HOME/.claude/skills/calvin" 2>/dev/null && pwd -P)
if [ -n "$repo" ]; then
  check "calvin repo (via ~/.claude/skills/calvin) skipped" '[ -z "$(calvin s5 "$repo/plan.md" "$(fresh)")" ]'
else
  echo "SKIP calvin repo skip check (~/.claude/skills/calvin not installed)"
fi
o=$(printf 'not json' | HOOK_STATE_DIR=$(fresh) "$H/calvin-remind.sh" 2>&1); r=$?
check "garbage input → exit 0, no output" '[ $r = 0 ] && [ -z "$o" ]'
o=$(calvin s6 '/x/my \"odd\" plan.md' "$(fresh)")
check "quotes in path → valid JSON" 'printf "%s" "$o" | jq -e .hookSpecificOutput >/dev/null'
S=$(fresh); ln -s "$Q/symlink-target" "$S/calvin-remind-$(printf '%s' "s7/x/plan.md" | shasum | cut -c1-12)"
o=$(calvin s7 /x/plan.md "$S")
check "dangling-symlink marker → silent, nothing created at target" '[ -z "$o" ] && [ ! -e "$Q/symlink-target" ]'
check "syntax" 'bash -n "$H/calvin-remind.sh"'

[ $fail = 0 ] && echo "ALL PASS" || { echo "FAILURES"; exit 1; }
