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

declare -gr cmdname=$0:t

# FIXME: the duplicated summaries == PITA
declare -gr cmdhelp="

usage: #c -h|--help
usage: #c [--issuer=ISSUER] COMMAND [OPTION...] [ARGUMENT...]
  Options:
    -h                Display this message
    --help            Display manual page
    -I, --issuer      Assume ISSUER for commands which take
                      maintenance request ids
  Operands:
    COMMAND           One of the commands listed below

  Commands:
    adopt             Adopt a maintenance request for testing
    attach            Ssh into a refhost and earmark it for testing given products
    bs                Download XML data for a maintenance request from the BuildService
    bugs              List or browse bugs related to a maintenance request
    checkout          Download metadata for a maintenance request
    config            Manipulate smrt configuration file
    detach            Disconnect attached refhost(s)
    fetch             Download metadata for a maintenance request
    get               Download files and directories from attached hosts
    hosts             Display information on attached hosts
    mklog             Create MTUI-compatible testreport
    packages          Display version information for packages under test
    prepare           Prepare hosts for current maintenance update
    push              Publish metadata for a maintenance request
    put               Upload files and directories to attached hosts
    repose            Use repose on attached hosts
    revert            Downgrade relevant packages to latest released versions
    run               Run a command in attached hosts
    tcf               Query and manipulate CTCS2 testsuites and results
    terms             Open terminals for attached hosts
    testopia          Query and anipulate Testopia testcases
    update            Install current maintenance update
    xml               Display information gleaned from BuildService XML data

"

declare -grx SMRT_PRELUDEDIR="${SMRT_PRELUDEDIR:-@preludedir@}"
declare -gr preludedir=$SMRT_PRELUDEDIR

. $preludedir/smrt.prelude.zsh || exit 2

function main # {{{
{
  local opt arg
  local -i i=0
  while haveopt i opt arg h help I= issuer= -- "$@"; do
    case $opt in
    h|help)   display-help $opt ;;
    I|issuer) declare -gx SMRT_ISSUER=$arg ;;
    *)        reject-misuse -$arg ;;
    esac
  done; shift $i

  (( $# )) || display-help h

  local REPLY=
  O find-cmd $1
  o run-cmd "$REPLY" $@[2,-1]
} # }}}

function find-cmd # {{{
{
  local name=smrt-$1 impl=

  for impl in $name $bindir/$name; do
    if impl=$(whence $impl); then
      REPLY=$impl
      return
    fi
  done

  complain 1 "unknown command ${(qq)1}"
} # }}}

function run-cmd # {{{
{
  "$@"
} # }}}

. $preludedir/smrt.coda.zsh

bindir=$0:h main "$@"
