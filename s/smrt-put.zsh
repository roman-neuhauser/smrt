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
usage: #c [HOST... --] SOURCE... TARGET

Upload files and directories to attached hosts

  Options:
    -h                Display this message
    --help            Display manual page

  Operands:
    HOST              Machine to upload to
    SOURCE            Pathname to upload
    TARGET            Destination path

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

  (( $# )) || reject-misuse

  check-preconditions $cmdname

  local -i seppos="$@[(i)--]"
  local -a hosts suite
  suite=("$@")
  if (( seppos <= $# )); then
    hosts=("$@[1,$((seppos - 1))]")
    suite=("$@[$((seppos + 1)),-1]")
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

  o impl $hosts -- $suite
} # }}}

function impl # {{{
{
  local -i seppos="$@[(i)--]"
  local -a hosts; hosts=("$@[1,$((seppos - 1))]")
  local -a suite; suite=("$@[$((seppos + 1)),-1]")

  local -a popts; popts=(
    --quote
    --plain
    --tag
    --joblog joblog
    --jobs=0
  )
  local ctlpath=$config_controlpath

  o parallel "${(@)popts}" \
    scp -pro BatchMode=yes -o ControlPath=$ctlpath  \
    "${(@)suite[1,-2]}" "{1}:${suite[-1]}" \
    ::: "${(@)hosts}"
} # }}}

. $preludedir/smrt.coda.zsh

o $cmdname-main "$@"
