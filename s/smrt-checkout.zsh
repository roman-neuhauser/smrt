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

usage: #c -h|<ID>
Download metadata for a maintenance request
  Options:
    -h                Display this message
  Operands:
    <ID>              Checkout a maintenance update <ID>

'

declare -gr needs_config=testreport_repository

declare -gr preludedir="${SMRT_PRELUDEDIR:-@preludedir@}"

. $preludedir/smrt.prelude.zsh || exit 2

function $0:t # {{{
{
  local opt arg
  local -i i=0
  while haveopt i opt arg h help -- "$@"; do
    case $opt in
    h|help) display-help ;;
    *)      reject-misuse -$arg ;;
    esac
  done; shift $i

  arg=${1-}
  case $arg in
  $~PATTERN_SLUG) : ;;
  *) reject-misuse $arg ;;
  esac

  o check-preconditions $0

  o impl "$@"
} # }}}

function impl # {{{
{
  local name=$1
  print Checking out $name
  mkdir -p $name
  o svn -q checkout $config_testreport_repository/$name $name/
} # }}}

. $preludedir/smrt.coda.zsh

$0:t "$@"
