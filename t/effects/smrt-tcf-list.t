smrt tcf list
=============

setup::

  $ . $TESTROOT/setup

  $ smrt_dryrun+=('run-in-hosts%*')

  $ slug=SUSE:Maintenance:1302:87808
  $ reify-fixture $slug
  $ cd $slug

no hosts given, no hosts attached::

  $ smrt tcf list
  error: no hosts attached
  [1]

some hosts given, no hosts attached::

  $ smrt tcf list foo
  error: foo is not attached
  [1]
