#!/usr/bin/env nix-shell
#!nix-shell -i python -p python27Packages.beautifulsoup4 python27Packages.docopt python27Packages.pyperclip python27Packages.html5-parser python27Packages.urllib3

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

# =======================================================================

from __future__ import division, print_function, unicode_literals
from logging import info, debug, error, warning as warn
import sys, os, re, logging, time, string
import pyperclip as clp
from docopt import docopt
from bs4 import BeautifulSoup
import multiprocessing

try:  # Python 2.6-2.7
    from HTMLParser import HTMLParser
except ImportError:  # Python 3
    from html.parser import HTMLParser
try:
    from urllib2 import Request, urlopen
except ImportError:
    from urllib.request import Request, urlopen
try:
    from urlparse import urlparse
except ImportError:
    from urllib.parse import urlparse

from multiprocessing.pool import ThreadPool as Pool

# import time

# =======================================================================

reqhdr = {
    'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.11 '
    '(KHTML, like Gecko) Chrome/23.0.1271.64 Safari/537.11',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    'Accept-Charset': 'ISO-8859-1,utf-8;q=0.7,*;q=0.3',
    'Accept-Encoding': 'none',
    'Accept-Language': 'en-US,en;q=0.8',
    'Connection': 'keep-alive',
}


def get_urllist(args):
    """Get HTTP(S) URLs from standard input, files or pass them through"""
    for arg in args:
        try:
            with sys.stdin if arg == '-' else open(arg, 'r') as urllst:
                for line in urllst:
                    line = line.strip()
                    if line.startswith('http'):
                        yield line
        except IOError as e:
            if arg.startswith('http'):
                yield arg
            warn("IOError while reading file '%s': %s", arg, e)


def url_request(url):
    """Retry getting the provided url."""
    for _ in range(5):
        try:
            urlhandle = urlopen(Request(url, headers=reqhdr))
            break
        except Exception:
            typ, val, tb = sys.exc_info()
            warn("Exception '%s' at '%s'. Retrying...", val, url)
            time.sleep(5)
    else:
        raise Exception("Failed after 5 retries")
    return urlhandle


def save_image(img):
    """Retreive image, append number and save it to a folder"""
    url, nmg, nm = img
    try:
        imgRequest = url_request(url)
    except:
        print('x')
        return None
    imgData = imgRequest.read()
    with open('{}/{}-{:0>3}.jpg'.format(nm, nm, nmg), 'wb') as output:
        output.write(imgData)
    print('.', end='')
    sys.stdout.flush()
    return url


def get_pages(domain, galsoup):
    """Get gallery pages from parsed first page."""
    lst = galsoup.findAll('a', text='Last') or galsoup.findAll('a', text='Random')
    lst = lst[0].get('href')
    lst, nParts = re.match(r'(.*)/(\d+?)$', lst).group(1, 2)
    makeabs = lambda x: domain + lst + '/' + str(x + 1)
    return map(makeabs, range(int(nParts)))


def get_imgurls(pages):
    """Get image urls from list of partial pages"""
    for url in pages:
        urlhdl = url_request(url)
        galsp = BeautifulSoup(urlhdl.read(), 'html.parser')
        imgs = galsp.findAll('a', text='Image Only')
        for img in imgs:
            yield img.get('href')


def walk_inputs(args):
    """Retrieve images from galaries"""
    pool = Pool(int(args['--processes']))
    print('Getting Image List...')
    for gal in get_urllist(args['ARGS']):
        urlhandle = url_request(gal)
        galsoup = BeautifulSoup(urlhandle.read(), 'html.parser')
        galtitle = galsoup.title.string
        domain = '{uri.scheme}://{uri.netloc}/'.format(uri=urlparse(gal))
        newpath = galtitle.replace('&amp;', 'and ')
        pages = get_pages(domain, galsoup)
        targets = [(v, i + 1, newpath) for i, v in enumerate(get_imgurls(pages))]
        if len(targets) < 1:
            warn('no images for: ' + newpath)
            continue
        if not os.path.exists(newpath):
            os.makedirs(newpath)
        print(len(targets), 'images found.')
        if not args['--no-download']:
            print('Downloading images...')
            for imgurl in pool.imap_unordered(save_image, targets):
                debug(imgurl)


if __name__ == '__main__':
    progname = os.path.splitext(os.path.basename(__file__))[0]
    vstring = (
        ' v0.7\nWritten by confus\n' '(Sun Aug 21 23:20:09 CEST 2016) on confusion'
    )
    args = docopt(__doc__.format(**locals()), version=progname + vstring)
    logging.basicConfig(
        level=logging.ERROR - int(args['--verbose']) * 10,
        format='[%(levelname)-7.7s] (%(asctime)s '
        '%(filename)s:%(lineno)s) %(message)s',
        datefmt='%y%m%d %H:%M',  # , stream=, mode=, filename=
    )
    if args['--clipboard']:
        args['ARGS'].extend(clp.paste().splitlines())
    walk_inputs(args)
