#!/bin/sh
# shellcheck disable=SC2164

MUTE_TOP="${MUTE_TOP:-$(git rev-parse --show-toplevel --show-superproject-working-tree 2>/dev/null || echo "${0%/*}/..")}"
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

"$CHAT" -w >out 2>err &
PID="$!"
"$MUTE" -d -f -o log "$PID" || exit 1
kill -USR1 "$PID"
wait "$PID" || exit 2

[ -f out ] || exit 3
[ "$(cat out)" = "stdout" ] || { cat out; exit 4; }
[ -f err ] || exit 5
[ "$(cat err)" = "stderr" ] || { cat err; exit 6; }

[ -f log ] || exit 7
for i in $(seq 1 5)
do
    printf "stdout %d\nstderr %d\n" "$i" "$i" >>log.exp
done

if ! diff -q log.exp log
then
    git diff --word-diff=plain --word-diff-regex=. log.exp log
    exit 8
fi
