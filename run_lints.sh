#!/bin/sh

: "${MUTE_TOP=$(git rev-parse --show-toplevel --show-superproject-working-tree 2>/dev/null || echo "${0%/*}")}"

cd "$MUTE_TOP" || exit 1

LINTS=$(find ./lints -type f -executable)
printf "Running %d lints: " "$(echo "$LINTS" | wc -l)"
log=$(mktemp)
errors=0
for lint in $LINTS
do
    out=$(mktemp)
    if "$lint" >"$out" 2>&1
    then
        printf "."
    else
        printf "x"
        : "$((errors += 1))"
        if [ "$errors" -gt 0 ]
        then
            echo >>"$log"
        fi
        echo "${lint#./} FAILED" >>"$log"
        cat "$out" >>"$log"
    fi
    rm "$out"
done

if [ "$errors" -eq 0 ]
then
    echo " OK!"
else
    echo " FAILED $errors."
fi

cat "$log"
rm "$log"
exit "$errors"
