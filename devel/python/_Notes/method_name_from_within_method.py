#!/usr/bin/python
from __future__ import print_function
import inspect

def foo():
   print( inspect.stack()[0][3] ) # Also works for decorated methods
   print( inspect.currentframe().f_code.co_name )

foo()

