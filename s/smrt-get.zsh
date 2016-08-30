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
usage: #c [HOST...] -- SOURCE...

Download files and directories from attached hosts

  Options:
    -h                Display this message
    --help            Display manual page

  Operands:
    HOST              Machine to download from
    SOURCE            Pathname to download

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

  local -i seppos="$@[(i)--]"
  local -a hosts suite
  if (( $seppos <= $# )); then
    hosts=("$@[1,$((seppos - 1))]")
    suite=("$@[$((seppos + 1)),-1]")
  else
    suite=("$@")
  fi

  (( $#suite )) || reject-misuse

  check-preconditions $0

  (( $#hosts )) || hosts=(.connected/*(N:t))
  (( $#hosts )) || complain 1 "no hosts attached"

  local h=
  for h in $hosts; do
    :; [[ -f .connected/$h ]] \
    || reject-misuse $h
  done

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

  local r=
  for r in $suite; do
    local l=${${r#(../)##}#/##}
    o mkdir -p ${^hosts}/$l:h
    o parallel "${(@)popts}" \
      scp -pro BatchMode=yes -o ControlPath=$ctlpath  \
      "{1}:$r" "{1}/$l" \
      ::: "${(@)hosts}"
  done
} # }}}

. $preludedir/smrt.coda.zsh

o $cmdname-main "$@"