import atexit
import tomllib
import logging
import logging.config
import logging.handlers
import pathlib
import time

log = logging.getLogger("my_app")


def setup_logging():
    logging.Formatter.converter = time.gmtime
    config_file = pathlib.Path("logging_conf.toml")
    with open(config_file, "rb") as fh:
        config = tomllib.load(fh)

    logging.config.dictConfig(config)

    # The queue handler is so that IO ops (or networking) does not block
    # the main application when log functions are called.
    if queue_handler := logging.getHandlerByName("queue_handler"):
        queue_handler.listener.start()
        atexit.register(queue_handler.listener.stop)


def main():
    setup_logging()
    logging.basicConfig(level="INFO")
    log.debug("DEBUG", extra={"x": "hello"})
    log.info("INFO")
    log.warning("WARNING")
    log.error("ERROR")
    log.critical("CRITICAL")
    try:
        1 / 0
    except ZeroDivisionError:
        log.exception("EXCEPTION")


if __name__ == "__main__":
    main()
