smrt mklog: traces
==================

setup::

  $ . $TESTROOT/setup

  $ slug=SUSE:Maintenance:1302:87808
  $ reify-fixture $slug
  $ cd $slug
  $ rm -f log

  $ smrt_chatty+=(
  >   '*~*print*'
  > )


test::

  $ [[ -e log ]]
  [1]

  $ smrt mklog
  o load-config */.smrtrc (glob)
  O find-cmd mklog
  o run-cmd */smrt-mklog (glob)
  o load-config */.smrtrc (glob)
  o smrt-mklog-main
  o assert-workdir smrt-mklog
  o impl
  o get-products-archs SLE-DESKTOP:12-SP1:x86_64 SLE-DESKTOP:12:x86_64 SLE-SERVER:12-SP1:ppc64le SLE-SERVER:12-SP1:s390x SLE-SERVER:12-SP1:x86_64 SLE-SERVER:12:ppc64le SLE-SERVER:12:s390x SLE-SERVER:12:x86_64
  o format-products SLE-DESKTOP:12 x86_64 SLE-DESKTOP:12-SP1 x86_64 SLE-SERVER:12 'ppc64le s390x x86_64' SLE-SERVER:12-SP1 'ppc64le s390x x86_64'
  o format-testplatforms SLE-DESKTOP:12 x86_64 SLE-DESKTOP:12-SP1 x86_64 SLE-SERVER:12 'ppc64le s390x x86_64' SLE-SERVER:12-SP1 'ppc64le s390x x86_64'
  o get-sources
  o prj2tp -- SLE-DESKTOP:12
  o prj2tp -- SLE-DESKTOP:12-SP1
  o prj2tp -- SLE-SERVER:12
  o prj2tp -- SLE-SERVER:12-SP1
  o format-bugs
  o format-l3infos bnc898513
  o format-l3infos bnc900914
  o format-l3infos bnc915410
  o format-l3infos bnc922710
  o get-testopia-tags
  o format-binaries
  o get-sources
  o get-reviewers
  o redir -0 binaries -1 packages-list.txt mk-packages-list
  o mk-packages-list
