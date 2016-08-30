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
usage: #c binaries [PACKAGES.XML]
usage: #c bugs [PATCHINFO.XML]
usage: #c channels [PROJECT.XML]
usage: #c codestreams [PROJECT.XML]
usage: #c diff [REQUEST.DIFF.XML]
usage: #c email [PERSON.XML]
usage: #c maintainers [OWNERS.XML]
usage: #c sources [PACKAGES.XML]

Display information gleaned from BuildService XML data

  Options:
    -h                Display this message
    --help            Display manual page

  Operands:
    binaries          List released packages
    bugs              List referenced bugs
    channels          List update channels
    codestreams       List codestreams
    diff              Display unified diff
    email             Display email address of a maintainer
    maintainers       List maintainer usernames
    sources           List released packages
'

declare -gr preludedir="${SMRT_PRELUDEDIR:-@preludedir@}"

. $preludedir/smrt.prelude.zsh || exit 2

. $preludedir/smrt.xml.zsh

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
    binaries    \
  | bugs        \
  | channels    \
  | codestreams \
  | diff        \
  | email       \
  | maintainers \
  | sources     )
    :
  ;;
  *) reject-misuse $arg ;;
  esac
  shift

  check-preconditions $cmdname

  do-$arg "$@"
} # }}}

function do-diff # {{{
{
  if [[ $# -eq 0 ]]; then
    :; [[ -f request.diff.xml ]] \
    || reject-misuse
    set -- request.diff.xml
  elif [[ $# -gt 1 ]]; then
    reject-misuse $2
  elif [[ ! -f $1 && $1 != - ]]; then
    reject-misuse $1
  fi

  o xml-xform-request-diff $1
} # }}}

function do-email # {{{
{
  :; [[ $# -eq 1 ]] \
  || reject-misuse ${2-}
  :; [[ -f $1 ]] \
  || reject-misuse $1

  local -a reply
  o xml-get-email $1
  o print -f '%s\n' -- $reply
} # }}}

function do-maintainers # {{{
{
  :; [[ $# -eq 1 ]] \
  || reject-misuse ${2-}
  :; [[ -f $1 || $1 == - ]] \
  || reject-misuse $1

  local -a reply
  o xml-get-maintainers $1
  o print -f '%s %s\n' -- $reply
} # }}}

function do-bugs # {{{
{
  if [[ $# -eq 0 ]]; then
    :; [[ -f patchinfo.xml ]] \
    || reject-misuse
    set -- patchinfo.xml
  elif [[ $# -gt 1 ]]; then
    reject-misuse $2
  elif [[ ! -f $1 && $1 != - ]]; then
    reject-misuse $1
  fi

  o xml-ls-bugs ${1/#%-//dev/stdin}
} # }}}

function do-channels do-codestreams # {{{
{
  if [[ $# -eq 0 ]]; then
    :; [[ -f project.xml ]] \
    || reject-misuse
    set -- project.xml
  elif [[ $# -gt 1 ]]; then
    reject-misuse $2
  elif [[ ! -f $1 && $1 != - ]]; then
    reject-misuse $1
  fi

  local inf=${1/#%-//dev/stdin} kind
  case $0 in
  do-channels)    kind=update   ;;
  do-codestreams) kind=standard ;;
  esac
  o redir -0 $inf xml-ls-repos $kind
} # }}}

function do-binaries do-sources # {{{
{
  if [[ $# -eq 0 ]]; then
    :; [[ -f packages.xml ]] \
    || reject-misuse
    set -- packages.xml
  elif [[ $# -gt 1 ]]; then
    reject-misuse $2
  elif [[ ! -f $1 && $1 != - ]]; then
    reject-misuse $1
  fi

  local inf=$1 kind=${0#do-}
  o xml-ls-released-$kind $inf ${inf:h}/repos-$kind
} # }}}

. $preludedir/smrt.coda.zsh

o $cmdname-main "$@"
