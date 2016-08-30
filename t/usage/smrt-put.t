smrt put
========

setup::

  $ . $TESTROOT/setup


help::

  $ smrt put -h
  usage: smrt put -h|--help
  usage: smrt put [HOST... --] SOURCE... TARGET
  
  Upload files and directories to attached hosts
  
    Options:
      -h                Display this message
      --help            Display manual page
  
    Operands:
      HOST              Machine to upload to
      SOURCE            Pathname to upload
      TARGET            Destination path
  
  This command should be run from inside a testreport directory

  $ smrt put --help
  o exec man 1 smrt-put


unknown option::

  $ smrt put -x
  smrt put: Unknown option '-x'
  Run 'smrt put -h' for usage instructions
  [1]

  $ smrt put --xeno
  smrt put: Unknown option '--xeno'
  Run 'smrt put -h' for usage instructions
  [1]


missing argument::

  $ smrt put
  smrt put: Missing argument
  Run 'smrt put -h' for usage instructions
  [1]
