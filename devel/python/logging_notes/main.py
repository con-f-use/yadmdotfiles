#!/usr/bin/env python
"""Demonstrates a few "behaviors" of the logging module, that might
or might not be surprising to some.

Run with: python main.py <optional_argument>"""


import logging, sys
import library

if __name__ == "__main__":
    if len(sys.argv) > 1:
        logging.warning(
            "!callig logging.<logfunction>, does logging.basicConfig,\n"
            " ...which on old python versions adds a handler\n"
            " ...and then we log everything twice!"
        )

    print("=== WITHOUT CONFIG ===")
    library.log_something()

    print("\n\n\n=== WITH ROOT CONFIG ===")
    root = logging.getLogger()
    root.setLevel(logging.DEBUG)
    roothandler = logging.StreamHandler()
    roothandler.setFormatter(logging.Formatter("[ROOTHANDLER|%(levelname)-3.3s](%(filename)s:%(lineno)4s): %(message)s", datefmt="%y%m%d %H:%M"))
    root.addHandler(roothandler)
    library.log_something()
    logging.warning("bla2")

    print(f"\n\n\n=== WITH {library.__name__.upper()} CONFIG ===")
    liblog = logging.getLogger(library.__name__)
    libhandler = logging.StreamHandler()
    libhandler.setFormatter(logging.Formatter("[ LIBHANDLER|%(levelname)s|%(module)s]: %(message)s", datefmt="%y%m%d %H:%M"))
    libhandler.setLevel(logging.INFO)
    liblog.addHandler(libhandler)
    library.log_something()

