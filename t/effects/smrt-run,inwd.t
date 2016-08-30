smrt run: effects
=================

setup::

  $ . $TESTROOT/setup

  $ slug=SUSE:Maintenance:1302:87808
  $ reify-fixture $slug

  $ cd $slug

  $ mkdir .connected
  $ touch .connected/snafu .connected/fubar


failure in some hosts::

  $ fake ssh <<\EOF
  > #!/usr/bin/zsh -efu
  > while getopts o: o; do
  >   :
  > done; shift $((OPTIND-1))
  > if [[ $1 == fubar ]]; then
  >   print -u 2 "command not found: ${2[(w)1]}"
  >   exit 1
  > else
  >   set -- ${(z)2}
  >   "$@"
  >   exit 0
  > fi
  > EOF

  $ smrt run snafu fubar -- echo rofl lmao
  snafu\trofl lmao (esc)
  fubar\tcommand not found: echo (esc)
  [1]

  $ tail log.fubar log.snafu
  ==> log.fubar <==
  % echo rofl lmao
  command not found: echo
  
  ==> log.snafu <==
  % echo rofl lmao
  rofl lmao


failure everywhere::

  $ fake ssh <<\EOF
  > #!/usr/bin/zsh -efu
  > echo >&2 "houston, we've got problem!"
  > exit 1
  > EOF

  $ smrt run snafu fubar -- false rofl lmao
  snafu\thouston, we've got problem! (esc)
  fubar\thouston, we've got problem! (esc)
  [2]

  $ tail log.fubar log.snafu
  ==> log.fubar <==
  % echo rofl lmao
  command not found: echo
  % false rofl lmao
  houston, we've got problem!
  
  ==> log.snafu <==
  % echo rofl lmao
  rofl lmao
  % false rofl lmao
  houston, we've got problem!


happy path::

  $ fake ssh <<\EOF
  > #!/usr/bin/zsh -efu
  > while getopts o: o; do
  >   :
  > done; shift $((OPTIND)) # also hostname
  > "${(z)@}"
  > exit 0
  > EOF

  $ smrt run snafu fubar -- echo rofl lmao
  snafu\trofl lmao (esc)
  fubar\trofl lmao (esc)

  $ tail log.fubar log.snafu
  ==> log.fubar <==
  % echo rofl lmao
  command not found: echo
  % false rofl lmao
  houston, we've got problem!
  % echo rofl lmao
  rofl lmao
  
  ==> log.snafu <==
  % echo rofl lmao
  rofl lmao
  % false rofl lmao
  houston, we've got problem!
  % echo rofl lmao
  rofl lmao


logs commands with no output::

  $ rm log.fubar log.snafu

  $ smrt run snafu fubar -- true "hello world" program

  $ tail log.fubar log.snafu
  ==> log.fubar <==
  % true 'hello world' program
  
  ==> log.snafu <==
  % true 'hello world' program
