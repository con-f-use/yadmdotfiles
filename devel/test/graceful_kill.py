#!/usr/bin/python

from __future__ import print_function
import time
import signal

class GracefulKiller:
    kill_now = False
    def __init__(self):
        # These take precedence over a KeyboardInterrup exception!
        signal.signal(signal.SIGINT,  self.exit_gracefully)
        signal.signal(signal.SIGTERM, self.exit_gracefully)

    def exit_gracefully(self, signum, frame):
        print('Will exit gracefully...')
        print('\tsignum:', signum, '; frame:', frame)
        self.kill_now = True
        cleanup()
        #exit(0)


def cleanup():
    print('Cleaning up...')


def main(killer):
    while True:
        time.sleep(1)
        print("doing something in a loop ...")
        if killer.kill_now:
            break


if __name__ == '__main__':
    killer = GracefulKiller()

    try:
        main(killer)
    except KeyboardInterrupt:
        print('This will never be seen!'
              '`exit_gracefully()` is invoked instead.')

    print('End of the program. I was killed gracefully :)')
