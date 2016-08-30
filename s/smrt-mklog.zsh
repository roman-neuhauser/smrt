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
usage: #c

Create MTUI-compatible testreport

  Options:
    -h                Display this message
    --help            Display manual page
'

declare -gr needs_workdir=1

declare -gr preludedir="${SMRT_PRELUDEDIR:-@preludedir@}"

. $preludedir/smrt.prelude.zsh || exit 2

function $cmdname-main # {{{
{
  local opt
  local -i i=0
  while haveopt i opt arg h help -- "$@"; do
    case $opt in
    h|help) display-help $opt ;;
    *)      reject-misuse -$arg ;;
    esac
  done; shift $i

  (( $# == 0 )) || reject-misuse $1

  check-preconditions $cmdname

  o impl "$@"
} # }}}

function impl # {{{
{
  local REPLY
  local -a reply
  local slug=$(cat slug)
  local mprj=${slug%:*}
  local mpno=${mprj##*:}
  local -a projects; projects=(${${:-$(cut -d \  -f 2 repos-binaries)}#SUSE:Updates:})

  o get-products-archs $projects
  local -a prodarchs; prodarchs=($reply)

  o format-products $prodarchs
  local -a products; products=($reply)

  o format-testplatforms $prodarchs
  local -a tps; tps=($reply)

  local -A patchinfo; patchinfo=($(cat patchinfo))

  local -a bncs; bncs=($(cut -d \  -f 1 issues))

  o format-bugs
  local -a bugs; bugs=($reply)

  o get-testopia-tags
  local -a testopia_tags; testopia_tags=($reply)

  o format-binaries
  local -a binaries; binaries=($reply)

  o get-sources
  local -a sources; sources=($reply)

  o get-reviewers
  local -a reviewers; reviewers=($reply)

  local hints="$([[ ! -e hints ]] || cat hints)"
  [[ -z $hints ]] || hints=$'\n'"$hints"$'\n'

  local n=$'\n' t=$'\t'
  local warnings="$([[ ! -e warnings ]] || cat warnings)"
  [[ -z $warnings ]] || {
    warnings=${(F)${(f)warnings}/#/$t}
    warnings="$n${t}WARNING:$n$warnings$n"
  }

  local -r sp='[[:space:]]#'

  if [[ -n ${(M)sources:#kernel*~*-update-tool} ]]; then
    subst notes_kernel
  else
    subst notes_userland \
      BUGS          "${(F)bugs}" \
      HINTS         "$hints" \
      TESTOPIATAGS  "${(j:,:)${(@)testopia_tags/#/packagename_}}"
  fi
  local notes=${${REPLY/#$~sp}/%$~sp}

  subst smrt_log_template \
    COMMENT       "${warnings:- (none)}" \
    PRODUCTS      "${(j:, :)products}" \
    CATEGORY      "$patchinfo[category]" \
    RATING        "$patchinfo[rating]" \
    PACKAGER      "$patchinfo[packager]" \
    BUGIDS        "${(@j:, :)bncs#bnc}" \
    SLUG          "$slug" \
    REPOPATH      "${mprj:gs,:,:/,}" \
    BINARIES      "${(j:, :)binaries}" \
    SOURCES       "${(j:, :)sources}" \
    REVIEWERS     "${(j:, :)reviewers}" \
    MPNO          "$mpno" \
    NOTES         "$notes" \
    TESTPLATFORMS "${(@F)tps/#/Testplatform: }"

  local tmp=$REPLY
  o redir -1 log \
    print -r -- ${${tmp/#$~sp/}/%$~sp/}

  o redir -0 binaries -1 packages-list.txt \
    mk-packages-list
} # }}}

function iter-binaries # {{{
{
  local dostuff=$1
  local repo prj arch pkg ver rel fpth
  while read repo prj arch pkg ver rel fpth; do
    [[ $pkg != *-(debuginfo|debugsource)(-[^-]##)# ]] || continue
    [[ $arch != (nosrc|src) ]] || continue
    $dostuff $repo $prj $arch $pkg $ver $rel $fpth
  done < binaries
} # }}}

function mk-packages-list # {{{
{
  local -a rv; rv=()
  function $0-iter
  {
    local repo=$1 fpth=$7
    rv+=("$repo/$fpth")
  }
  iter-binaries $0-iter
  print -rl ${(o)rv}
} # }}}

function get-reviewers # {{{
{
  local -A reviewers
  local -a rv; rv=()
  local pkg addrs
  while read pkg addrs; do
    reviewers+=(${pkg%:} "$addrs")
  done < reviewers
  while read pkg addrs; do
    rv+=(${=${reviewers[$pkg]:-$addrs}})
  done < maintainers
  reply=(${(ou)rv})
} # }}}

function get-sources # {{{
{
  reply=(${(fou):-"$(cut -d \  -f 2 sources)"})
} # }}}

function get-testopia-tags # {{{
{
  local -a rv; rv=()
  function $0-iter
  {
    local pkg=$4
    rv+=($pkg)
  }
  iter-binaries $0-iter
  reply=(${(ou)rv})
} # }}}

function format-binaries # {{{
{
  local -a rv; rv=()
  function $0-iter
  {
    local pkg=$4 ver=$5 rel=$6
    rv+=("$pkg = $ver-$rel")
  }
  iter-binaries $0-iter
  reply=(${(ou)rv})
} # }}}

function format-bugs # {{{
{
  local -a rv
  local bnc summary
  while read bnc summary; do
    (( $#summary <= 60 )) || summary=$summary[1,60]...
    local i=${bnc#bnc}
    local h="Bug #$i (\"$summary\"):"
    local u=${(l:$(($#h))::-:):-}
    reply=()
    o format-l3infos $bnc
    local l3="${(@F)reply}"
    subst bugtpl BUGID "$i" HEADING "$h" UNDERLINE "$u" L3INFO "$l3"
    rv+=($REPLY)
  done < issues
  reply=($rv)
} # }}}

function format-l3infos # {{{
{
  local -a rv; rv=()
  local l3=
  reply=()
  for l3 in bugs/$1/l3info.<->(N); do
    local REPLY=
    o format-l3info $l3
    rv+=("$REPLY""${(g::):-\n\n}")
  done
  reply=("${(@)rv}")
  (( ! $#reply )) \
  || reply=("additional info from L3:" "" $reply)
} # }}}

function format-l3info # {{{
{
  declare -A labels; labels=(
    impact            "Impact"
    incident          "Incident ID"
    patch             "Patch"
    probability       "Probability"
    reproducer        "Reproducer"
    requires_3dparty  "Requires 3rd-party"
    summary           "Summary"
  )
  declare -A multis; multis=(
    reproducer 1
    summary 1
  )

  declare label= value= this= prev=
  declare -i multiline=0 firstline=0
  declare -a rv; rv=()
  while IFS== read -r label value; do
    this=$label
    multiline=${+multis[$label]}
    firstline=${#this:#$prev}
    prev=$this
    if (( multiline && firstline )); then
      rv+=("$(print -f "\t%s\n\t\t%s\n" "$labels[$label]:" "$value")")
    elif (( multiline )); then
      rv+=("$(print -f "\t\t%s\n" -- "$value")")
    else
      rv+=("$(print -f "\t%-20s%s\n" -- "$labels[$label]:" "$value")")
    fi
  done < $1
  REPLY="${(@F)rv}"
} # }}}

function get-products-archs # {{{
{
  local -a projects; projects=($@)
  local -a a rv; rv=()
  local pv
  for pv in ${(ou)projects%:*}; do
    a=(${${(M)projects:#$pv:*}##*:})
    rv+=("$pv" "${(j: :)a}")
  done
  reply=($rv)
} # }}}

function format-products # {{{
{
  local -a projects; projects=($@)
  local -a rv; rv=()
  local pv archs
  for pv archs in $projects; do
    archs=${archs/i586/i386} # a quirk for legacy compat
    rv+=("${pv//:/ } (${archs// /, })")
  done
  reply=(${(o)rv})
} # }}}

function format-testplatforms # {{{
{
  local -a sources
  o get-sources
  sources=($reply)

  local -a allarchtrigger; allarchtrigger=("${(Z:Cn:):-$(< allarchtrigger)}")

  local allarchs=${#sources:*allarchtrigger}

  local -A projects; projects=("$@")

  local -a tps; tps=(${${(f):-"$(cat testplatforms)"}/#: })

  # $notest_classes, $notest_archs are shared with prj2tp and mktphdr
  local -a notest_classes; notest_classes=(debug java teradata)
  local -a notest_archs
  (( allarchs )) || notest_archs=(ia64 ppc64 ppc64le)
  # $tpdefs is shared with prj2tp and mktphdr
  local -A tpdefs
  local tpl
  for tpl in $tps; do
    local name= major= minor= class= base= archs=
    tpl=${tpl#:}
    eval $tpl
    if [[ -n ${projects[$name]:-} ]]; then
      archs=${projects[$name]/i586/i386}
    fi
    local n=
    local -a qs; qs=()
    for n in name major minor class base archs; do
      qs+=("$n=${(Pq-)n}")
    done
    tpdefs[$name]="${(j: :)qs}"
  done

  function prj2tp # {{{
  {
    local vt=$1 prj=$2
    local name= major= minor= class= base= archs=
    (( ${+tpdefs[$prj]} )) || {
      reply=()
      return
    }
    eval $tpdefs[$prj]
    if [[ $class == (${(~j:|:)notest_classes}) ]]; then
      reply=()
      return
    fi
    local -a rv; rv=()
    if [[ -n $base ]]; then
      local b
      for b in $=base; do
        mktphdr $vt $b $name
        rv+=($reply)
      done
    else
      mktphdr $vt $name
      rv+=($reply)
    fi
    reply=($rv)
  } # }}}

  function mktphdr # {{{
  {
    local -a tags
    local vt=$1 name=$2 addon=${3-} major= minor= class= base= archs=
    (( ${+tpdefs[$name]} )) || {
      reply=()
      return
    }
    eval $tpdefs[$name]
    if [[ $class == (${(~j:|:)notest_classes}) ]]; then
      reply=()
      return
    fi
    local bclass=$class
    local -A aparts
    aparts+=(base "$class(major=$major,minor=$minor)")
    if [[ -n $addon ]]; then
      major= minor=
      eval $tpdefs[$addon]
      aparts+=(addon "$class(major=$major,minor=$minor)")
    fi
    local -a aarchs; aarchs=($=archs)
    aarchs=(${aarchs:|notest_archs})
    aparts+=(arch "[${(j:,:)aarchs}]")
    local -a parts
    local k
    for k in base arch addon; do
      (( $+aparts[$k] )) || continue
      parts+="$k=$aparts[$k]"
    done
    local tphdr="${(j-;-)parts}"
    local -a tvs
    case $vt in
    --kernel)
      tvs+=("$tags kernel" '')
    ;;
    --hyperv)
      tvs+=("$tags" 'virtual=(mode=guest,hypervisor=hyperv)')
    ;;
    --vmware)
      tvs+=("$tags" 'virtual=(mode=guest,hypervisor=vmware)')
    ;;
    --kvm)
      if [[ $bclass == sles ]]; then
        tvs+=("$tags" 'virtual=(mode=guest,hypervisor=kvm)')
        tvs+=("$tags" 'virtual=(mode=host,hypervisor=kvm)')
      else
        tvs+=("$tags" 'virtual=(hypervisor=kvm)')
      fi
    ;;
    --xen)
      if [[ $bclass == sles ]]; then
        tvs+=("$tags" 'virtual=(mode=guest,hypervisor=xen)')
        tvs+=("$tags kernel" 'virtual=(mode=host,hypervisor=xen)')
      else
        tvs+=("$tags" 'virtual=(hypervisor=xen)')
      fi
    ;;
    esac
    local -a rv tp
    local t v
    for t v in "${(@)tvs}"; do
      t=${(j:,:)${(s: :)t}}
      t=${t:+tags=($t)}
      tp=($tphdr $t $v)
      rv+=("${(j.;.)tp}")
    done
    reply=(${rv:-$tphdr})
  } # }}}

  # adapted from templates-management/qa_maintained_template_bs.pl
  # the logic is equally dubious in both places (notice how libvirt
  # is mentioned in two legs)
  local vt=
  if [[ -n ${(M)sources:#kernel*~*-update-tool} ]]; then
    vt=kernel
  elif [[ -n ${(M)sources:##(libvirt|virt-manager|xen%|xen-)} ]]; then
    vt=xen
  elif [[ -n ${(M)sources:##(libvirt|qemu)} ]]; then
    vt=kvm
  elif [[ -n ${(M)sources:##(sblim-gather-novirt|vmware|release-notes-SLES-for-VMware|SLES-for-VMware-release|SLES-for-VMware-SP3-migration)} ]]; then
    vt=vmware
  elif [[ -n ${(M)sources:##(hyper-v|WALinuxAgent)} ]]; then
    vt=hyperv
  fi

  local -a rv; rv=()
  local prj
  for prj in ${(ko)projects}; do
    o prj2tp --$vt $prj
    rv+=($reply)
  done
  reply=(${(o)rv})
} # }}}

function subst # {{{
{
  local -r tpl=${(P)1}; shift
  local -A substs; substs=("$@")
  local -r sp='[[:space:]]#'
  local -a match mbegin mend
  REPLY=${tpl//(#b)\%\((${(~kj:|:)substs})\)/${substs[$match[1]]}}
} # }}}

# templates {{{
declare -r smrt_log_template=$'
SUMMARY: PASSED/FAILED

comment:%(COMMENT)

$Author$

Products: %(PRODUCTS)
Category: %(CATEGORY)
Rating: %(RATING)
Packager: %(PACKAGER)
Bugs: %(BUGIDS)
ReviewRequestID: %(SLUG)
Repository: http://download.suse.de/ibs/%(REPOPATH)/
Packages: %(BINARIES)
SRCRPMs: %(SOURCES)
Suggested Test Plan Reviewers: %(REVIEWERS)
%(TESTPLATFORMS)

#############################
Test results by product-arch:
#############################


########################
notes for/by the tester:
########################

%(NOTES)

zypper update log:
------------------
put here the output of the following commands:

export LANG=
zypper lr -puU
zypper refresh
zypper patches | grep :p=%(MPNO)
zypper patches | awk -F "|" \'/:p=%(MPNO)\>/ { print $2; }\' | while read p; do zypper -n install -l -y -t patch $p; done
zypper patches | grep :p=%(MPNO)
'

declare -r notes_kernel='
results from kABI checks:
-------------------------

...
'

declare -r notes_userland='
%(BUGS)

regression tests:
-----------------
List of testcases in Testopia:

https://bugzilla.suse.com/tr_list_cases.cgi?tags_type=anyexact&tags=%(TESTOPIATAGS)
%(HINTS)
(put your details here)

source code change review:
--------------------------
(put here the assessment of the spec + source changes when compared to the latest release)
'

declare -r bugtpl='
%(HEADING)
%(UNDERLINE)

https://bugzilla.suse.com/show_bug.cgi?id=%(BUGID)

REPRODUCER_PRESENT:     YES/NO
REPRODUCER_COVERAGE:    YES/NO
REPRODUCER_APPLICABLE:  YES/NO
REPRODUCER_WORKING:     YES/NO
REPRODUCER_AUTOMATABLE: YES/NO

%(L3INFO)...'
# templates }}}

. $preludedir/smrt.coda.zsh

o $cmdname-main "$@"
