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
usage: #c [--adopt] [--push] {MPRJ|MRID|SLUG} [DEST]

Download metadata for a maintenance request

  Options:
    -h                Display this message
    --help            Display manual page
    --adopt           Assign the maintenance request to yourself for testing
    --push            Publish metadata in testreport repository
  Operands:
    MRID              Maintenance request MRID
    MPRJ              Maintenance request currently linked into
                      the maintenance project MPRJ
    SLUG              MPRJ:MRID, Maintenance request MRID
    DEST              Destination directory, defaults to SLUG

'

declare -gr needs_config='bugzilla_url issuer_apiurls l3db_creds l3db_url metadata_url'

declare -gr preludedir="${SMRT_PRELUDEDIR:-@preludedir@}"

. $preludedir/smrt.prelude.zsh || exit 2

. $preludedir/smrt.bs.zsh
. $preludedir/smrt.hints.zsh
. $preludedir/smrt.xml.zsh

function $cmdname-main # {{{
{
  local -i adopt=0 push=0
  local opt arg
  local -i i=0
  while haveopt i opt arg adopt push h help -- "$@"; do
    case $opt in
    h|help) display-help $opt ;;
    adopt|push)
            : ${(P)opt::=1} ;;
    *)      reject-misuse -$arg ;;
    esac
  done; shift $i

  local id=${1-} dst=${2-}
  local mprj= mrid=
  case $id in
  $~PATTERN_SLUG)
    : ${SMRT_ISSUER:=${id%%:*}}
    mrid=${id##*:}
    mprj=${id%:*}
  ;;
  $~PATTERN_MRID)
    mrid=$id
  ;;
  (*)
    reject-misuse $id
  ;;
  esac

  (( $# < 3 )) || reject-misuse $3

  o check-preconditions $cmdname

  local REPLY= rmprj
  o fetch-request-xml $mrid
  rmprj=$REPLY

  [[ -n $mprj ]] || mprj=$rmprj

  [[ $mprj == $rmprj ]] || {
    complain 1 "$mprj:$mrid does not exist"
  }

  o impl $mprj $mrid $dst

  if (( push )); then
    o smrt push
  fi

  if (( adopt )); then
    o oscqam assign --skip-template $mrid
  fi
} # }}}

function impl # {{{
{
  local mprj=$1 mrid=$2
  local slug=$mprj:$mrid
  local dst=${3-$slug}

  o destdir-ok $dst

  o cd $dst

  print Downloading $slug metadata ${3+into $dst}

  o redir -1 reviewers \
    curl -Sfs $config_metadata_url/reviewers

  o redir -1 productdefs.pm \
    curl -Sfs $config_metadata_url/productdefs.pm

  o redir -1 productdefs \
    perl $preludedir/smrt.tps.pl productdefs.pm

  o redir -1 testplatforms.pm \
    curl -Sfs $config_metadata_url/testplatforms.pm

  o redir -1 testplatforms \
    perl $preludedir/smrt.tps.pl testplatforms.pm

  o redir -1 request.xml \
    bs-fetch-request $mrid

  o redir -1 request.diff.xml \
    bs-fetch-request-diff $mrid

  o redir -1 patchinfo.xml \
    bs-fetch-patchinfo $mprj

  o redir -1 packages.xml \
    bs-fetch-packages $mprj

  o redir -1 project.xml \
    bs-fetch-project $mprj

  o redir -1 repositories.xml \
    bs-fetch-repos $mprj

  o redir -1 patchinfo \
    fetch-patchinfo patchinfo.xml

  o redir -0 project.xml -1 repos-sources \
    xml-ls-repos standard

  o redir -0 project.xml -1 repos-binaries \
    xml-ls-repos update

  o redir -1 sources \
    xml-ls-released-sources packages.xml repos-binaries

  o redir -1 binaries \
    xml-ls-released-binaries packages.xml repos-binaries

  o redir -1 maintainers \
    fetch-package-maintainers sources

  o redir -1 request.diff \
    xml-xform-request-diff request.diff.xml

  o redir -1 issues \
    xml-ls-bugs patchinfo.xml

  o generate-bugs issues

  o redir -1 l3s.xml \
    sg-fetch-l3s bugs/bnc*(:t:s/bnc//)

  [[ -s l3s.xml ]] \
  && o redir -0 l3s.xml \
    xml-xform-l3s

  o redir -1 allarchtrigger \
    curl -Sfs $config_metadata_url/packages-to-be-tested-on-all-archs

  o redir -1 minimaltrigger \
    curl -Sfs $config_metadata_url/packages-to-be-tested-on-minimal-systems

  o generate-hints

  o generate-warnings

  o redir -1 slug \
    print $slug
} # }}}

function generate-hints # {{{
{
  local -a pkgs; pkgs=($(cut -d ' ' -f 4 binaries))
  local -A patchinfo; patchinfo=($(cat patchinfo))
  local -a minimaltrigger; minimaltrigger=($(sed -n '/^[^#]/ { s/\s*$//; p; }' minimaltrigger))
  local -a hints;
  if [[ ${(L)patchinfo[category]} == (yast|you) ]]; then
    hints+=($hints_yast_online_update "")
  fi

  if [[ -n ${(M)pkgs:#(MozillaFirefox*|epiphany*|mozilla|*-konqueror|opera)} ]]; then
    hints+=($hints_browser "")
  fi

  if [[ -n ${(M)pkgs:#(acroread|evince|kdegraphics3-pdf|okular|xpdf)} ]]; then
    hints+=($hints_pdfviewer "")
  fi

  if [[ -n ${pkgs:*minimaltrigger} ]]; then
    hints+=($hints_minimal_system "")
  fi

  if (( $#hints )); then
    redir -1 hints print -r -- "${(@F)hints}"
  fi
} # }}}

function generate-warnings # {{{
{
  local -a pds; pds=(${(f):-"$(< productdefs)"})

  local -A pas; pas=()
  local pd
  for pd in $pds; do
    local name= base= class= major= minor= archs=
    pd=${pd#:}
    eval $pd
    pas[$name]=$archs
  done

  local -a warnings

  local -a pvas; pvas=(${${:-$(cut -d \  -f 2 repos-binaries)}#SUSE:Updates:})
  local pv
  for pv in ${(ou)pvas%:*}; do
    local -a a; a=(${(ou)${(M)pvas:#$pv:*}##*:})
    local as="${(j: :)a/i586/i386}"
    (( 1 == ${+pas[$pv]} )) \
    || complain 1 "product ${(qqq)pv} not found in 'productdefs'!"
    if [[ $pas[$pv] != $as ]]; then
      warnings+=(
        "the list of architectures for product ${(qqq)pv/:/ } is not matching!"
        "it should have: ${pas[$pv]:s/i586/i386/:gs/ /, }"
        "it has: ${as// /, }"
      )
    fi
  done

  if (( $#warnings )); then
    redir -1 warnings print -r -- "${(@F)warnings}"
  fi
} # }}}

function sg-fetch-l3s # {{{
{
  trap "o rm -f l3s.xml.tmp" EXIT
  o redir -1 l3s.xml.tmp \
    curl -Sfs \
      -H 'Accept: application/xml' \
      -H "Authorization: ApiKey $config_l3db_creds" \
      "$config_l3db_url${(@j:,:)@}"
  [[ ! -s l3s.xml.tmp ]] \
  || o redir -1 l3s.xml xml fo l3s.xml.tmp
} # }}}

function xml-xform-l3s # {{{
{
  trap 'o rm -f l3s.tmp' EXIT
  :; o redir -1 l3s.tmp \
    xml sel -T -t \
    -m /response/objects/object \
      -o bug_id= -o bnc -v bug_id -o $'\001' \
      -o incident= -v incident -o $'\001' \
      -o summary= -v summary -o $'\001' \
      -o probability= -v probability -o $'\001' \
      -o impact= -v outcome -o $'\001' \
      -o patch= -v patch -o $'\001' \
      -o reproducer= -v reproducer -o $'\001' \
      -o requires_3dparty= -v requires_thirdparty -o $'\001' \
  || return 0
  o redir -0 l3s.tmp \
    awk '
      BEGIN {
        FS = "=";
        OFS = "=";
        RS = "\001";
      }
      ($1 == "bug_id") {
        bug = $2;
        next;
      }
      ($1 == "incident") {
        split($2, parts, "/");
        $2 = parts[5];
        fn = sprintf("bugs/%s/l3info.%s", bug, $2);
        printf("") > fn;
      }
      ($1 == "requires_3dparty") {
        $2 = ($2 == "True") ? "yes" : ($2 == "False") ? "no" : $2;
      }
      {
        hd = sprintf("%s=", $1);
        if ($1 ~ /^(summary|reproducer)$/) {
          gsub(/\r*\n/, "\n", $0);
          gsub(/\n/, sprintf("\n%s", hd), $0);
        }
        print $0 >> fn;
      }
    '
} # }}}

function fetch-patchinfo # {{{
{
  local inxml=$1 tmp=${1:r}.tmp
  trap "o rm -f $PWD/$tmp" EXIT
  o redir -0 $inxml -1 $tmp \
    xml-ls-patchinfo
  local -A data; data=($(cat $tmp))
  local name=$data[packager]
  o fetch-info person $name
  local -a reply
  o xml-get-email person-$name.xml
  data[packager]=$reply
  o redir -1 $tmp:r \
    print -f '%s %s\n' "${(@kv)data}"
} # }}}

function fetch-request-xml # {{{
{
  local mrid=$1 _mprj rxml=$(mktemp)
  trap "o rm -f $rxml" EXIT
  o redir -1 $rxml bs-fetch-request $mrid
  o xml sel -T -t \
      -m //action/source \
      -v @project \
      --nl \
      $rxml \
  | sort -u \
  | read REPLY
} # }}}

function fetch-package-maintainers # {{{
{
  local srcrpms=$1
  local kind email name p
  local -a emails names reply

  o cut -f 2 -d ' ' $srcrpms \
  | sort -u \
  | while read p; do
      local owners_xml=owners-$p.xml

      print -f '%s' -- $p

      o redir -1 $owners_xml \
        bs-fetch-maintainers $p

      o xml-get-maintainers $owners_xml
      names=($reply)
      (( $#names )) || {
        complain - "package $p has no maintainer"
        print
        continue
      }

      local -a people groups
      for kind name in $names; do
        case $kind in
        person) people+=($name) ;;
        group)  groups+=($name) ;;
        esac
      done

      emails=()

      for name in $groups; do
        o fetch-info group $name
        o xml-get-email group-$name.xml
        if (( $#reply )); then
          emails+=($reply)
          continue
        fi
        o xml-get-group-members group-$name.xml
        people+=($reply)
      done

      for name in ${(u)people}; do
        o fetch-info person $name
        o xml-get-email person-$name.xml
        emails+=($reply)
      done
      o print -f ' %s\n' -- ${(j: :)${(u)emails}}
    done
} # }}}

function fetch-info # {{{
{
  local kind=$1 name=$2
  local file=$kind-$name.xml
  [[ -e $file ]] \
  || o redir -1 $file \
     bs-fetch-info $kind $name
} # }}}

function generate-bugs # {{{
{
  local issues=$1
  local bugid subject
  mkdir bugs
  while read bugid subject; do
    mkdir bugs/$bugid
    redir -1 bugs/$bugid/url \
      print -f '%s/show_bug.cgi?id=%s\n' -- \
        $config_bugzilla_url \
        ${bugid#bnc}
    redir -1 bugs/$bugid/subject \
      print -r -- $subject
  done < $issues
} # }}}

. $preludedir/smrt.coda.zsh

o $cmdname-main "$@"
