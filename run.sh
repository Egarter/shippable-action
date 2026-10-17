#!/usr/bin/env bash
# Runs inside the action: optionally start the dev server, wait for it, scan, summarize.
set -uo pipefail
url="$SHIPPABLE_URL"
case "$url" in http*) probe="$url" ;; *) probe="http://$url" ;; esac

if [ -n "${SHIPPABLE_START:-}" ]; then
  log=$(mktemp)
  # redirect the whole subshell, or the server keeps this step's output pipe open and the step never ends
  (cd "$SHIPPABLE_DIR" && exec bash -c "$SHIPPABLE_START") >"$log" 2>&1 </dev/null &
  for _ in $(seq 1 60); do curl -s -o /dev/null "$probe" && break; sleep 2; done
  if ! curl -s -o /dev/null "$probe"; then
    echo "::error::$probe did not answer within 2 minutes. Last lines of the server log:"
    tail -30 "$log"
    exit 2
  fi
fi

cd "$SHIPPABLE_DIR" || exit 2
out=$(mktemp)
npx -y "shippable-dev@${SHIPPABLE_VERSION:-latest}" scan "$url" --no-open | tee "$out"
code=${PIPESTATUS[0]}

if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
  { echo "### Shippable scan"; echo '```'; sed 's/\x1b\[[0-9;]*m//g' "$out"; echo '```'; } >> "$GITHUB_STEP_SUMMARY"
fi
exit "$code"
