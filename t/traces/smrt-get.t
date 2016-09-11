smrt get
========

setup::

  $ . $TESTROOT/setup

  $ smrt_chatty+=(
  >   'impl%*'
  >   'mkdir%*'
  >   'parallel%*'
  > )

  $ fake -f scp <<\EOF
  > while getopts pro: o; do :; done; shift $((OPTIND - 1))
  > print -u 2 "${(@q)@}"
  > EOF

  $ slug=SUSE:Maintenance:1302:87808
  $ reify-fixture $slug
  $ cd $slug
  $ mkdir .connected

no hosts attached, no hosts given::

  $ smrt get -- /abs/path rel/path
  error: no hosts attached
  [1]

  $ smrt get /abs/path rel/path
  error: no hosts attached
  [1]

  $ print > .connected/root@rofl -l omg wtf
  $ print > .connected/toor@snafu -l rofl lmao

some hosts attached, some given::

  $ smrt get root@rofl -- /abs/path rel/path
  o impl root@rofl -- /abs/path rel/path
  o mkdir -p root@rofl/abs
  o parallel * scp -pro BatchMode=yes -o ControlPath=*/%r@%h:%p '{1}:/abs/path' '{1}/abs/path' ::: root@rofl (glob)
  root@rofl\troot@rofl:/abs/path root@rofl/abs/path (esc)
  o mkdir -p root@rofl/rel
  o parallel * scp -pro BatchMode=yes -o ControlPath=*/%r@%h:%p '{1}:rel/path' '{1}/rel/path' ::: root@rofl (glob)
  root@rofl\troot@rofl:rel/path root@rofl/rel/path (esc)

default hosts::

  $ smrt get -- /abs/path rel/path
  o impl root@rofl toor@snafu -- /abs/path rel/path
  o mkdir -p root@rofl/abs toor@snafu/abs
  o parallel * scp -pro BatchMode=yes -o ControlPath=*/%r@%h:%p '{1}:/abs/path' '{1}/abs/path' ::: root@rofl toor@snafu (glob)
  root@rofl\troot@rofl:/abs/path root@rofl/abs/path (esc)
  toor@snafu\ttoor@snafu:/abs/path toor@snafu/abs/path (esc)
  o mkdir -p root@rofl/rel toor@snafu/rel
  o parallel * scp -pro BatchMode=yes -o ControlPath=*/%r@%h:%p '{1}:rel/path' '{1}/rel/path' ::: root@rofl toor@snafu (glob)
  root@rofl\troot@rofl:rel/path root@rofl/rel/path (esc)
  toor@snafu\ttoor@snafu:rel/path toor@snafu/rel/path (esc)
