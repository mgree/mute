#!/bin/sh

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

"$CHAT" -s >out 2>err &
PID="$!"
sleep 0.05
"$MUTE" -dd -f "$PID" 3 2 1 || exit 1
wait "$PID" || exit 2

[ -f out ] || exit 3
[ "$(stat -c %s out)" -eq 0 ] || { cat out; exit 4; }
[ -f err ] || exit 5
[ "$(stat -c %s err)" -eq 0 ] || { cat err; exit 6; }
