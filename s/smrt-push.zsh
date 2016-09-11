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
usage: #c

Publish metadata for a maintenance request

  Options:
    -h                Display this message
    --help            Display manual page

'

declare -gr needs_workdir=1
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

  (( $# == 0 )) || reject-misuse $1

  o check-preconditions $cmdname

  o impl "$@"
} # }}}

function impl # {{{
{
  local slug=$(< slug)
  local repo=$config_testreport_repository
  [[ -d .svn ]] || {
    :; o svn info $repo/$slug >/dev/null 2>&1 \
    || o svn -q mkdir -m SMRT $repo/$slug

    o svn -q checkout $repo/$slug .checkout
    o mv -n .checkout/*(D) .
    o rm -r .checkout
  }
  local -a news
  local line
  o svn status \
  | while IFS= read line; do
      [[ $line == \?* ]] || continue
      news+=($line[9,-1])
    done

  (( $#news )) || {
    complain 1 'nothing to publish'
  }

  if (( $#news )); then
    o svn -q add $^news@
  fi

  print -f 'Publishing results into\n'
  print -f '  %s/%s\n' $repo $slug
  print -f '  %s/%s\n' $repo:s~#*@~http://~ $slug

  o svn -q commit -m smrt
} # }}}

. $preludedir/smrt.coda.zsh

o $cmdname-main "$@"
