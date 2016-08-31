smrt repose
===========

setup::

  $ . $TESTROOT/setup

  $ smrt_dryrun+=('run-in-hosts%*')
  $ smrt_chatty+=('*~*load-config%*')

  $ slug=SUSE:Maintenance:1302:87808
  $ reify-fixture $slug
  $ cd $slug


some hosts attached::

  $ mkdir .connected
  $ touch .connected/{bofh@fubar,pfy@snafu}.example.org

  $ smrt repose list fubar -- :::gm
  O find-cmd repose
  o run-cmd */smrt-repose list fubar -- :::gm (glob)
  o smrt-repose-main list fubar -- :::gm
  o assert-workdir smrt-repose
  o repose list bofh@fubar.example.org -- :::gm

  $ smrt repose list fubar --
  O find-cmd repose
  o run-cmd */smrt-repose list fubar -- (glob)
  o smrt-repose-main list fubar --
  o assert-workdir smrt-repose
  o repose list bofh@fubar.example.org
