smrt hosts --packages: effects
==============================

setup::

  $ . $TESTROOT/setup

  $ slug=SUSE:Maintenance:1302:87808
  $ reify-fixture $slug
  $ cd $slug
  $ mkdir .connected
  $ smrt_chatty+=('(log-output|print|run-in-hosts|ssh|cat|true)%*')
  $ fake -f ssh <<\EOF
  > print -u 1 -- fake-ssh some output from $3
  > print -u 2 -- fake-ssh some error from $3
  > exit 41
  > EOF


some hosts attached, no hosts given::

  $ print > .connected/rofl -l omg wtf
  $ print > .connected/snafu -l rofl lmao

  $ smrt hosts --packages
  o run-in-hosts rofl snafu -- 'rpm -q --queryformat '\''%{NAME} %{VERSION} %{RELEASE}\n'\'' rsync'
  o log-output parallel * ssh -o ControlPath=*/%r@%h:%p '{1}' \''rpm -q --queryformat '\''\'\'\''%{NAME} %{VERSION} %{RELEASE}\n'\''\'\'\'' rsync'\' ::: rofl snafu (glob)
  rofl\tfake-ssh some output from rofl (esc)
  rofl\tfake-ssh some error from rofl (esc)
  snafu\tfake-ssh some output from snafu (esc)
  snafu\tfake-ssh some error from snafu (esc)
  [2]

  $ tail log.*
  ==> log.rofl <==
  % rpm -q --queryformat '%{NAME} %{VERSION} %{RELEASE}\n' rsync
  fake-ssh some output from rofl
  fake-ssh some error from rofl
  
  ==> log.snafu <==
  % rpm -q --queryformat '%{NAME} %{VERSION} %{RELEASE}\n' rsync
  fake-ssh some output from snafu
  fake-ssh some error from snafu
