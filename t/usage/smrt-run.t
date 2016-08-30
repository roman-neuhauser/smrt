smrt run
========

setup::

  $ . $TESTROOT/setup


help::

  $ smrt run -h
  usage: smrt run -h|--help
  usage: smrt run [HOST... --] COMMAND
  
  Run a command in attached hosts
  
    Options:
      -h                Display this message
      --help            Display manual page
    Operands:
      COMMAND           Command to run
      HOST              Machine to run the command in
  
  This command should be run from inside a testreport directory

  $ smrt run --help
  o exec man 1 smrt-run


unknown option::

  $ smrt run -x
  smrt run: Unknown option '-x'
  Run 'smrt run -h' for usage instructions
  [1]

  $ smrt run --xeno
  smrt run: Unknown option '--xeno'
  Run 'smrt run -h' for usage instructions
  [1]


no arguments::

  $ smrt run
  smrt run: Missing argument
  Run 'smrt run -h' for usage instructions
  [1]
