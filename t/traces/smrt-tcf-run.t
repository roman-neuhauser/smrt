smrt tcf run
============

setup::

  $ . $TESTROOT/setup

  $ smrt_dryrun+=('run-in-hosts%*')
  $ smrt_chatty+=('*~*load-config%*')

  $ slug=SUSE:Maintenance:1302:87808
  $ reify-fixture $slug
  $ cd $slug

no hosts attached, no hosts given::

  $ smrt tcf run -- foo
  O find-cmd tcf
  o run-cmd /*/smrt-tcf run -- foo (glob)
  o smrt-tcf-main run -- foo
  o assert-workdir smrt-tcf
  o do-run -- foo
  error: no hosts attached
  [1]

some hosts attached::

  $ mkdir .connected
  $ touch .connected/{bofh@fubar,pfy@snafu}.example.org

  $ smrt tcf run -- foo
  O find-cmd tcf
  o run-cmd /*/smrt-tcf run -- foo (glob)
  o smrt-tcf-main run -- foo
  o assert-workdir smrt-tcf
  o do-run -- foo
  o run-in-hosts bofh@fubar.example.org pfy@snafu.example.org -- /usr/bin/env TESTS_LOGDIR=/var/log/qa/SUSE:Maintenance:1302:87808 foo-run
