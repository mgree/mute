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
script](https://raw.githubusercontent.com/mgree/mute/main/mute).

## Version history

+ v0.1.0
  - Initial release.

## License

This project is licensed under the GNU General Public License,
version 3. See
[LICENSE](https://raw.githubusercontent.com/mgree/mute/main/LICENSE)
for details.

Copyright (c) 2025 Michael Greenberg.
