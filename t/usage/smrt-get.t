smrt get
========

setup::

  $ . $TESTROOT/setup


help::

  $ smrt get -h
  usage: smrt get -h|--help
  usage: smrt get [HOST... --] SOURCE...
  
  Download files and directories from attached hosts
  
    Options:
      -h                Display this message
      --help            Display manual page
  
    Operands:
      HOST              Machine to download from
      SOURCE            Pathname to download
  
  This command should be run from inside a testreport directory

  $ smrt get --help
  o exec man 1 smrt-get


unknown option::

  $ smrt get -x
  smrt get: Unknown option '-x'
  Run 'smrt get -h' for usage instructions
  [1]

  $ smrt get --xeno
  smrt get: Unknown option '--xeno'
  Run 'smrt get -h' for usage instructions
  [1]


missing argument::

  $ smrt get
  smrt get: Missing argument
  Run 'smrt get -h' for usage instructions
  [1]
