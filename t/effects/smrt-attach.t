smrt attach: effects
====================

setup::

  $ . $TESTROOT/setup

  $ slug=SUSE:Maintenance:1302:87808
  $ reify-fixture $slug


test::

  $ cd $slug

  $ smrt attach snafubar rofl lmao
  Connecting to snafubar for rofl lmao

  $ cat connected.snafubar
  rofl
  lmao