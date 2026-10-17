#!/usr/bin/env python


import logging, os, sys
from logging import info, debug, error, warning as warn

from math import sqrt, pi

logcfg = dict(
    level=logging.DEBUG,
    format="[%(levelname)-3.3s](%(lineno)4s:%(filename)s): %(message)s",
    datefmt="%y.%m.%d %H:%M",
    stream=sys.stderr,
)
logging.basicConfig(**logcfg)
warn("Using startup file: '%s'", __file__)

# Aliases for copy&pasting json
try:
    import __builtin__
except:
    import builtins as __builtin__
__builtin__.true = True
__builtin__.false = False
__builtin__.null = None

# Don't be smartass, exit!
type(exit).__repr__ = lambda s: exit()

from pathlib import Path as P
import math, json, subprocess, random, stat, re, gzip
from pprint import pprint, pformat
