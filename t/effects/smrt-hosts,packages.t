smrt hosts --packages: effects
==============================

setup::

  $ . $TESTROOT/setup

  $ slug=SUSE:Maintenance:1302:87808
  $ reify-fixture $slug
  $ cd $slug

no hosts or packages given, no hosts attached::

  $ smrt hosts --packages
  error: no hosts attached
  [1]

some packages given, no hosts attached::

  $ smrt hosts --packages foo
  error: no hosts attached
  [1]

some hosts given, no hosts attached::

  $ smrt hosts --packages foo --
  error: foo is not attached
  [1]
