#!/usr/bin/env python
import logging

logging.warning("Warnings are printed without config.")
logging.info("Nope")

# Execute: Only prints warning, uses fallback handler



logging.basicConfig(
    level=logging.DEBUG,
    format="[%(name)s|%(levelname)-3.3s]: %(message)s"
) # basicConfig is shitty!
logging.warning("WARNING")  # doesn't print anything if you have...
logging.info("Info")        #...an ealier logging call!
logging.debug("Debug")      #...like in line 4
# Execute: still only prints "WARNING" because logging calls before

print(
    f"{logging.Logger.root.manager.loggerDict = }\n"
    f"{logging.getLogger().handlers = }\n"
    f"{logging.getLogger().level = }"
)


import libra
libra.log.warning("test from outside of libra")
libra.log.setLevel(logging.ERROR)  # don't pass instances, use getLogger
logging.getLogger("libra").setLevel(logging.ERROR)
libra.log.warning("test2 from outside of libra")
