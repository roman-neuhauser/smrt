smrt attach
============

setup::

  $ . $TESTROOT/setup


help::

  $ smrt attach -h
  usage: smrt attach -h|--help
  usage: smrt attach HOST... -- PRODUCT...
  
  Ssh into a refhost and earmark it for testing given products
  
    Options:
      -h                Display this message
      --help            Display manual page
    Operands:
      HOST              [USER@]HOSTSPEC
      PRODUCT           PRODNAME:PRODVER
  
  This command should be run from inside a testreport directory

  $ smrt attach --help
  o exec man 1 smrt-attach


unknown option::

  $ smrt attach -x
  smrt attach: Unknown option '-x'
  Run 'smrt attach -h' for usage instructions
  [1]

  $ smrt attach --xeno
  smrt attach: Unknown option '--xeno'
  Run 'smrt attach -h' for usage instructions
  [1]


missing argument::

  $ smrt attach
  smrt attach: Missing argument
  Run 'smrt attach -h' for usage instructions
  [1]

  $ smrt attach fubar
  smrt attach: Missing argument
  Run 'smrt attach -h' for usage instructions
  [1]

  $ smrt attach -- fubar
  smrt attach: Missing argument
  Run 'smrt attach -h' for usage instructions
  [1]

  $ smrt attach fubar --
  smrt attach: Missing argument
  Run 'smrt attach -h' for usage instructions
  [1]


outside a testreport::

  $ smrt attach snafubar -- rofl lmao
  smrt attach: * is not a testreport (glob)
  This command should be run from inside a testreport directory
  Run 'smrt attach -h' for usage instructions
  [1]
