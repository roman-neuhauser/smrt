smrt terms gnome
================

setup::

  $ . $TESTROOT/setup

  $ smrt_chatty+=(
  > 'impl%*'
  > 'nohup%*'
  > 'zsh%*'
  > '(*gnome*)~(*load-config*)'
  > )

  $ smrt_dryrun+=(
  >   'nohup%*'
  > )

  $ slug=SUSE:Maintenance:1302:87808
  $ reify-fixture $slug
  $ cd $slug
  $ mkdir .connected


no hosts attached, no hosts given::

  $ smrt terms gnome
  o run-cmd */smrt-terms gnome (glob)
  o smrt-terms-main gnome
  o impl gnome
  error: no hosts attached
  [1]


some hosts attached, no hosts given::

  $ print > .connected/root@rofl -l omg wtf
  $ print > .connected/toor@snafu -l rofl lmao

  $ smrt terms gnome
  o run-cmd */smrt-terms gnome (glob)
  o smrt-terms-main gnome
  o impl gnome
  o run-gnome root@rofl toor@snafu
  o zsh -f */smrt.terms.gnome.zsh root@rofl toor@snafu (glob)
  o smrt.terms.gnome.zsh-main root@rofl toor@snafu
  o nohup gnome-terminal --tab -e 'ssh -Y root@rofl' --tab -e 'ssh -Y toor@snafu'
