#!/usr/bin/python
import signal
from distutils.util import strtobool

signal.signal(signal.SIGALRM, exit)
signal.alarm(5)
if strtobool(raw_input('Answer within 5 seconds: Do you agree? [y/N] ')):
    print('you agreed!')
signal.alarm(0)

from threading import Timer

timeout = 10
t = Timer(timeout, print, ['Sorry, times up'])
t.start()
prompt = "You have %d seconds to choose the correct answer...\n" % timeout
answer = input(prompt)
t.cancel()
