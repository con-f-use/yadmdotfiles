#!/usr/bin/env python3

import sys, os
from pprint import pprint, pformat

def main(args=None):
    if args is None:
        args = sys.argv[1:]

    ret = {}
    for ln in sys.stdin:
        if not ln.strip():
            continue
        ln = ln.split()

        fl = ln[-1]
        if fl not in ret:
            ret[fl] = list(ln) + [1]
        else:
            ret[fl][-1] += 1

    hist = reversed(sorted([f'{v[-1]:04d}  --  {k}' for k,v in ret.items()]))

    pprint(list(hist)[:20])


if __name__ == '__main__':
    sys.exit( main() )

