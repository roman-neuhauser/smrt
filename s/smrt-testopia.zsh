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
usage: #c create PACKAGE
usage: #c list PACKAGE
usage: #c show TCID

Query and manipulate Testopia testcases

  Options:
    -h                Display this message
    --help            Display manual page
  Operands:
    create            Create new testcase; opens editor
    list              List testcases for a given PACKAGE
    show              Display a testcase
    PACKAGE           Package name
    TCID              Testcase id
'

declare -gr needs_config='bugzilla_url testopia_url testopia_user testopia_pass'

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
  create|list|show) : ;;
  *) reject-misuse ${1-} ;;
  esac

  (( $# == 2 )) || reject-misuse ${3-}

  check-preconditions $cmdname

  o impl "$@"
} # }}}

function impl # {{{
{
  local -x testopia_url=$config_testopia_url
  local -x testopia_user=$config_testopia_user
  local -x testopia_pass=$config_testopia_pass
  o python3 $preludedir/smrt.testopia.py "$@"
} # }}}

. $preludedir/smrt.coda.zsh

o $cmdname-main "$@"
