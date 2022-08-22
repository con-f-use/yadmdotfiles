import logging

log = logging.getLogger(__name__)

def log_something():
    print("\n***usual - given no config, should use logging.lastResort handler:")
    log.warning("log:warning")
    log.info("log:info - if you see this we have config")
    log.debug("log:debug - never seen with the libhandler, because its handler has level 'INFO'!")

    print("\n***no last resort:")
    _orig_last_resort = logging.lastResort
    logging.lastResort = None
    log.warning("log:warning")
    log.info("log:info - if you see this we have config")
    log.debug("log:debug - never seen with the libhandler, because its handler has level 'INFO'!")
    logging.lastResort = _orig_last_resort

    print("\n***propagate off:")
    log.propagate = False
    log.warning("log:warning")
    log.info("log:info - if you see this we have config")
    log.debug("log:debug - never seen with the libhandler, because its handler has level 'INFO'!")
    log.propagate = True

    print("\n***library loger level to INFO:")
    log.setLevel(logging.INFO)
    log.warning("log:warning")
    log.info("log:info - we should not see a debug from librarlylogger or rootlogger next, because it does not propagate below its level")
    log.debug("log:debug - never seen with the libhandler, because its handler has level 'INFO'!")
    log.setLevel(logging.NOTSET)

    print("\n**NullHandler:")
    nullhandler = logging.NullHandler()
    log.addHandler(nullhandler)
    log.warning("log:warning")
    log.info("log:info - if you see this we have config")
    log.debug("log:debug - never seen with the libhandler, because its handler has level 'INFO'!")
    log.removeHandler(nullhandler)
