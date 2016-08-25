smrt testopia create
====================

setup::

  $ . $TESTROOT/setup


no arguments::

  $ smrt testopia create
  smrt testopia: Missing argument
  Run 'smrt testopia -h' for usage instructions
  [1]


no configuration file::

  $ smrt testopia create bash
  smrt-testopia: missing or bungled configuration
  the 'bugzilla_url' directive is missing from your ~/.smrtrc
  [1]

partial configuration file::

  $ cat > ~/.smrtrc <<EOF
  > bugzilla_url = https://bugzilla.example.org
  > EOF

  $ smrt testopia create bash
  smrt-testopia: missing or bungled configuration
  the 'testopia_url' directive is missing from your ~/.smrtrc
  [1]
