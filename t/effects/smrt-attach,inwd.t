smrt attach: effects
====================

setup::

  $ . $TESTROOT/setup

  $ slug=SUSE:Maintenance:1302:87808
  $ reify-fixture $slug


test happy path::

  $ cd $slug

  $ fake ssh <<\EOF
  > echo spam from ssh
  > exit 0
  > EOF

  $ smrt attach snafubar -- rofl lmao
  Attaching snafubar for rofl lmao
  spam from ssh

  $ cat .connected/snafubar
  rofl
  lmao

  $ fake -f ssh <<\EOF
  > case $* in
  > (-O check *omg) exit 1 ;;
  > (-O check *) exit 0 ;;
  > (*) echo >&2 hiccups from ssh $@; exit 1 ;;
  > esac
  > EOF

  $ smrt attach omg wtf -- foo bar baz
  Attaching omg for foo bar baz
  hiccups from ssh * omg (glob)
  warning: failed to attach omg
  Attaching wtf for foo bar baz

  $ ls .connected
  snafubar
  wtf
