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

PID_MAX=$(cat /proc/sys/kernel/pid_max)
pid=$(python3 -c "import secrets; print(secrets.randbelow($PID_MAX))")
while kill -0 "$pid" >/dev/null 2>&1
do
    pid=$(python3 -c "import secrets; print(secrets.randbelow($PID_MAX))")
done

"$MUTE" "$pid" >out 2>err

[ "$?" -ne 0 ] || exit 1
[ -f out ] || exit 2
[ "$(stat -c %s out)" -eq 0 ] || { cat out; exit 3; }
[ -f err ] || exit 4
[ "$(cat err)" = "mute: no such process $pid" ] || { cat err; exit 5; }
