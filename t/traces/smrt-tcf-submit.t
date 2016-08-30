smrt tcf submit
===============

setup::

  $ . $TESTROOT/setup

  $ smrt_dryrun+=('run-in-hosts%*')
  $ smrt_chatty+=('*~*load-config%*')

  $ slug=SUSE:Maintenance:1302:87808
  $ reify-fixture $slug
  $ cd $slug

no hosts attached, no hosts given::

  $ smrt tcf submit -- foo
  O find-cmd tcf
  o run-cmd /*/smrt-tcf submit -- foo (glob)
  o smrt-tcf-main submit -- foo
  o assert-workdir smrt-tcf
  o do-submit -- foo
  error: no hosts attached
  [1]

some hosts attached::

  $ mkdir .connected
  $ touch .connected/{bofh@fubar,pfy@snafu}.example.org

  $ smrt tcf submit -- foo
  O find-cmd tcf
  o run-cmd /*/smrt-tcf submit -- foo (glob)
  o smrt-tcf-main submit -- foo
  o assert-workdir smrt-tcf
  o do-submit -- foo
  o run-in-hosts bofh@fubar.example.org pfy@snafu.example.org -- /usr/share/qa/tools/remote_qa_db_report.pl -b -t patch:SUSE:Maintenance:1302:87808 -T * -f /var/log/qa/SUSE:Maintenance:1302:87808 -c 'testing foo on SUSE:Maintenance:1302:87808 on ????-??-??T??:??:??+*' (glob)
