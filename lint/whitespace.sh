#!/bin/sh

MUTE_TOP="${MUTE_TOP:-$(git rev-parse --show-toplevel --show-superproject-working-tree 2>/dev/null || echo "${0%/*}/..")}"

tab="$(printf "\t")"
errors=0
# shellcheck disable=SC2044
for file in $(find "$MUTE_TOP" -type f \! -path '*/.git/*')
do
    relpath="${file#"$MUTE_TOP/"}"

    # find trailing whitespace
    if grep -I -lq -e '[[:blank:]]$' "$file"
    then
        echo "$relpath: trailing whitespace"
        grep --line-number -e '[[:blank:]]$' "$file" | sed 's/[[:blank:]]\+$/\o33[41m&\o033[0m/'
        : $((errors += 1))
    fi

    # find tabs (ignoring Makefiles!)
    if grep -I -lq -e "$tab" "$file" && ! [ "$(basename "$file")" = "Makefile" ]
    then
        echo "$relpath: tabs"
        grep --line-number -e "$tab" "$file" | sed 's/\t$/\o33[41m&\o033[0m/'
        : $((errors += 1))
    fi

    # ensure final newline
    last="$(tail -c1 "$file")"
    if [ "$last" != "$(printf '\n')" ]
    then
        echo "$relpath: missing a trailing newline"
    fi
done
exit "$errors"
