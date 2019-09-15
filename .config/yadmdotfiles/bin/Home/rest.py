#!/usr/bin/python2.7
# coding: UTF-8, break: linux, indent: 4 spaces, lang: python/eng
"""
Local REST-API calls.

This uses https://bugs.cudaops.com/browse/BNNGF-48609 to make requests to
the REST-API from 127.0.0.1 using box credentials.

The commands 'post' and 'get' referr to HTTP POST and GET requests.
<data_or_file> can be a jason data string past via POST or a file
containing such a string (use '-' to read from stdin).

Version: 0.3
Author: Jan Christoph Bischko
Author_EMail: jbischko@barracuda.com
Date: Fri, 06 Oct 2017 14:42:33 +0200 on jbischko-linux
Url: https://stash.cudaops.com/projects/BNNGA/repos/weasel/browse/rest

Usage:
    {__progname__} --help | --version
    {__progname__} get [options] [-v...] <url>...
    {__progname__} post [options] [-v...] <url> <data_or_file>

Options:
    -v --verbose        Specify (multiply) to increase output
    -q --quiet          Print as little as possible
    -r --rest-url=URL   Base URL for the requests [default: https://127.0.0.1:8443/rest/]
    -c --cert=PATH      Path to box certificate [default: /opt/phion/certs/box-cert.pem]
    -k --key=PATH       Path to box keyfile [default: /opt/phion/certs/box-key.pem]
"""
#=======================================================================
from __future__ import print_function, with_statement
from logging import info, debug, error, warning as warn
import sys, os, re, logging, json

fields = ['Version','Author','Author_EMail','Date','Url']
r = '('+ ')|('.join(['?P<'+s+'>(?<=\\n'+s+':).*' for s in fields]) +')'
r = re.compile(r, re.MULTILINE)
fields = dict( ('__'+k.lower()+'__',v.strip()) for di in  [v.groupdict() for v in r.finditer(__doc__)] for k,v in di.iteritems() if v )
globals().update(fields)

__progname__ = os.path.splitext(os.path.basename( __file__ ))[0]
__vstring__ = '{} v{}\nWritten by {},\n{}'.format(__progname__, __version__,
__author__, __date__)

def importupdate(*packs):
    '''Try to update/install packages if import fails.'''
    import importlib
    try:
        import pip
    except:
        import ensurepip
        ensurepip.bootstrap(upgrade=True)
        os.execve(sys.argv[0],sys.argv,os.environ); sys.exit()
    fail = []
    for pack in packs:
        try:
            importlib.import_module(pack)
        except ImportError:
            pip.main(['install', '-U', pack])
            fail.append(pack)
        finally:
            if fail:
                sys.stderr.write(
                    'Install/upgrade these packes manually:'+
                    ' pip, '+ ', '.join(packs)                )
            globals()[pack] = importlib.import_module(pack)

importupdate('requests', 'docopt')

from requests.packages.urllib3.exceptions import InsecureRequestWarning, InsecurePlatformWarning
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)
requests.packages.urllib3.disable_warnings(InsecurePlatformWarning)


def send_get(args):
    for arg in args['<url>']:
        ret = requests.get( arg, **args['--cert'] )
        if args['--verbose']>=0:
            print(ret.text)


def send_post(args):
    indat = args['<data_or_file>']
    try:
        with sys.stdin if indat == '-' else open(indat,'r') as fl:
            data = fl.read()
    except IOError:
        data = indat
    try:
        json.loads(data)
    except ValueError, e:
        error('data I got is not valid json: %s', e)
        sys.exit(1)
    ret = requests.post( args['<url>'][0], data=data, **args['--cert'] )
    if args['--verbose']>=0:
        print(ret.text)

#=======================================================================

def main(args):
    debug('args')
    if args['<url>'][0] in ['post','get']:
        error('choose either post or get!')
        exit(1)

    if( args['get'] ):
        send_get(args)
    elif( args['post'] ):
        send_post(args)


if __name__ == '__main__':
    args = docopt.docopt(__doc__.format(**locals()), version=__vstring__)
    args['--cert'] = {'verify':False, 'cert':(args['--cert'],args['--key'])}
    for it, arg in enumerate(args['<url>']):
        args['<url>'][it] = args['--rest-url']+arg
    if args['--quiet']: args['--verbose'] = -1
    logging.basicConfig(
        level   = logging.ERROR - int(args['--verbose'])*10,
        format  = '[%(levelname)-7.7s] (%(asctime)s '
                  '%(filename)s:%(lineno)s) %(message)s',
        datefmt = '%y%m%d %H:%M'   #, stream=, mode=, filename=
    )
    main(args)
