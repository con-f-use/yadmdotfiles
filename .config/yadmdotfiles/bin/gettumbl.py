#!/usr/bin/python
# coding: UTF-8, break: linux, indent: 4 spaces, lang: python/eng
"""
Download images from given URL files ('-' for standard input) or URLs.

Usage:
    {progname} --help | --version
    {progname} [options] [-v...] (ARGS | -c)

Options:
    -v --verbose           Specify (multiply) to increase status reporting
    -c --clipboard         Get inputs from clipboard and command line args
"""

#=======================================================================

from __future__ import division, print_function, unicode_literals
from logging import info, debug, error, warning as warn
import sys, os, re, logging, string
from docopt import docopt
from BeautifulSoup import BeautifulSoup
from pprint import pprint

#=======================================================================

if __name__ == '__main__':
    progname = os.path.splitext(os.path.basename( __file__ ))[0]
    vstring = (' v0.1\nWritten by confus\n'
               '(Sun Mar 26 23:20:09 CEST 2017) on confusion' )
    args = docopt(__doc__.format(**locals()), version=progname+vstring)
    logging.basicConfig(
        level   = logging.ERROR - int(args['--verbose'])*10,
        format  = '[%(levelname)-7.7s] (%(asctime)s '
                  '%(filename)s:%(lineno)s) %(message)s',
        datefmt = '%y%m%d %H:%M'   #, stream=, mode=, filename=
    )
    if args['--clipboard']: args['ARGS'].extend( clp.paste().splitlines() )
    with open(args['ARGS'][0]) as fl:
        galsoup = BeautifulSoup( fl )
    imgs = galsoup.findAll('img',{'class':'rb-img'})
    for img in imgs:
        print( img['src'] )
    sys.stderr.write('cat filename | wget -nc --content-disposition -i -\n')