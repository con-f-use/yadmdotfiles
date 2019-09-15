#!/usr/bin/python
# Some finer points about logging.
#
# see: https://docs.python.org/3/howto/logging-cookbook.html

import logging
logging.basicConfig()
logging.basicConfig(level='INFO')  # catch: only first call (line above) will have effect
log = logging.getLogger()
log.setLevel(logging.INFO)

try:
    raise ValueError('test')
except ValueError:
    log.exception('oh noes!')  # exec_info=True
    log.warning('warn')
    log.warning('warn exec', exc_info=True)
    try:
        log.info('warn stack >3.2 only', stack_info=True)  
    except TypeError as e:
        log.exception('stack_info only exists in versions >3.2')


