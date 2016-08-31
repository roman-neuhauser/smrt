smrt hosts: effects
===================

setup::

  $ . $TESTROOT/setup

  $ slug=SUSE:Maintenance:1302:87808
  $ reify-fixture $slug
  $ cd $slug
  $ mkdir .connected


no hosts given, no hosts attached::

  $ smrt hosts


some hosts given, no hosts attached::

  $ smrt hosts foo
  error: foo is not attached
  [1]


test default behavior with hosts::

  $ print > .connected/rofl -l omg wtf
  $ print > .connected/snafu -l rofl lmao

  $ smrt hosts
  rofl                         omg wtf
  snafu                        rofl lmao
