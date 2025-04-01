# mute

[![Run tests](https://github.com/mgree/mute/actions/workflows/test.yaml/badge.svg)](https://github.com/mgree/mute/actions/workflows/test.yaml)

`mute $PID` silences `$PID`---closing STDOUT and STDIN (or, if you
like, every file descriptor pointing to a terminal).

GUI applications often produce debugging or error output as they
run. If you start a GUI application from a terminal and forget to
redirect their output, these messages can clutter your
terminal. `mute` attaches to a running process and intervenes,
redirecting output to `/dev/null`.

## Getting started

```
Usage: mute [-tfandv] [-o TARGET] PID [FD ...]

  -t         only close FDs if they are ttys (if no FDs specified, will close all tty FDs)
  -f         close FDs unconditionally
  -a         append to TARGET rather than truncating
  -n         dry run; shows the GDB script to be used, but does not run it
  -d         debug mode (shows debugging output on stdout; repeat to increase output)
  -v         show version information and exit
  -o TARGET  redirect FDs to TARGET [default: /dev/null]
             relative paths are relative to `mute`'s current directory, not PID's

  FD can be a decimal number or one of stdout, stderr, or stdin

  Running `mute PID` is the same as `mute -t PID stdout stderr`: FDs 1 and 2 will be
  closed if they are tty FDs.
```

### Dependencies

`mute` uses the GNU debugger, `gdb`, to intervene on processes. `mute`
will not work without `gdb`.

Autodetecting file descriptors that point at ttys with `mute -a`
currently depends on `procfs`, and will fail if `/proc/PID/fd/` does
not exist.

### Installing

All you really need is the [`mute`
script](https://raw.githubusercontent.com/mgree/mute/main/mute). For a nicer, more formal install, you can [download a release](https://github.com/mgree/mute/releases) and do a standard install:

```shellsession
$ wget -q https://github.com/mgree/mute/releases/download/latest/mute-latest.tgz
$ tar xzf mute-latest.tgz
$ cd mute-*
$ ./configure
checking for a BSD-compatible install... /usr/bin/install -c
checking for gdb... yes
checking for mktemp... yes
checking for pandoc (for manpage)... yes
checking for gzip (for manpage)... yes
checking for expect (for tests)... yes
checking for sleep (for tests)... yes
configure: creating ./config.status
config.status: creating Makefile
------------------------------------------------------------------------
mute version 0.1.0

Prefix: /usr/local
Compiling utilities:

To build and install, run:

  make && make install
------------------------------------------------------------------------
$ make && make install
pandoc --standalone --from markdown-smart --to man -o man/mute.1 man/mute.1.md
gzip <man/mute.1 >man/mute.1.gz
/usr/bin/install -c -d /usr/local/bin
/usr/bin/install -c -m 755 mute /usr/local/bin
/usr/bin/install -c -d /usr/local/share/man/man1
/usr/bin/install -c -m 644 man/mute.1.gz /usr/local/share/man/man1
```

As usual, you can use `./configure --prefix` to control the installation prefix.

If you clone [the repo](https://github.com/mgree/mute), you will need
to run `autoconf` to generate the `configure` script, which will
generate the `Makefile`.

### Running tests

You can run the test suite using `./run_tests.sh` or `make test`.

```shellsession
$ make test
./run_tests.sh
RUNNING ALL 17 TESTS FOR mute

SCRIPT TEST force.explicit12.sh:               PASS

SCRIPT TEST force.only1.sh:                    PASS

SCRIPT TEST saved.123.sh:                      PASS

SCRIPT TEST saved.12.sh:                       PASS

SCRIPT TEST error.badpid.sh:                   PASS

SCRIPT TEST force.output.sh:                   PASS

SCRIPT TEST racy.force.implicit12.sh:          PASS

SCRIPT TEST force.names.sh:                    PASS

SCRIPT TEST force.output.append.sh:            PASS

SCRIPT TEST force.implicit12.sh:               PASS

SCRIPT TEST saved.321.sh:                      PASS

EXPECT TEST auto.saved.allttys.exp:            PASS

EXPECT TEST auto.names.exp:                    PASS

EXPECT TEST auto.saved.implicit12.exp:         PASS

EXPECT TEST auto.implicit12.exp:               PASS

EXPECT TEST auto.notty1.implicit12.exp:        PASS

EXPECT TEST auto.explicit12.exp:               PASS

SUMMARY: PASSED 17/17 TESTS, FAILED 0 TESTS
```

The `run_tests.sh` script accepts filters on its arguments in case you
would like to run a particular test.

### Contributing

All contributions must be signed off as
[GPLv3](https://github.com/mgree/mute/blob/main/LICENSE), i.e., a PR
must include a `Signed-off-by:` line.

Project-specific lints are run in `run_lints.sh`; PRs that do not pass
the linter will not be accepted. If at all possible, PRs should come
with tests that confirm the new behavior.

## Version history

+ v0.1.0
  - Initial release.

## License

This project is licensed under the GNU General Public License,
version 3. See
[LICENSE](https://raw.githubusercontent.com/mgree/mute/main/LICENSE)
for details.

Copyright (c) 2025 Michael Greenberg.
