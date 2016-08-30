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
usage: #c maintainers PKG
usage: #c packages MPRJ|SLUG
usage: #c patchinfo MPRJ|SLUG
usage: #c project MPRJ|SLUG
usage: #c repos MPRJ|SLUG
usage: #c request MRID|SLUG
usage: #c request-diff MRID|SLUG

Download XML data for a maintenance request from the BuildService

  Options:
    -h                Display this message
    --help            Display manual page

  Operands:
    maintainers       Download maintainer data for a package
    packages          Download packages.xml data
    patchinfo         Download patchinfo.xml data
    project           Download project.xml data
    repos             Download repositories.xml data
    request           Download request.xml data
    request-diff      Download request.diff.xml data
    MPRJ              ISSUER:Maintenance:ISSUE
    MRID              Maintenance request MRID
    PKG               Package name
    SLUG              MPRJ:MRID
'

declare -gr needs_config='assumed_issuer'

declare -gr preludedir="${SMRT_PRELUDEDIR:-@preludedir@}"

. $preludedir/smrt.prelude.zsh || exit 2

. $preludedir/smrt.bs.zsh

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

  local cmd=${1-} arg=${2-}
  case $cmd in
  maintainers)
    : # $arg is (supposed to be) a (source) package name
  ;;
  packages|patchinfo|project|repos)
    case $arg in
    $~PATTERN_SLUG)
      arg=${arg%:*}
    ;&
    $~PATTERN_MPRJ)
      : ${SMRT_ISSUER:=${arg%%:*}}
    ;;
    *) reject-misuse $arg ;;
    esac
  ;;
  request|request-diff)
    case $arg in
    $~PATTERN_SLUG)
      : ${SMRT_ISSUER:=${arg%%:*}}
      arg=${arg##*:}
    ;;
    *) reject-misuse $arg ;;
    esac
  ;;
  *)
    reject-misuse $cmd
  ;;
  esac

  (( $# == 2 )) || reject-misuse $3

  check-preconditions $cmdname

  : ${SMRT_ISSUER:=$config_assumed_issuer}

  bs-fetch-$cmd $arg
} # }}}

. $preludedir/smrt.coda.zsh

o $cmdname-main "$@"
