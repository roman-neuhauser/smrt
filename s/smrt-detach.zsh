#!@ZSH@ -f
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
usage: #c [--dead] [HOST...]

Disconnect attached refhost(s)

  Options:
    -h                Display this message
    --help            Display manual page
    --dead            Detach only disconnected hosts
  Operands:
    HOST              Machine to detach

'

declare -gr needs_workdir=1

declare -gr preludedir="${SMRT_PRELUDEDIR:-@preludedir@}"

. $preludedir/smrt.prelude.zsh || exit 2

function $cmdname-main # {{{
{
  local opt arg impl=impl-default
  local -i i=0
  while haveopt i opt arg h help dead -- "$@"; do
    case $opt in
    h|help) display-help $opt ;;
    dead)   impl=impl-dead ;;
    ?)      reject-misuse -$arg ;;
    esac
  done; shift $i

  check-preconditions $cmdname

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

  o $impl $hosts
} # }}}

function impl-default # {{{
{
  local h= ctlpath=$config_controlpath
  for h in "$@"; do
    print -f 'Detaching %s\n' $h
    o rm .connected/$h
    if o ssh -o ControlPath=$ctlpath -O check $h; then
      o ssh -o ControlPath=$ctlpath -O exit $h
    else
      complain - "No connection to $h"
    fi
  done
} # }}}

function impl-dead # {{{
{
  local h= ctlpath=$config_controlpath
  for h in "$@"; do
    if o ssh -o ControlPath=$ctlpath -O check $h; then
      continue
    fi
    print -f 'Detaching dead %s\n' $h
    o rm .connected/$h
  done
} # }}}

. $preludedir/smrt.coda.zsh

o $cmdname-main "$@"
