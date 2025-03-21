#!/bin/sh
# shellcheck disable=SC2164

MUTE_TOP="${MUTE_TOP:-$(git rev-parse --show-toplevel --show-superproject-working-tree 2>/dev/null || echo "${0%/*}")}"
MUTE="$MUTE_TOP/mute"

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
PID=$(python3 -c "import secrets; print(secrets.randbelow($PID_MAX))")
while kill -0 "$PID" >/dev/null 2>&1
do
    PID=$(python3 -c "import secrets; print(secrets.randbelow($PID_MAX))")
done

"$MUTE" "$PID" >out 2>err && exit 1

[ -f out ] || exit 2
[ "$(stat -c %s out)" -eq 0 ] || { cat out; exit 3; }
[ -f err ] || exit 4
[ "$(cat err)" = "mute: no such process $PID" ] || { cat err; exit 5; }
