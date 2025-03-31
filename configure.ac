AC_PREREQ(2.68)
AC_INIT([mute], [0.1.0], [https://github.com/mgree/mute/issues])

# make sure we're in the right place
AC_CONFIG_SRCDIR([mute])
AC_REQUIRE_AUX_FILE([man/mute.1.md])

# need install
AC_PROG_INSTALL

dnl MUTE_REQUIRE_PROG(progname, checking_msg, pre, true_if_failed, post, fail_msg)
AC_DEFUN([MUTE_REQUIRE_PROG], [
AC_MSG_CHECKING([ifelse([$2], [], [for $1], [$2])])
$3
if ifelse([$4], [], [! type -p $1 >/dev/null 2>&1], [$4])
then
        AC_MSG_RESULT([no])
        AC_MSG_ERROR([mute needs $1 to work, but ifelse([$6], [], [it could not be found], [$6]).])
else
        AC_MSG_RESULT([yes])
        $5
fi
])

MUTE_REQUIRE_PROG([gdb])
MUTE_REQUIRE_PROG([mktemp])

# for manpages
if test -f man/mute.1.gz
then
        need_manpage=no
else
        need_manpage=yes
fi
AC_ARG_ENABLE([manpage],
              [AS_HELP_STRING([--enable-manpage],
                              [generate the manpage instead of using the cached version (requires pandoc, default is no when man/mute.1.gz is present)])],
              [enable_manpage=${enableval}], [enable_manpage=${need_manpage}])
if test "$enable_manpage" = "yes"
then
        AC_MSG_CHECKING([for pandoc (for manpage)])
        if ! type -p pandoc >/dev/null 2>&1
        then
                AC_MSG_RESULT([no])
                enable_manpage="no"
        else
                AC_MSG_RESULT([yes])
        fi

        AC_MSG_CHECKING([for gzip (for manpage)])
        if ! type -p gzip >/dev/null 2>&1
        then
                AC_MSG_RESULT([no])
                enable_manpage="no"
        else
                AC_MSG_RESULT([yes])
        fi

        if test "$enable_manpage" = no
        then
                if test -f man/mute.1.gz
                then
                        AC_MSG_NOTICE([
------------------------------------------------------------------------
WARNING

Your system is missing some programs used to generate the manpage, so
the cached version will be used instead.
------------------------------------------------------------------------
])
                else
                        AC_MSG_ERROR([
------------------------------------------------------------------------
WARNING

Your system is missing some programs used to generate the manpage and
no cached manpage is available.
------------------------------------------------------------------------
])
                fi
        fi
fi
AC_SUBST(enable_manpage)

# programs just used in tests
missing_test_programs=0

AC_PROG_AWK
AC_MSG_CHECKING([whether awk is gawk (for tests)])
if test "$(stat -L -c %i "$(type -p "$AWK")")" != "$(stat -L -c %i "$(type -p awk)")"
then
        AC_MSG_RESULT([no; some tests may behave strangely])
        : $((missing_test_programs += 1))
else
        AC_MSG_RESULT([yes])
fi

dnl MUTE_REQUIRE_PROG(progname)
AC_DEFUN([MUTE_TEST_PROG], [
AC_MSG_CHECKING([for $1 (for tests)])
if ! type -p $1 >/dev/null 2>&1
then
        AC_MSG_RESULT([no; some tests may fail])
        : $((missing_test_programs += 1))
else
        AC_MSG_RESULT([yes])
fi
])

MUTE_TEST_PROG([expect])
MUTE_TEST_PROG([sleep])

if test "$missing_test_programs" -ne 0
then
        AC_MSG_NOTICE([
------------------------------------------------------------------------
WARNING

Your system is missing some programs used in tests, so some tests may
fail.
------------------------------------------------------------------------
])

fi

AC_CONFIG_FILES([Makefile:Makefile.in])
AC_OUTPUT

cat <<EOF
------------------------------------------------------------------------
${PACKAGE_NAME} version ${PACKAGE_VERSION}

Prefix: ${prefix}
Compiling utilities: $enable_utils

To build and install, run:

  make && make install
------------------------------------------------------------------------
EOF
