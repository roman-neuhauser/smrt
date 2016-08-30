smrt testopia show
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

  $ smrt testopia show 1234
  O find-cmd testopia
  o run-cmd /*/smrt-testopia show 1234 (glob)
  o smrt-testopia-main show 1234
  o assert-config-vars smrt-testopia bugzilla_url testopia_url testopia_user testopia_pass
  o impl show 1234
  o python3 /*/smrt.testopia.py show 1234 (glob)
