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
usage: #c [HOST...]
usage: #c --packages [HOST... --] [PACKAGE...]

Display information on attached hosts

  Options:
    -h                Display this message
    --help            Display manual page
    --packages        Display version information for packages under test
                      as currently installed (or not) on each HOST
  Operands:
    HOST              Display information on HOST
    PACKAGE           Display information on PACKAGE

'

declare -gr needs_workdir=1

declare -gr preludedir="${SMRT_PRELUDEDIR:-@preludedir@}"

. $preludedir/smrt.prelude.zsh || exit 2

function $cmdname-main # {{{
{
  local impl=list-hosts
  local opt arg
  local -i i=0
  while haveopt i opt arg h help packages -- "$@"; do
    case $opt in
    h|help) display-help $opt ;;
    packages) impl=list-packages ;;
    ?)      reject-misuse -$arg ;;
    esac
  done; shift $i

  check-preconditions $cmdname

  o $impl "$@"
} # }}}

function list-hosts # {{{
{
  local -a hosts; hosts=("$@")
  (( $#hosts )) || hosts=(.connected/*(N:t))

  local -a this rhosts
  local h=
  for h in $hosts; do
    this=(.connected/*$h*(N:t))
    :; (( $#this )) \
    || complain 1 "$h is not attached"
    rhosts+=($this)
  done; hosts=($rhosts)

  (( $#hosts )) || return 0

  local f= tags=
  for h in $hosts; do
    f=.connected/$h
    tags="${(pj: :)${(f)$(<$f)}}"
    print -f '%-28s %s\n' $h $tags
  done
} # }}}

function list-packages # {{{
{
  local -a hosts suite
  local -i seppos="$@[(i)--]"
  suite=("$@")
  if (( seppos <= $# )); then
    hosts=("$@[1,$((seppos - 1))]")
    suite=($(awk '{print $4}' binaries | sort -u))
  fi
  (( $#hosts )) || hosts=(.connected/*(N:t))
  (( $#hosts )) || complain 1 "no hosts attached"
  (( $#suite )) || suite=($(cut -d ' ' -f 2 sources | sort -u))

  local -a this rhosts
  local h=
  for h in $hosts; do
    this=(.connected/*$h*(N:t))
    :; (( $#this )) \
    || complain 1 "$h is not attached"
    rhosts+=($this)
  done; hosts=($rhosts)

  (( $#hosts )) || complain 1 "no hosts attached"

  o run-in-hosts \
    $hosts \
    -- \
    "rpm -q --queryformat '%{NAME} %{VERSION} %{RELEASE}\n' $suite"
} # }}}

. $preludedir/smrt.coda.zsh

o $cmdname-main "$@"
