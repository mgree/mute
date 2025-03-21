#!/bin/sh
# shellcheck disable=SC2164

MUTE_TOP="${MUTE_TOP:-$(git rev-parse --show-toplevel --show-superproject-working-tree 2>/dev/null || echo "${0%/*}")}"
MUTE="$MUTE_TOP/mute"
CHAT="$MUTE_TOP/tests/chat"

wd=$(mktemp -d)
cd "$wd"
trap cleanup EXIT
cleanup() {
    ec="$?"
    cd
    [ -d "$wd" ] && rm -r "$wd"
    return "$ec"
}

# chat won't wait, but will try to output 100 times
"$CHAT" 100 >out 2>err &
PID="$!"
"$MUTE" -d -f "$PID" || exit 1
wait "$PID" || exit 2

[ -f out ] || exit 3
[ -f err ] || exit 4

out_lines=$(cat out | wc -l)
err_lines=$(cat err | wc -l)

printf "%d lines on stdout and %d lines on stderr\n" "$out_lines" "$err_lines"

[ "$out_lines" -lt 40 ] || exit 5
[ "$err_lines" -lt 40 ] || exit 6

