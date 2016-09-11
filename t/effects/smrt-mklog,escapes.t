smrt mklog: effects
===================

setup::

  $ . $TESTROOT/setup

  $ slug=SUSE:Maintenance:2598:115124
  $ reify-fixture $slug
  $ cd $slug
  $ rm -f log packages-list.txt


test::

  $ smrt mklog

  $ sed -n '/^additional info/,/^\.\.\.$/{s/'$'\t''/  /g; p;}' log
  additional info from L3:
  
    Incident ID:        45371
    Summary:
      After patching to samba-client-4.2.4-16.1.x86_64.rpm it is not possible to connect to a NetApp Filer (NetApp's  network attached storage using CIFS).
    Probability:        medium
    Impact:             medium
    Patch:              correct
    Reproducer:
      smbclient "//<NETAPP DFS SHARE" -W ADB -U "ADB\\<username>%<password>"
      smb: \> cd <\allowed directory\>
      
      It now fails with errors, see bug #description.
    Requires 3rd-party: yes
  
  ...
