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
usage: #c HOST... -- PRODUCT...

Ssh into a refhost and earmark it for testing given products

  Options:
    -h                Display this message
    --help            Display manual page
  Operands:
    HOST              [USER@]HOSTSPEC
    PRODUCT           PRODNAME:PRODVER

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

  # at least one host, "--", at least one tag
  (( $# >= 3 )) || reject-misuse

  check-preconditions $cmdname

  impl "$@"
} # }}}

function impl # {{{
{
  local -i seppos="$@[(i)--]"
  local -a hosts; hosts=("$@[1,$((seppos - 1))]")
  local -a suite; suite=("$@[$((seppos + 1)),-1]")

  (( $#hosts )) || reject-misuse
  (( $#suite )) || reject-misuse

  local ctlpath=$config_controlpath
  o mkdir -p $ctlpath:h .connected

  local h=
  for h in $hosts; do
    o print -f 'Attaching %s for %s\n' $h "$suite"
    o ssh -O check -o ControlPath=$ctlpath -q $h ||
    o ssh -MNf -o ControlPath=$ctlpath $h || {
      complain - "failed to attach $h"
      continue
    }
    o print >>| .connected/$h -f '%s\n' -- $suite
  done
} # }}}

. $preludedir/smrt.coda.zsh

o $cmdname-main "$@"
