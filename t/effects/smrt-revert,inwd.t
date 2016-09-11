smrt revert
===========

setup::

  $ . $TESTROOT/setup

  $ slug=SUSE:Maintenance:1302:87808
  $ reify-fixture $slug

  $ fake -f ssh <<\EOF
  > while getopts qo: o; do
  >   case $o in
  >   q) ;;
  >   o) shift ;;
  >   esac
  > done; shift $((OPTIND - 1))
  > print -r ssh stderr spam
  > print ssh stdout spam
  > exit 69
  > EOF

  $ cd $slug


no hosts given, no hosts attached::

  $ smrt revert
  error: no hosts attached
  [1]


not an attached host::

  $ smrt revert snafubar
  error: snafubar is not attached
  [1]


mixed hosts::

  $ mkdir .connected
  $ print -l > .connected/foo bar baz
  $ print -l > .connected/omg wtf

  $ smrt revert foo snafubar omg
  error: snafubar is not attached
  [1]

  $ print -lnr log.*(N)


massages given hosts::

  $ smrt revert omg
  omg\tssh stderr spam (esc)
  omg\tssh stdout spam (esc)
  [1]

  $ print -lr log.*(N)
  log.omg

  $ smrt revert omg foo
  omg\tssh stderr spam (esc)
  omg\tssh stdout spam (esc)
  foo\tssh stderr spam (esc)
  foo\tssh stdout spam (esc)
  [2]

  $ print -lr log.*(N)
  log.foo
  log.omg

  $ rm -f log.*(N)

hosts attached, none given::

  $ smrt revert
  foo\tssh stderr spam (esc)
  foo\tssh stdout spam (esc)
  omg\tssh stderr spam (esc)
  omg\tssh stdout spam (esc)
  [2]

  $ print -lr log.*(N)
  log.foo
  log.omg
