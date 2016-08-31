smrt tcf run
============

setup::

  $ . $TESTROOT/setup

  $ smrt_dryrun+=('run-in-hosts%*')
  $ smrt_chatty+=('run-in-hosts%*')

  $ slug=SUSE:Maintenance:1302:87808
  $ reify-fixture $slug
  $ cd $slug

no hosts given, no hosts attached::

  $ smrt tcf run -- bar
  error: no hosts attached
  [1]

some hosts given, no hosts attached::

  $ smrt tcf run foo -- bar
  error: foo is not attached
  [1]
