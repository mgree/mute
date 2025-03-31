#!/bin/sh
# shellcheck disable=SC2059

COMMAND=${0##*/}

usage() {
    cat >&2 <<EOF
Usage: $COMMAND [PAT ...]

  Run the test suite. By default, all tests are run.

  You can specify tests to run using PAT using grep regex syntax.
  If a test matches any pattern, it will be selected and run.
EOF
}

while getopts ":h" opt
do
    case "$opt" in
        (h) usage
            exit 0;;
        (*) usage
            exit 2;;
    esac
done

: "${MUTE_TOP=$(git rev-parse --show-toplevel --show-superproject-working-tree 2>/dev/null || echo "${0%/*}")}"

if ! [ -d "$MUTE_TOP/tests" ]
then
    MUTE_TOP="$PWD"
fi

MUTE_TOP="$(cd "$MUTE_TOP" || exit 1; pwd)" || {
    echo "$COMMAND: couldn't find the root of the mute distribution"
    exit 2
}

TEST_DIR="$MUTE_TOP/tests"
if ! [ -d "$TEST_DIR" ]
then
    echo "$COMMAND: couldn't find test directory (looked in $TEST_DIR)"
    exit 2
fi
export MUTE_TOP

selected="$(mktemp)"
if [ "$#" -eq 0 ]
then
    # no patterns, so select all tests
    echo '.*' >"$selected"
else
    printf "%s\n" "$@" >"$selected"
fi

find_tests() {
    find "$TEST_DIR" -type f -executable -name '*.sh' | sort -R
    find "$TEST_DIR" -type f -executable -name '*.exp' | sort -R
}
COUNT_OF_ALL_TESTS="$(find_tests | wc -l)"
TESTS="$(find_tests | grep -f "$selected")"
COUNT_OF_SELECTED_TESTS="$(echo "$TESTS" | wc -l)"
rm "$selected"

plural() {
    if [ "$1" -ne 1 ]
    then
        echo "S"
    fi

}

if [ "$COUNT_OF_SELECTED_TESTS" -eq "$COUNT_OF_ALL_TESTS" ]
then
    SELECTED_MSG="ALL $COUNT_OF_ALL_TESTS"
else
    SELECTED_MSG="$COUNT_OF_SELECTED_TESTS OF $COUNT_OF_ALL_TESTS"
    SKIPPED_COUNT=$((COUNT_OF_ALL_TESTS - COUNT_OF_SELECTED_TESTS))
    SKIPPED_MSG=" (SKIPPED $SKIPPED_COUNT UNSELECTED TEST$(plural $SKIPPED_COUNT))"
fi

echo "RUNNING $SELECTED_MSG TESTS FOR mute"

FAILED=0
PASSED=0
for test in $TESTS
do
    name="$(basename "$test")"
    case "$name" in
        (*.sh)  kind="SCRIPT";;
        (*.exp) kind="EXPECT"
                if ! type expect >/dev/null 2>&1
                then
                    printf "\nTEST $name:%$((40 - (5 + ${#name} + 1) ))s" ""
                    printf "FAIL (could not find 'expect')\n"
                    : $((FAILED += 1))
                    continue
                fi
                ;;
    esac

    printf "\n$kind TEST $name:%$((40 - (5 + ${#name} + 1) ))s" ""

    out=$(mktemp)
    err=$(mktemp)
    "$test" >"$out" 2>"$err"
    ec=$?

    if [ "$ec" -eq 0 ]
    then
        : $((PASSED += 1))
        printf "PASS\n"
    else
        : $((FAILED += 1))
        printf "FAIL (\$?=$ec)\n"

        printf "STDOUT:\n=======\n"
        cat "$out"
        printf "=======\n\nSTDERR:\n=======\n"
        cat "$err"
        printf "=======\n"
    fi

    rm "$out" "$err"
done

printf "\nSUMMARY: PASSED $PASSED/$COUNT_OF_SELECTED_TESTS TEST$(plural "$PASSED"), FAILED $FAILED TEST$(plural "$FAILED")$SKIPPED_MSG\n"
[ "$PASSED" -eq "$COUNT_OF_SELECTED_TESTS" ]
