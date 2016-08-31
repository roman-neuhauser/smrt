#!/usr/bin/zsh -f
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

declare -gr cmdname=${SMRT_CMDNAME-$0:t}

declare -gr cmdhelp='

usage: #c -h|--help
usage: #c list [HOST...]
usage: #c run [HOST... --] SUITE
usage: #c submit [HOST... --] SUITE

Query and manipulate CTCS2 testsuites and results

  Options:
    -h                Display this message
    --help            Display manual page
  Operands:
    list              List testsuites installed in each HOST
    run               Run a CTCS2 testsuite in each HOST
    submit            Submit CTCS2 testsuite results into a QADB
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
    *)      reject-misuse -$arg ;;
    esac
  done; shift $i

  arg=${1-}
  case $arg in
  list|run|submit) : ;;
  *) reject-misuse ${1-} ;;
  esac

  check-preconditions $cmdname

  o do-$1 "$@[2,-1]"
} # }}}

function do-list # {{{
{
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

  o run-in-hosts $hosts -- "ls /usr/share/qa/tools/*-run"
} # }}}

function do-run # {{{
{
  local -i seppos="$@[(i)--]"
  local -a hosts suite
  if (( seppos <= $# )); then
    suite=("$@[$((seppos + 1)),-1]")
    hosts=("$@[1,$((seppos - 1))]")
  else
    suite=("$@")
  fi
  (( $#hosts )) || hosts=(.connected/*(N:t))
  (( $#hosts )) || complain 1 "no hosts attached"
  (( $#suite )) || complain 1 "no command given"

  local -a this rhosts
  local h=
  for h in $hosts; do
    this=(.connected/*$h*(N:t))
    :; (( $#this )) \
    || complain 1 "$h is not attached"
    rhosts+=($this)
  done; hosts=($rhosts)

  (( $#hosts )) || complain 1 "no hosts attached"
  local id=$(< slug)

  o run-in-hosts $hosts -- \
    /usr/bin/env TESTS_LOGDIR=/var/log/qa/$id \
    "${suite/%-run}-run"
} # }}}

function do-submit # {{{
{
  local -i seppos="$@[(i)--]"
  local -a hosts; hosts=("$@[1,$((seppos - 1))]")
  local -a suite; suite=("$@[$((seppos + 1)),-1]")

  (( $#hosts )) || hosts=(.connected/*(N:t))
  (( $#hosts )) || complain 1 "no hosts attached"
  local h=
  for h in $hosts; do
    :; [[ -e .connected/$h ]] \
    || reject-misuse $h
  done
  (( $#suite == 1 )) || reject-misuse ${suite[2]-}

  local id=$(< slug)

  o run-in-hosts $hosts -- \
    /usr/share/qa/tools/remote_qa_db_report.pl \
    -b \
    -t patch:$id \
    -T "$USERNAME" \
    -f /var/log/qa/$id \
    -c "testing ${suite/%-run} on $id on $(date --utc --iso-8601=seconds)"
} # }}}

. $preludedir/smrt.coda.zsh

o $cmdname-main "$@"
