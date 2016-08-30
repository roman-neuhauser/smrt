smrt terms xterm
================

setup::

  $ . $TESTROOT/setup

  $ smrt_chatty+=(
  >   'impl%*'
  >   'nohup%*'
  >   'zsh%*'
  >   '(*xterm*)~(*load-config*)'
  > )

  $ smrt_dryrun+=(
  >   'nohup%*'
  > )

  $ slug=SUSE:Maintenance:1302:87808
  $ reify-fixture $slug
  $ cd $slug
  $ mkdir .connected


no hosts attached, no hosts given::

  $ smrt terms xterm
  o run-cmd */smrt-terms xterm (glob)
  o smrt-terms-main xterm
  o impl xterm
  error: no hosts attached
  [1]


some hosts attached, no hosts given::

  $ print > .connected/root@rofl -l omg wtf
  $ print > .connected/toor@snafu -l rofl lmao

  $ smrt terms xterm
  o run-cmd */smrt-terms xterm (glob)
  o smrt-terms-main xterm
  o impl xterm
  o run-xterm root@rofl toor@snafu
  o zsh -f */smrt.terms.xterm.zsh root@rofl toor@snafu (glob)
  o smrt.terms.xterm.zsh-main root@rofl toor@snafu
  o nohup xterm -T root@rofl -e ssh -Y root@rofl
  o nohup xterm -T toor@snafu -e ssh -Y toor@snafu
