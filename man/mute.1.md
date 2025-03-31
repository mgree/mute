% MUTE(1) mute v0.1.0 | silence a running command
% Michael Greenberg

# NAME

mute - silence a running command

# SYNOPSIS
| **mute** [-dfnt] *PID* [*FD ...*]
| **mute** [-adfnt] -o *TARGET* *PID* [*FD ...*]
| **mute** -v
| **mute** -h

# DESCRIPTION

**mute** silences an already running command. **mute** uses *gdb* to modify a running process. By default, it will redirect *stdout* (file descriptor 1) and *stderr* (file descriptor 2) to */dev/null*. If the redirection fails, it will close the file descriptor. It is also possible to have **mute** capture the output, using the **-o** *TARGET* option to redirect output to a given *TARGET*.

Each *FD* can be a file descriptor number or one of *stdin* (meaning 0), *stdout* (meaning 1), or *stderr* (meaning 2). File descriptors are case insensitive.

## Flags

**-a**

: Append output to *TARGET* rather than truncating it. Only has an effect when **-o** *TARGET* is supplied.

**-d**

: Debug mode. Repeat for more verbose output.

**-f**

: Close all file descriptors unconditionally. (Normally, **mute** will only close the specified file descriptors if they are ttys according to **isatty()**. Overrides **-t**.

**-h**

: Show a usage message (and exit).

**-n**

: Dry run mode: does everything short of actually muting the process.

**-t**

: Only close FDs if they are ttys. If no *FD*s are specified, will close all file descriptors that are open on a tty. (Detecting all open file descriptors relies on **/proc/***PID***/fd**, and will fail if **/proc** is not mounted or inaccessible.) Overrides **-f**.

**-v**

: Show version information (and exit).

## Options

**-o** *TARGET*

: Redirect the given file descriptors to *TARGET* instead of */dev/null*.

## Arguments

*PID*

: The process id of the process to mute. You can use **pidof** to search for processes by name, but note that these may not be unique.

*FD ...*

: File descriptors to redirect to *TARGET* (defaults to */dev/null*). May be a non-negative number or a case-insensitive named FD (*stdin* is 0, *stdout* is 1, *stderr* is 2). If unspecified, defaults to *stdout stderr*, i.e., 1 2.

# EXIT STATUS

0

: Ran successfully.

1

: Runtime error: could not find *PID* or could not auto-detect file descriptors with **-t**.

2

: Could not interpret command-line arguments.

# EXAMPLES

To mute the background command you just ran, run **mute $!**.

To mute a command by name, run **mute $(pidof -sx ***NAME***)**.

# SEE ALSO

**gdb**(1), **isatty**(3), **null**(4), **pidof**(8), **proc**(5), **pty**(7)

# BUGS

See
[https://github.com/mgree/mute/issues](https://github.com/mgree/mute/issues).

# LICENSE

Copyright (c) 2025 Michael Greenberg. GPLv3 licensed.
