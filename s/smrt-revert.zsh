#!/usr/bin/zsh -f
# vim: ft=zsh sw=2 sts=2 et fdm=marker cms=\ #\ %s

declare -gr cmdname=${SMRT_CMDNAME-$0:t}

declare -gr cmdhelp='
usage: #c -h|--help
usage: #c [HOST...]

Downgrade relevant packages to latest released versions

  Options:
    -h                Display this message
    --help            Display manual page
  Operands:
    HOST              [USER@]HOSTSPEC
'

declare -gr needs_workdir=1

declare -gr preludedir="${SMRT_PRELUDEDIR:-@preludedir@}"

. $preludedir/smrt.prelude.zsh || exit 2

function $cmdname-main # {{{
{
  local opt arg
  local -i i=0 norepo=0
  while haveopt i opt arg h help no-repo -- "$@"; do
    case $opt in
    h|help) display-help $opt ;;
    no-repo) norepo=1 ;;
    ?)      reject-misuse -$arg ;;
    esac
  done; shift $i

  check-preconditions $cmdname

  local -a hosts; hosts=("$@")

  local h=
  for h in $hosts; do
    :; [[ -f .connected/$h ]] \
    || complain 1 "$h is not attached"
  done

  (( $#hosts )) || hosts=(.connected/*(N:t))
  (( $#hosts )) || complain 1 "no hosts attached"

  (( norepo )) || o repose issue-rm $hosts -- $(<slug)

  o smrt prepare --force --installed $hosts
} # }}}

. $preludedir/smrt.coda.zsh

o $cmdname-main "$@"
