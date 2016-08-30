#!/usr/bin/zsh -f
# vim: ft=zsh sw=2 sts=2 et fdm=marker cms=\ #\ %s

declare -gr cmdname=${SMRT_CMDNAME-$0:t}

declare -gr cmdhelp='
usage: #c -h|--help
usage: #c [HOST...]

Prepare hosts for current maintenance update

  Options:
    -h                Display this message
    --help            Display manual page
    --force           Use zypper install with --force
    --installed       Do not install missing packages
  Operands:
    HOST              Machine to manipulate
'

declare -gr needs_workdir=1

declare -gr preludedir="${SMRT_PRELUDEDIR:-@preludedir@}"

. $preludedir/smrt.prelude.zsh || exit 2

function $cmdname-main # {{{
{
  local opt arg
  local -i i=0 o_force=0 o_installed=0
  while haveopt i opt arg h help force installed -- "$@"; do
    case $opt in
    h|help) display-help $opt ;;
    force) o_force=1 ;;
    installed) o_installed=1 ;;
    ?)      reject-misuse -$arg ;;
    esac
  done; shift $i

  check-preconditions $0

  local -r issue=${${(s.:.):-$(< slug)}[3]}

  local -a hosts; hosts=("$@")

  local h=
  for h in $hosts; do
    :; [[ -f .connected/$h ]] \
    || complain 1 "$h is not attached"
  done

  (( $#hosts )) || hosts=(.connected/*(N:t))
  (( $#hosts )) || complain 1 "no hosts attached"

  local pkgs="$(awk '{print $4}' binaries | sort -u)"
  local -a cmds; cmds=("printf '%s\n' $pkgs")
  local force=

  if (( o_force )); then
    force=--force
  fi

  if (( o_installed )); then
    cmds=("rpm -q --qf '%{NAME}\n' $pkgs | grep -v 'is not installed'")
  fi

  cmds+=("xargs -r zypper -n in $force --force-resolution -y -l --oldpackage")
  o run-in-hosts \
    $hosts \
    -- \
    "${(@j: | :)cmds}"
} # }}}

. $preludedir/smrt.coda.zsh

o $cmdname-main "$@"
