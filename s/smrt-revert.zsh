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

function $0:t # {{{
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

  (( norepo )) || o removerepo "$issue" $hosts

  impl "$@"
} # }}}

function impl # {{{
{
  local -i seppos="$@[(i)--]"
  local -a hosts; hosts=("$@[1,$((seppos - 1))]")
  (( $#hosts )) || hosts=(.connected/*(N:t))
  local -a pkgs; pkgs=(${(f):-"$(awk '{print $4}' binaries | sort -u)"})
  local -r mrid=${${:-$(< slug)}##*:}
  o run-in-hosts \
    $hosts \
    -- \
    "pkgs=\$(rpm -q --qf '%{NAME}\n' $pkgs | sed '/is not installed/d'); if test x = \"x\$pkgs\"; then echo nothing to do; else zypper -n in --oldpackage --force-resolution -y -l \$pkgs; fi"
} # }}}

function removerepo # {{{
{
  local issue=$1; shift
  o repose issue-rm $@ -- $(<slug)
} # }}}

$0:t "$@"
