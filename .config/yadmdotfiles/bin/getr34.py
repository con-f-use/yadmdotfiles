#!/usr/bin/python2
# coding: UTF-8, break: linux, indent: 4 spaces, lang: python/eng
"""
Download images from given URL files ('-' for standard input) or URLs.

Usage:
    {progname} --help | --version
    {progname} [options] [-v...] (ARGS... | -c [ARGS...])

Options:
    -v --verbose           Specify (multiply) to increase status reporting
    -n --no-download       Simulate downloading without creating any files
    -c --clipboard         Get inputs from clipboard and command line args
    -p --processes=<int>   Number of processes for downlaod [default: 15]

Examples:
    Get URLs or paths to files containing URL lists from clipboard.
        {progname} -c

    Get images in specified gallery and downlad them sequentially.
        {progname} -p 1 'http://myurl.com/some/gallery'

    Get get gallery URLs from another command's output and a file.
        anothercommand | {progname} myurls.txt -

ToDo: Better Error Handling!
"""

#=======================================================================

from __future__ import division, print_function, unicode_literals
from logging import info, debug, error, warning as warn
import sys, os, re, logging, time, string
import pyperclip as clp
from docopt import docopt
from bs4 import BeautifulSoup
import multiprocessing
try: # Python 2.6-2.7
    from HTMLParser  import HTMLParser
except ImportError: # Python 3
    from html.parser import HTMLParser
try:
    from urllib2 import Request, urlopen
except ImportError:
    from urllib.request import Request, urlopen
try:
    from urlparse import urlparse
except ImportError:
    from urllib.parse import urlparse

# from __future__ import division, print_function, unicode_literals
# from logging import info, debug, error, warning as warn
# import sys, os, re, logging, string, functools, urllib2
# import pyperclip as clp
# from docopt import docopt
# from bs4 import BeautifulSoup
# from urlparse import urlparse
from multiprocessing.pool import ThreadPool as Pool
# import time

#=======================================================================

#urlreq = functools.partial(Request, headers={
reqhdr = {
  'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.11 '
                '(KHTML, like Gecko) Chrome/23.0.1271.64 Safari/537.11',
  'Accept':'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
  'Accept-Charset': 'ISO-8859-1,utf-8;q=0.7,*;q=0.3',
  'Accept-Encoding': 'none',
  'Accept-Language': 'en-US,en;q=0.8',
  'Connection': 'keep-alive'
}
#})
# q = multiprocessing.JoinableQueue()
# h = HTMLParser()

def get_urllist(args):
    '''Get HTTP(S) URLs from standard input, files or pass them through'''
    for arg in args:
        try:
            with sys.stdin if arg == '-' else open(arg,'r') as urllst:
                for line in urllst:
                    line = string.strip(line)
                    if line.startswith('http'): yield line
        except IOError as e:
            if arg.startswith('http'): yield arg
            warn("IOError while reading file '%s': %s", arg, e)


# def url_request(url):
#         for _ in range(5):
#             try:
#                 urlhandle = urllib2.urlopen( urlreq( url ) )
#                 break
#             except Exception:
#                 typ, val, tb = sys.exc_info()
#                 warn('Exception... retrying.')
#                 time.sleep(5)
#         else:
#             raise Exception("Failed after 5 retries")
#         return urlhandle

def url_request(url):
    '''Retry getting the provided url.'''
    for _ in range(5):
        try:
            urlhandle = urlopen(
                Request(url, headers=reqhdr)
            )
            break
        except Exception:
            typ, val, tb = sys.exc_info()
            warn("Exception '%s' at '%s'. Retrying...", val, url)
            time.sleep(5)
    else:
        raise Exception("Failed after 5 retries")
    return urlhandle


def save_image(img):
    '''Retreive image, append number and save it to a folder'''
    url, nmg, nm = img
    try:
        imgRequest = url_request(url)
    except:
        print('x')
        return None
    imgData = imgRequest.read()
    fname = nm +'/'+ nm +'-{:0>3}.jpg'
    with open(fname.format(nmg),'wb') as output:
        output.write(imgData)
    print('.', end='')
    sys.stdout.flush()
    return url


def walk_inputs(args):
    '''Retrieve images from galaries'''
    pool = Pool( int(args['--processes']) )
    print('Getting Image List...')
    for it, gal in enumerate( get_urllist(args['ARGS']) ):
        urlhandle = url_request(gal)
        galsoup = BeautifulSoup( urlhandle.read(), 'html.parser' )
        galtitle = galsoup.title.string
        domain = '{uri.scheme}://{uri.netloc}/'.format( uri=urlparse(gal) )
        newpath = string.replace(galtitle, '&amp;', 'and ')
        lst = galsoup.findAll('a', text='Last')[0].get('href')
        nParts = int( re.sub(r'^.*/(\d+?)$', r'\1', lst) )
        print(it, ':', newpath)
        targets = []
        for part in range(1,nParts+1):
            print("\t", part, 'of', nParts)
            parturl = domain + re.sub(r'/(\d+?)$', '/'+str(part), lst)
            urlhdl = url_request( parturl )
            print("\t URL:", parturl)
            galsp = BeautifulSoup( urlhdl.read(), 'html.parser' )
            imgs = galsp.findAll('a', text='Image Only')
            for img in imgs:
                targets.append(
                    (
                        img.get('href'),
                        len(targets)+1,
                        newpath
                    )
                )
                # newpat stuff here!
                # if not args['--no-download']:
                #     targets.append( pool.apply_async( save_images (
                #         img.parent.get('href'),
                #         len(targets)+1,
                #         newpath
                #                   )                 )             )
                # for res in targets:
                #     try:
                #         print( res.get(timeout=10) )
                #     except: # TimeoutError in multiprocessing module
                #         warn("Timeout!")
        if len(imgs)<1: warn('no images for: '+ newpath); continue
        if not os.path.exists(newpath):
            os.makedirs(newpath)
        print( len(targets), 'images found.' )
        if not args['--no-download']:
            print('Downloading images...')
            for result in pool.imap_unordered(save_image, targets):
                print(result)


if __name__ == '__main__':
    progname = os.path.splitext(os.path.basename( __file__ ))[0]
    vstring = (' v0.6\nWritten by confus\n'
               '(Sun Aug 21 23:20:09 CEST 2016) on confusion' )
    args = docopt(__doc__.format(**locals()), version=progname+vstring)
    logging.basicConfig(
        level   = logging.ERROR - int(args['--verbose'])*10,
        format  = '[%(levelname)-7.7s] (%(asctime)s '
                  '%(filename)s:%(lineno)s) %(message)s',
        datefmt = '%y%m%d %H:%M'   #, stream=, mode=, filename=
    )
    if args['--clipboard']: args['ARGS'].extend( clp.paste().splitlines() )
    walk_inputs(args)

































# imgpgs = galsoup.findAll("a",{"href":re.compile("/picture/")})
# for pg in imgpgs:
#     req = urllib2.Request( domain + pg["href"], headers=hdr )
#     pgsoup = BeautifulSoup( urllib2.urlopen(req).read() )
#     img = pgsoup.find("input",{"id":"imageName",value:True})
#     dir = pgsoup.find("input",{"id":"imageDir",value:True})
#
# def save_image(img, nmg, newpath):
#     imgRequest = urlreq(img)
#     imgData = urllib2.urlopen(imgRequest).read()
#     idx = ""
#     fname = newpath +'/'+ newpath +'-{:0>3}.jpg'
#     while os.path.exists( fname.format(idx) ):
#         idx = int(idx or "0") + 1
#     with open(fname.format(idx),'wb') as output:
#         output.write(imgData)
