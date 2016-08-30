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
usage: #c SLUG [DEST]

Download metadata for a maintenance request

  Options:
    -h                Display this message
    --help            Display manual page
  Operands:
    SLUG              Checkout a maintenance update SLUG
    DEST              Destination directory, defaults to SLUG

'

declare -gr needs_config=testreport_repository

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
  $~PATTERN_SLUG) : ;;
  *) reject-misuse $arg ;;
  esac

  (( $# < 3 )) || reject-misuse $3

  o check-preconditions $cmdname

  o impl "$@"
} # }}}

function impl # {{{
{
  local slug=$1 dest=${2:-$1}
  o destdir-ok $dest
  local msg="Checking out $slug"
  [[ $slug == $dest ]] || msg+=" into $dest"
  print -r $msg
  o svn -q checkout $config_testreport_repository/$slug $dest/
} # }}}

. $preludedir/smrt.coda.zsh

o $cmdname-main "$@"
