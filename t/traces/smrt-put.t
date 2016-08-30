smrt put
========

setup::

  $ . $TESTROOT/setup

  $ smrt_chatty+=(
  >   'impl%*'
  >   'parallel%*'
  > )

  $ fake scp <<\EOF
  > #!/usr/bin/zsh -f
  > while getopts pro: o; do :; done; shift $((OPTIND - 1))
  > print -u 2 "${(@q)@}"
  > EOF

  $ slug=SUSE:Maintenance:1302:87808
  $ reify-fixture $slug
  $ cd $slug
  $ mkdir .connected

no hosts attached, no hosts given::

  $ smrt put -- /abs/path rel/path
  error: no hosts attached
  [1]

  $ smrt put /abs/path rel/path
  error: no hosts attached
  [1]

  $ print > .connected/root@rofl -l omg wtf
  $ print > .connected/toor@snafu -l rofl lmao

some hosts attached, some given::

  $ smrt put root@rofl -- /abs/path rel/path
  o impl root@rofl -- /abs/path rel/path
  o parallel * scp -pro BatchMode=yes -o ControlPath=*/%r@%h:%p /abs/path '{1}:rel/path' ::: root@rofl (glob)
  root@rofl\t/abs/path root@rofl:rel/path (esc)

default hosts::

  $ smrt put -- /abs/path rel/path
  o impl root@rofl toor@snafu -- /abs/path rel/path
  o parallel * scp -pro BatchMode=yes -o ControlPath=*/%r@%h:%p /abs/path '{1}:rel/path' ::: root@rofl toor@snafu (glob)
  root@rofl\t/abs/path root@rofl:rel/path (esc)
  toor@snafu\t/abs/path toor@snafu:rel/path (esc)
