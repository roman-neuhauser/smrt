# vim: ft=zsh sw=2 sts=2 et fdm=marker cms=\ #\ %s

# Copyright (C) 2016 SUSE LLC
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

setopt extended_glob
setopt hist_subst_pattern
setopt pipe_fail
setopt err_return
setopt no_unset
setopt warn_create_global

declare -Tgx SMRT_CHATTY smrt_chatty \|
declare -Tgx SMRT_DRYRUN smrt_dryrun \|

declare -gr logfd=2

. haveopt.sh

declare -gx SMRT_ISSUER

declare -g PATTERN_MRID='<->'
declare -g PATTERN_MPRJ='SUSE:Maintenance:<->'
declare -g PATTERN_SLUG=$PATTERN_MPRJ:$PATTERN_MRID

declare -gr cfgfile_system="@sysconfdir@/smrt"
declare -gr cfgfile_user=$HOME/.smrtrc

declare -ga cfgfiles; cfgfiles=(
  $cfgfile_system
  $cfgfile_user(N)
  ${SMRT_CONFIG-}
)

[[ -z ${SMRT_IN_DEVELOPMENT-} ]] || cfgfiles=($cfgfiles[2,-1])


function o O # {{{
{
  local chatty=SMRT_CHATTY
  local dryrun=SMRT_DRYRUN
  local -i do_dryrun=0
  if [[ $1 == -n ]]; then
    shift
    do_dryrun=1
  fi
  if (( ${(P)#chatty} )); then
    if [[ "${(@j,%,)@}" == ${(P)~chatty} ]]; then
      print -ru $logfd -- $0 "${(q-)@}"
    fi
  fi
  if [[ $0 == o ]] && (( ${(P)#dryrun} )); then
    if [[ "${(@j,%,)@}" == ${(P)~dryrun} ]]; then
      do_dryrun=1
    fi
  fi
  if (( do_dryrun )); then
    return 0
  fi
  "$@"
} # }}}

function complain # {{{
{
  local ex=0 severity=warning
  if [[ $1 == <-> ]]; then
    ex=$1
    severity=error
  fi
  shift
  print -u 2 -f "%s: %s\n" $severity $1
  if (( $# > 1 )); then
    print -u 2 -f "%s\n" "$@[2,-1]"
  fi
  return $ex
} # }}}

function redir # {{{
{
  local -i o0=0 o1=1 o2=2
  local optname OPTARG OPTIND
  while getopts 0:1:2: optname; do
    case $optname in
    0) exec {o0}<$OPTARG ;;
    1) exec {o1}>$OPTARG ;;
    2) exec {o2}>$OPTARG ;;
    esac
  done; shift $((OPTIND - 1))
  o "$@" <&${o0} 1>&${o1} 2>&${o2}
} # }}}

function bsc # {{{
{
  local -a opts

  local OPTIND= OPTARG= opt=
  while getopts :d: opt; do
    case $opt in
    d) opts+=(-d $OPTARG) ;;
    ?) cmdname=bsc reject-misuse -$OPTARG ;;
    esac
  done; shift $((OPTIND - 1))

  [[ -n $SMRT_ISSUER ]] \
  || o complain 1 'no issuer given'

  local -r issuer=${SMRT_ISSUER:-SUSE}
  local -r apiurl=${config_issuer_apiurls[(rw)$issuer:*]#$issuer:}

  :; o curl -Sfns "${(@)opts}" "$apiurl$1" \
  || o complain $? "failed bsc ${(j: :)${(q-)@}}"
} # }}}

function oscqam # {{{
{
  local -r issuer=${SMRT_ISSUER:-SUSE}
  local -r apiurl=${config_issuer_apiurls[(rw)$issuer:*]#$issuer:}

  set -- --apiurl=$apiurl qam "$@"
  :; o osc "$@" \
  || o complain - "failed osc ${(j: :)${(q-)@}}"
} # }}}

function display-help # {{{
{
  if [[ $1 == h ]]; then
    local self=${cmdname/-/ }
    print -- ${${${cmdhelp//\#c/$self}//#[[:space:]]#/}//%[[:space:]]#/}
    if (( needs_workdir )); then
      print
      print -f $msg_needs_workdir
    fi
    exit
  fi
  o exec man 1 $cmdname
  exit # we get here in tests
} # }}}

function reject-misuse # {{{
{
  local val=${1-} self=${cmdname/-/ } ex=1
  case $val in
  -?)  print -f "%s: Unknown option '%s'\n" -- $self $val ;;
  -?*) print -f "%s: Unknown option '%s'\n" -- $self -$val ;;
  ?*)  print -f "%s: Unknown argument '%s'\n" -- $self $val ;;
  '')  print -f "%s: Missing argument\n" -- $self ;;
  esac
  print -f $msg_run_for_usage $self
  exit $ex
} # }}}

function check-preconditions # {{{
{
  local cmd=$1 nw=${needs_workdir-0} nc=${needs_config-}
  (( ! $nw )) \
  || o assert-workdir $cmd
  (( ! $#nc )) \
  || o assert-config-vars $cmd $=nc
} # }}}

function assert-workdir # {{{
{
  [[ -e slug ]] && return
  local self=${cmdname/-/ }
  print -u 2 -f '%s: %s is not a testreport\n' -- $self $PWD
  if (( needs_workdir )); then
    print -u 2 -f $msg_needs_workdir
    print -u 2 -f $msg_run_for_usage -- $self
  fi
  exit 1
} # }}}

function assert-config-vars # {{{
{
  local cmd=$1 var=
  shift
  for var in $@; do
    assert-config-var $cmd $var
  done
} # }}}

function assert-config-var # {{{
{
  local cmd=$1
  local name=$2
  local var=config_$name
  (( ${(P)+var} )) && return
  print -u 2 -f $msg_needs_config \
    -- $cmd $name
  return 1
} # }}}

function destdir-ok # {{{
{
  local -r dst=$1
  :; [[ ! -e $dst ]] \
  || [[ -n $dst(#qN/) && -z $dst/*(DN) ]] \
  || complain 1 "refusing to clobber existing destination $dst"

  o mkdir -p $dst
} # }}}

function load-config # {{{
{
  local cfgfile line name
  local -a tokens
  for cfgfile in "$@"; do
    for line in "${(@f):-$(cat $cfgfile 2>&-)}"; do
      tokens=(${(Z:C:)line})
      (( $#tokens )) || continue
      [[ $tokens[2] == '=' ]] || complain - 'syntax error'
      name=config_${tokens[1]}
      declare -g $name
      : ${(P)name::="${(e)tokens[3,-1]}"}
    done
  done
} # }}}

function log-output # {{{
{
  local h= t= line=
  for h in $hosts; do
    print >>| log.$h -f '%% %s\n' "${(j: :)${(@)cmd}}"
  done

  "$@" 2>&1 | while IFS=$'\t\n' read t line; do
    local logfile=log.$t
    print -r -- "$line" >>| $logfile
    print -f "%s\t%s\n" -- "$t" "$line"
  done
} # }}}

function run-in-hosts # {{{
{
  local -i seppos="$@[(i)--]"
  local -a hosts; hosts=("$@[1,$((seppos - 1))]")
  (( $#hosts )) || complain 1 "no hosts attached"

  local -a cmd; cmd=("$@[$((seppos + 1)),-1]")
  (( $#cmd )) || complain 1 "no command given"

  local -a popts; popts=(
    --plain
    --tag
    --joblog joblog
    --jobs=0
  )
  local ctlpath=$config_controlpath

  local h=
  for h in $hosts; do
    :; [[ -e .connected/$h ]] \
    || complain 1 "$h is not attached"
  done

  o log-output parallel "${(@)popts}" \
    ssh -o ControlPath=$ctlpath '{1}' "${(q-)cmd}" \
    ::: "${(@)hosts}"
} # }}}

o load-config $cfgfiles

[[ -n ${config_controlpathdir:+set} ]] \
|| declare -gr config_controlpathdir=${${:-"@controlpathdir@"}//\%u/$UID}

[[ -n ${config_controlpath:+set} ]] \
|| declare -gr config_controlpath=${config_controlpathdir%/#}/%r@%h:%p

declare -ag config_names; config_names=(
  assumed_issuer
  bugzilla_url
  controlpath
  issuer_apiurls
  l3db_creds
  l3db_url
  metadata_url
  testopia_url
  testopia_user
  testopia_pass
  testreport_repository
)

declare -gr msg_needs_workdir='This command should be run from inside a testreport directory\n'
declare -gr msg_run_for_usage="Run '%s -h' for usage instructions\n"
declare -gr msg_needs_config="\
%s: missing or bungled configuration
the '%s' directive is missing from your configuration files
"
