#!@ZSH@ -f
# vim: ft=zsh sw=2 sts=2 et fdm=marker cms=\ #\ %s

declare -gr cmdname=${SMRT_CMDNAME-$0:t}

declare -gr cmdhelp='
usage: #c -h|--help
usage: #c [HOST...]

Install current maintenance update

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

  local -r issue=${${(s.:.):-$(< slug)}[3]}

  local -a hosts; hosts=("$@")
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

  (( norepo )) || o addrepo "$issue" $hosts

  impl "$issue" $hosts
} # }}}

function impl # {{{
{
  local issue=$1; shift
  o run-in-hosts \
    $@ \
    -- \
    "zypper patches | awk -F '|' '/:p=$issue\\>/ { print \$2; }' | xargs -r zypper -n install -l -y -t patch"
} # }}}

function addrepo # {{{
{
  local issue=$1; shift
  o repose issue-add $@ -- .
} # }}}

o $cmdname-main "$@"
