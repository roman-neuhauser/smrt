smrt testopia list
==================

setup::

  $ . $TESTROOT/setup

  $ smrt_dryrun+=('python3%*')
  $ smrt_chatty+=('*~*load-config%*')

  $ cat > ~/.smrtrc <<EOF
  > bugzilla_url = https://bugzilla.example.org
  > testopia_url = https://apibugzilla.example.org
  > testopia_user = testopus
  > testopia_pass = testopas
  > EOF


test::

  $ smrt testopia list bash
  O find-cmd testopia
  o run-cmd /*/smrt-testopia list bash (glob)
  o smrt-testopia-main list bash
  o assert-config-vars smrt-testopia bugzilla_url testopia_url testopia_user testopia_pass
  o impl list bash
  o python3 /*/smrt.testopia.py list bash (glob)
