#!/usr/bin/zsh -f
# vim: ft=zsh sw=2 sts=2 et fdm=marker cms=\ #\ %s

declare -gr cmdname=${SMRT_CMDNAME-$0:t}

declare -gr cmdhelp='
usage: #c -h|--help
usage: #c [HOST...]

Use repose on attached hosts

  Options:
    -h                Display this message
    --help            Display manual page
  Operands:
    HOST              Attached host
'

declare -gr needs_workdir=1

declare -gr preludedir="${SMRT_PRELUDEDIR:-@preludedir@}"

. $preludedir/smrt.prelude.zsh || exit 2

function $cmdname-main # {{{
{
  local opt arg
  local -i i=0
  while haveopt i opt arg h help -- "$@"; do
    case $opt in
    h|help) display-help $opt ;;
    ?)      reject-misuse -$arg ;;
    esac
  done; shift $i

  check-preconditions $cmdname

  local -r cmd=$1; shift

  local -a hosts suite
  suite=("$@")
  local -i seppos="$@[(i)--]"
  if (( seppos <= $# )); then
    suite=("$@[$((seppos + 1)),-1]")
    hosts=("$@[1,$((seppos - 1))]")
  fi
  (( $#hosts )) || hosts=(.connected/*(N:t))
  (( $#hosts )) || complain 1 "no hosts attached"

  local -a this rhosts
  local h=
  for h in $hosts; do
    this=(.connected/*$h*(N:t))
    :; (( $#this )) \
    || complain 1 "$h is not attached"
    rhosts+=($this)
  done; hosts=($rhosts)

  (( $#hosts )) || complain 1 "no hosts attached"

  o repose $cmd $hosts ${suite:+--} $suite
} # }}}

. $preludedir/smrt.coda.zsh

o $cmdname-main "$@"
