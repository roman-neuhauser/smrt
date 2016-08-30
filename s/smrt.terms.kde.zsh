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


declare -gr preludedir="${SMRT_PRELUDEDIR:-@preludedir@}"

. $preludedir/smrt.prelude.zsh || exit 2


function $cmdname-main # {{{
{
  (( $# )) || reject-misuse

  o konsole --nofork
  declare -gr K_DBUS_SRV=org.kde.konsole-$!
  local sessno=1

  o sleep 1
  o new-tab $sessno $1
  shift

  while (( $# )); do
    o sleep 1
    sessno=$(o qdbus $K_DBUS_SRV /Konsole newSession)

    o sleep 1
    o new-tab "$sessno" $1
    shift
  done
} # }}}

function new-tab # {{{
{
  local sessno=$1 host=$2
  o qdbus $K_DBUS_SRV /Sessions/$sessno sendText "ssh -Y $host"
  o sleep 1
  o qdbus $K_DBUS_SRV /Sessions/$sessno sendText $'\n'
} # }}}

o $cmdname-main "$@"
