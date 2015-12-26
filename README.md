# Lilypond Version Manager

This is a command-line program meant to ease your use of multiple lilypond versions.
I wrote it in order to enable dynamic versions for [lilybin](http://lilybin.com/)
(my fork is currently under development)

The below documentation is mostly just copy/paste from the CLI since everything
should be self explanatory.  If you have any questions on how to use it, that means
I didn't do my job of making it easy enough - so please file a github issue.


## Lilyvm Constraints
Currently lilyvm is only available on the Linux kernel with machine names of i686 and x86_64
(both found via `uname`).  This is a limitation I impose due to my unfamiliarity
with different architectures and not wanting to test a variety unless necessary.  So
if you find yourself wanting to use lilyvm on an unsupported kernel or machine
(uname nomenclature), then please file a github issue and we'll figure it out from there.


## Install lilyvm
```
# into your home directory
curl -s https://raw.githubusercontent.com/olsonpm/lilyvm/latest/dist/install.sh | sh
```

```
# into a directory of your choice
curl -o delme.sh -s https://raw.githubusercontent.com/olsonpm/lilyvm/latest/dist/install.sh
chmod +x delme.sh
./delme.sh --install-dir /path/to/dir
rm delme.sh
```

Upon finishing, the script will instruct you to modify your shell initialization
script by adding
```
export PATH="<install dir>/bin:${PATH}" # Adds lilyvm to your path
```


## Use lilyvm
```
$ lilyvm --help

Description: A version manager for lilypond

Usage: lilyvm [options] <command>
Options
  -h|--help          print this
  -v|--version       print version of lilyvm

Commands
  disable-colors     disable colors in terminal output
  enable-colors      enable colors in terminal output
  install            install a version of lilypond
  ls                 list installed versions of lilypond
  ls-remote          list hosted versions of lilypond available for install
  uninstall          uninstall a version of lilypond
  uninstall-lilyvm   uninstall lilyvm
  update             update lilyvm to the latest version
  use                set lilypond version for shell use
  using              show current lilypond version

To get help for a command, type lilyvm <command> -h
```

Mostly you will be installing versions of lilypond.  When you install your first
version of lilypond, its bin directory contents are symlinked to lilyvm's, making it
available on your path.  Upon changing versions, the new version's bin directory
contents then become available.  This makes your life easier.
```
$ lilyvm ls-remote

* = currently installed

2.8.8-1
2.10.0-2
2.10.33-1
2.12.0-1
2.12.3-1
2.14.0-1
2.14.2-1
2.16.0-1
2.16.1-1
2.16.2-1
2.18.0-1
2.18.1-1
2.18.2-1

$ lilyvm install -v 2.18.2-1

Downloading install script
######################################################################## 100.0%

Install script executed

Lilypond version 2.18.2-1 was successfully installed

Since this is your first install, the current version is now set to this one.
  Should you decide to install more versions, you may change your current version
  via lilyvm use <version>
```

And you should now have access to lilypond
```
$ which lilypond
/<install dir>/.lilyvm/bin/lilypond

$ lilypond --version
GNU LilyPond 2.18.2

Copyright (c) 1996--2012 by
  Han-Wen Nienhuys <hanwen@xs4all.nl>
  Jan Nieuwenhuizen <janneke@gnu.org>
  and others.

This program is free software.  It is covered by the GNU General Public
License and you are welcome to change it and/or distribute copies of it
under certain conditions.  Invoke as `lilypond --warranty' for more
information.
```
