smrt adopt
==========

setup::

  $ . $TESTROOT/setup


help::

  $ smrt adopt -h
  usage: smrt adopt -h|--help
  usage: smrt adopt MRID|MPRJ|SLUG
  
  Adopt a maintenance request for testing
  
    Options:
      -h                Display this message
      --help            Display manual page
    Operands:
      MRID              Maintenance request MRID
      MPRJ              Maintenance request currently linked into
                        the maintenance project MPRJ
      MPRJ:MRID         Maintenance request MRID

  $ smrt adopt --help
  o exec man 1 smrt-adopt


unknown option::

  $ smrt adopt -x
  smrt adopt: Unknown option '-x'
  Run 'smrt adopt -h' for usage instructions
  [1]

  $ smrt adopt --xeno
  smrt adopt: Unknown option '--xeno'
  Run 'smrt adopt -h' for usage instructions
  [1]


no arguments::

  $ smrt adopt
  smrt adopt: Missing argument
  Run 'smrt adopt -h' for usage instructions
  [1]


invalid arguments::

  $ smrt adopt x12345
  smrt adopt: Unknown argument 'x12345'
  Run 'smrt adopt -h' for usage instructions
  [1]

  $ smrt adopt SUSE:Maintenance:1234
  smrt adopt: Unknown argument 'SUSE:Maintenance:1234'
  Run 'smrt adopt -h' for usage instructions
  [1]

  $ smrt adopt oSUSE:Maintenance:1234:56789
  smrt adopt: Unknown argument 'oSUSE:Maintenance:1234:56789'
  Run 'smrt adopt -h' for usage instructions
  [1]

  $ smrt adopt SUSE:Maintenance:1234x:56789
  smrt adopt: Unknown argument 'SUSE:Maintenance:1234x:56789'
  Run 'smrt adopt -h' for usage instructions
  [1]

  $ smrt adopt SUSE:Maintenance:1234:56789x
  smrt adopt: Unknown argument 'SUSE:Maintenance:1234:56789x'
  Run 'smrt adopt -h' for usage instructions
  [1]

  $ smrt adopt SUSE:Maintenance::1234:56789
  smrt adopt: Unknown argument 'SUSE:Maintenance::1234:56789'
  Run 'smrt adopt -h' for usage instructions
  [1]


no configuration file::

  $ smrt adopt SUSE:Maintenance:1234:5678
  smrt-adopt: missing or bungled configuration
  the 'bugzilla_url' directive is missing from your configuration files
  [1]

partial configuration file::

  $ cat > ~/.smrtrc <<EOF
  > bugzilla_url = https://bugzilla.example.org
  > EOF

  $ smrt adopt SUSE:Maintenance:1234:5678
  smrt-adopt: missing or bungled configuration
  the 'issuer_apiurls' directive is missing from your configuration files
  [1]

bare MRID requires --issuer::

  $ cat > ~/.smrtrc <<EOF
  > bugzilla_url = https://bugzilla.example.org
  > issuer_apiurls = SNAFU:omg fuBAR:wtf
  > l3db_creds = smrt:mtui
  > l3db_url = http://l3db.example.org/
  > metadata_url = file:///etc/smrt
  > EOF

  $ smrt adopt 12345
  error: no issuer given
  [1]
