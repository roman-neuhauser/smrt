smrt update
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
  > print ssh stderr spam
  > print ssh stdout spam
  > exit 69
  > EOF

  $ cd $slug


no hosts given, no hosts attached::

  $ smrt update
  error: no hosts attached
  [1]


not an attached host::

  $ smrt update snafubar
  error: snafubar is not attached
  [1]


mixed hosts::

  $ mkdir .connected
  $ print -l > .connected/foo bar baz
  $ print -l > .connected/omg wtf

  $ smrt update foo snafubar omg
  error: snafubar is not attached
  [1]

  $ print -lnr log.*(N)


massages given hosts::

  $ smrt update omg
  omg\tssh stderr spam (esc)
  omg\tssh stdout spam (esc)
  [1]

  $ print -lr log.*(N)
  log.omg

  $ smrt update omg foo
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

  $ smrt update
  foo\tssh stderr spam (esc)
  foo\tssh stdout spam (esc)
  omg\tssh stderr spam (esc)
  omg\tssh stdout spam (esc)
  [2]

  $ print -lr log.*(N)
  log.foo
  log.omg
