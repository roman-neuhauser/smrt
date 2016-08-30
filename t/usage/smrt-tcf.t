smrt tcf
========

setup::

  $ . $TESTROOT/setup


help::

  $ smrt tcf -h
  usage: smrt tcf -h|--help
  usage: smrt tcf list [HOST...]
  usage: smrt tcf run [HOST... --] SUITE
  usage: smrt tcf submit [HOST... --] SUITE
  
  Query and manipulate CTCS2 testsuites and results
  
    Options:
      -h                Display this message
      --help            Display manual page
    Operands:
      list              List testsuites installed in each HOST
      run               Run a CTCS2 testsuite in each HOST
      submit            Submit CTCS2 testsuite results into a QADB
  
  This command should be run from inside a testreport directory

  $ smrt tcf --help
  o exec man 1 smrt-tcf


unknown option::

  $ smrt tcf -x
  smrt tcf: Unknown option '-x'
  Run 'smrt tcf -h' for usage instructions
  [1]

  $ smrt tcf --xeno
  smrt tcf: Unknown option '--xeno'
  Run 'smrt tcf -h' for usage instructions
  [1]


no arguments::

  $ smrt tcf
  smrt tcf: Missing argument
  Run 'smrt tcf -h' for usage instructions
  [1]


invalid arguments::

  $ smrt tcf foo
  smrt tcf: Unknown argument 'foo'
  Run 'smrt tcf -h' for usage instructions
  [1]
