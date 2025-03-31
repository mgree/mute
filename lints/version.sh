#!/bin/sh

MUTE_TOP="${MUTE_TOP:-$(git rev-parse --show-toplevel --show-superproject-working-tree 2>/dev/null || echo "${0%/*}/..")}"

cd "$MUTE_TOP" || exit 1

V_SCRIPT="$(grep 'MUTE_VERSION=' mute | cut -d'"' -f 2)"
V_MANPAGE="$(grep 'MUTE(1)' man/mute.1.md | cut -d' ' -f 4)"
V_README="$(grep -A 2 '## Version history' README.md | tail -n 1 | cut -d' ' -f 2)"
V_CONFAC="v$(grep AC_INIT configure.ac | cut -d'[' -f3 | cut -d']' -f1)"

echo "Checking versions match..."
echo "      Script: '$V_SCRIPT'"
echo "     Manpage: '$V_MANPAGE'"
echo "      README: '$V_README'"
echo "configure.ac: '$V_CONFAC'"

[ "$V_SCRIPT" = "$V_MANPAGE" ] && [ "$V_SCRIPT" = "$V_README" ] && [ "$V_SCRIPT" = "$V_CONFAC" ]
