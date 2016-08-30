# vim: ft=python sw=2 sts=2 et fdm=marker cms=\ #\ %s

import re
import subprocess
import tempfile
import xml.sax.saxutils as saxutils
import xmlrpc.client as xmlrpclib

class Display(object):
  stati = {
    1: 'proposed',
    2: 'confirmed',
    3: 'disabled',
  }

  def __init__(dsp, println = print, bugzilla = None):
    dsp.println = println
    dsp.bugzilla = bugzilla

  def create(dsp, case_id):
    dsp.println('created testcase %s/tr_show_case.cgi?case_id=%s' % (
      dsp.bugzilla,
      case_id,
    ))

  def list(dsp, case_id, summary, isautomated, **crap):
    dsp.println('{summary:40}: {automated}'.format(
      summary = summary,
      automated = 'automated' if isautomated else 'manual'
    ))
    dsp.println('{}/tr_show_case.cgi?case_id={}'.format(dsp.bugzilla, case_id))
    dsp.println()

  def show(dsp, case_id, summary, case_status_id, isautomated, action, requirement = None, setup = None, breakdown = None, effect = None, **crap):
    dsp.println('Testcase summary: %s' % (summary))
    dsp.println('Testcase URL: %s' % ('{}/tr_show_case.cgi?case_id={}'.format(dsp.bugzilla, case_id)))
    dsp.println('Testcase automated: %s' % ('yes' if isautomated else 'no'))
    dsp.println('Testcase status: %s' % (dsp.stati[case_status_id]))
    dsp.println('Testcase requirements: %s' % (requirement))
    if setup:
      dsp.println('Testcase setup:\n%s' % unhtmlize(setup))
    if breakdown:
      dsp.println('Testcase breakdown:\n%s' % unhtmlize(breakdown))
    dsp.println('Testcase actions:\n%s' % unhtmlize(action))
    if effect:
      dsp.println('Testcase effect:\n%s' % unhtmlize(effect))


class BugzillaRPC(object):
  """Connector to the Bugzilla XMLRPC interface

  Interface to the Bugzilla XMLRPC API documented at
  http://www.bugzilla.org/docs/4.0/en/html/api/Bugzilla/WebService.html

  Interface to the Testopia XMLRPC API documented at
  https://wiki.mozilla.org/Testopia:Documentation:XMLRPC

  """

  def __init__(self, url):
    self.proxy = xmlrpclib.ServerProxy(url);

  def query_interface(self, service, *query):
    return getattr(self.proxy, service)(*query)


def unhtmlize(s):
  s = str(s) \
    .replace('<br>', '\n') \
    .replace('</span>', '\n') \
    .replace('</div>', '\n') \
    .replace('&nbsp;', ' ')

  s = re.sub('<[^>]*>', '', s)

  try:
      return saxutils.unescape(s)
  except Exception:
      return text

def htmlize(text):
  try:
    return saxutils.escape(text, {'|br|':'<br>'})
  except Exception:
    return text

def edit_text(text):
  editor = os.environ.get('VISUAL', os.environ.get('EDITOR', 'vi'))
  tmpfile = tempfile.NamedTemporaryFile()

  with open(tmpfile.name, 'w') as tmp:
    tmp.write(text)

  try:
    subprocess.check_call((editor, tmpfile.name))
  except subprocess.CalledProcessError as e:
    del tmpfile
    return e, None

  with open(tmpfile.name, 'r') as tmp:
    text = tmp.read().strip('\n')

  del tmpfile
  return None, text


edit_template = """
package: {package}
summary:
sle-version: {sle_version}
status: proposed
automated: no
requirement:
text/setup:
text/breakdown:
text/action:
text/effect:
""".strip()


class TestopiaFrontend(object):
  plans = {
     '9': '251',
    '10': '263,351',
    '11': '2672',
    '12': '4809'
  }
  stati = dict(
    proposed  = '1',
    confirmed = '2',
    disabled  = '3',
  )
  def __init__(tf, api, display):
    tf.api     = api
    tf.display = display

  def do_create(tf, package):
    fields = [line.partition(':')[0] for line in edit_template.splitlines()]

    proposal = edit_template.format(
      package = package,
      sle_version = max(tf.plans.keys())
    )
    err, result = edit_text(proposal)
    if (err):
      print("editor failed: %s" % err, file = sys.stderr)
      return

    if result == proposal:
      print('testcase was not modified. not uploading.', file = sys.stderr)
      return

    sresult = result.replace('\n', '|br|')

    for field in fields:
      sresult = sresult.replace('|br|%s:' % field, '\n%s:' % field)

    values = dict()
    result = sresult.split('\n')

    for line in result:
      key, _, val = line.partition(':')
      key, val = key.strip(), val.strip()
      if key == 'automated':
          key = 'isautomated'
          val = str(int(val == 'yes'))
      elif key == 'package':
        key = 'tags'
        val = 'packagename_{name},testcase_{name}'.format(name = val.strip())
      elif key == 'sle-version':
        key = 'plans'
        val = tf.plans[val]
      elif key == 'status':
        key = 'case_status_id'
        val = tf.stati[val]
      elif key.startswith('text/'):
        key = key.replace('text/', '')

      values[key] = htmlize(val.strip())

    tc = dict(
      status = 2,
      category = 2919,
      priority = 6,
    )

    tc.update(values)

    case_id = tf.api.query_interface('TestCase.create', tc)
    tf.display.create(case_id)

  def do_show(tf, tcid):
    response = tf.api.query_interface('TestCase.get', tcid)
    # prevent conflicts between response['version'] vs response['text']['version']
    outputs = dict(**response['text'])
    outputs.update(**response)
    tf.display.show(**outputs)

  def do_list(tf, *pkgs):
    response = tf.api.query_interface('TestCase.list', dict(
      tags = ','.join(['packagename_%s,testcase_%s' % (pkg, pkg) for pkg in pkgs]),
      tags_type = 'anyexact',
      plan_id = 2672
    ))
    for tc in response:
      tf.display.list(**tc)


if __name__ == '__main__':
    import os, sys
    url  = os.environ['testopia_url']
    user = os.environ['testopia_user']
    pasw = os.environ['testopia_pass']

    cmd  = sys.argv[1]
    args = sys.argv[2:]

    tf = TestopiaFrontend(
      api = BugzillaRPC(url.replace('://', '://%s:%s@' % (user, pasw))),
      display = Display(bugzilla = 'https://bugzilla.novell.com'),
    )

    meth = 'do_%s' % cmd
    getattr(tf, meth)(*args)
