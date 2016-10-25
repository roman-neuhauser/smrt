smrt fetch: traces
==================

setup::

  $ . $TESTROOT/setup

  $ smrt_chatty+=(
  >   'bsc%*'
  >   'cd%*'
  >   'curl%*'
  >   'fetch-*'
  >   'mkdir%*'
  >   'redir%*'
  >   'xml%*'
  > )

  $ slug=SUSE:Maintenance:1302:87808


ReviewRequestID::

  $ smrt --issuer SUSE fetch ${slug##*:}
  o fetch-request-xml 87808
  o redir -1 * bs-fetch-request 87808 (glob)
  o bsc /request/87808
  o curl -Sfns https://api.example.com/request/87808
  o xml sel -T -t -m //action/source -v @project --nl /?*/?* (glob)
  o mkdir -p SUSE:Maintenance:1302:87808
  o cd SUSE:Maintenance:1302:87808
  Downloading SUSE:Maintenance:1302:87808 metadata
  o redir -1 reviewers curl -Sfs *://*/reviewers (glob)
  o curl -Sfs *://* (glob)
  o redir -1 productdefs.pm curl -Sfs file://*/t/fixtures/productdefs.pm (glob)
  o curl -Sfs *://* (glob)
  o redir -1 productdefs perl */smrt.tps.pl ./productdefs.pm (glob)
  o redir -1 testplatforms.pm curl -Sfs file://*/t/fixtures/testplatforms.pm (glob)
  o curl -Sfs *://* (glob)
  o redir -1 testplatforms perl */smrt.tps.pl ./testplatforms.pm (glob)
  o redir -1 request.xml bs-fetch-request 87808
  o bsc /request/87808
  o curl -Sfns https://api.example.com/request/87808
  o redir -1 request.diff.xml bs-fetch-request-diff 87808
  o bsc -d 'cmd=diff&view=xml' /request/87808
  o curl -Sfns -d 'cmd=diff&view=xml' https://api.example.com/request/87808
  o redir -1 patchinfo.xml bs-fetch-patchinfo SUSE:Maintenance:1302
  o bsc /source/SUSE:Maintenance:1302/patchinfo/_patchinfo
  o curl -Sfns https://api.example.com/source/SUSE:Maintenance:1302/patchinfo/_patchinfo
  o redir -1 packages.xml bs-fetch-packages SUSE:Maintenance:1302
  o bsc -d match=project=\'SUSE:Maintenance:1302\''&limit=0' /search/published/binary/id
  o curl -Sfns -d match=project=\'SUSE:Maintenance:1302\''&limit=0' https://api.example.com/search/published/binary/id
  o redir -1 project.xml bs-fetch-project SUSE:Maintenance:1302
  o bsc /source/SUSE:Maintenance:1302/_meta
  o curl -Sfns https://api.example.com/source/SUSE:Maintenance:1302/_meta
  o redir -1 repositories.xml bs-fetch-repos SUSE:Maintenance:1302
  o bsc /build/SUSE:Maintenance:1302/_result
  o curl -Sfns https://api.example.com/build/SUSE:Maintenance:1302/_result
  o redir -1 patchinfo fetch-patchinfo patchinfo.xml
  o fetch-patchinfo patchinfo.xml
  o redir -0 patchinfo.xml -1 patchinfo.tmp xml-ls-patchinfo
  o fetch-info person farmer
  o redir -1 person-farmer.xml bs-fetch-info person farmer
  o bsc /person/farmer
  o curl -Sfns https://api.example.com/person/farmer
  o xml sel -T -t -v /person/email --nl person-farmer.xml
  o redir -1 patchinfo print -f '%s %s\n' category security packager farmer@example.com rating moderate
  o redir -0 project.xml -1 repos-sources xml-ls-repos standard
  o redir -0 project.xml -1 repos-binaries xml-ls-repos update
  o redir -1 sources xml-ls-released-sources packages.xml repos-binaries
  o xml sel -T -t -m '//binary[@arch="src" or @arch="nosrc"]' -v @repository -o ' ' -v @name -o ' ' -v @version -o ' ' -v @release --nl packages.xml
  o redir -1 binaries xml-ls-released-binaries packages.xml repos-binaries
  o xml sel -T -t -m '//binary[@arch!="src" and @arch!="nosrc"]' -v @repository -o ' ' -v @arch -o ' ' -v @name -o ' ' -v @version -o ' ' -v @release -o ' ' -v @filepath --nl packages.xml
  o redir -1 maintainers fetch-package-maintainers sources
  o fetch-package-maintainers sources
  o redir -1 owners-rsync.xml bs-fetch-maintainers rsync
  o bsc -d 'filter=bugowner&binary=rsync' /search/owner
  o curl -Sfns -d 'filter=bugowner&binary=rsync' https://api.example.com/search/owner
  o xml sel -T -t -m '//owner/*[name() = "group" or name() = "person"]' -v 'name()' -o ' ' -v @name --nl owners-rsync.xml
  o fetch-info person farmer
  o xml sel -T -t -v /person/email --nl person-farmer.xml
  o redir -1 request.diff xml-xform-request-diff request.diff.xml
  o xml sel -T -t --if '0 = count(/request/action[source/@package != "patchinfo"]/sourcediff/files/file[diff])' -o empty -n --else -m '/request/action[source/@package != "patchinfo"]/sourcediff/files/file[diff]' -o 'diff --bs ' -v ../../old/@package -o / --if '@state="added"' -v new/@name --else -v old/@name --break -o ' ' -v ../../new/@package -o / --if '@state="deleted"' -v old/@name --else -v new/@name --break --nl -o '--- ' --if '@state="added"' -o /dev/null --else -v ../../old/@package -o / -v old/@name --break --nl -o '+++ ' --if '@state="deleted"' -o /dev/null --else -v ../../new/@package -o / -v new/@name --break --nl -v diff --break --break request.diff.xml
  o redir -1 issues xml-ls-bugs patchinfo.xml
  o xml sel -T -t -m '/patchinfo/issue[@tracker="bnc"]' -v @tracker -v @id -o ' ' -v . --nl patchinfo.xml
  o redir -1 l3s.xml sg-fetch-l3s 898513 900914 915410 922710
  o redir -1 l3s.xml.tmp curl -Sfs -H 'Accept: application/xml' -H 'Authorization: ApiKey smrt:mtui' 'http://l3db.example.org/api/1/raederwerk/?incident__bug_id__in=898513,900914,915410,922710'
  o curl -Sfs -H 'Accept: application/xml' -H 'Authorization: ApiKey smrt:mtui' 'http://l3db.example.org/api/1/raederwerk/?incident__bug_id__in=898513,900914,915410,922710'
  o redir -1 l3s.xml xml fo l3s.xml.tmp
  o xml fo l3s.xml.tmp
  o redir -0 l3s.xml xml-xform-l3s
  o redir -1 l3s.tmp xml sel -T -t -m /response/objects/object -o bug_id= -o bnc -v bug_id -o \x01 -o incident= -v incident -o \x01 -o summary= -v summary -o \x01 -o probability= -v probability -o \x01 -o impact= -v outcome -o \x01 -o patch= -v patch -o \x01 -o reproducer= -v reproducer -o \x01 -o requires_3dparty= -v requires_thirdparty -o \x01 (esc)
  o xml sel -T -t -m /response/objects/object -o bug_id= -o bnc -v bug_id -o \x01 -o incident= -v incident -o \x01 -o summary= -v summary -o \x01 -o probability= -v probability -o \x01 -o impact= -v outcome -o \x01 -o patch= -v patch -o \x01 -o reproducer= -v reproducer -o \x01 -o requires_3dparty= -v requires_thirdparty -o \x01 (esc)
  o redir -1 allarchtrigger curl -Sfs file:///*/packages-to-be-tested-on-all-archs (glob)
  o curl -Sfs file:///*/packages-to-be-tested-on-all-archs (glob)
  o redir -1 minimaltrigger curl -Sfs file:///*/packages-to-be-tested-on-minimal-systems (glob)
  o curl -Sfs file:///*/packages-to-be-tested-on-minimal-systems (glob)
  o redir -1 slug print SUSE:Maintenance:1302:87808
