#!/usr/bin/python

from __future__ import print_function, division
import multiprocessing, time, sys
q = multiprocessing.JoinableQueue()

def real_worker(num):
    time.sleep(5%num)
    print('wrk'+ str(num), end='')
    sys.stdout.flush()


def worker_wrapper():
    '''Handle worker in the global queue.'''
    for item in iter( q.get, None ):
        real_worker(item)
        q.task_done()
    q.task_done()


procs = []
for i in range(4):
    procs.append( multiprocessing.Process(target=worker_wrapper) )
    procs[-1].daemon = True
    procs[-1].start()

# Add stuff to queue
data = range(1,70)
for datum in data: # will start working once the first item is added
    q.put( datum )


# do something else in the meantime
time.sleep(5)
print('\nsomething else')

# Add more to queue
for datum in range(71,80):
    q.put(datum)


# print progress
while q.qsize()>0:
    time.sleep(5)
    progress = 100.0*(1-q.qsize()/len(data))
    print( "\r{:.2f}% done".format( progress ), end='' )
    sys.stdout.flush()
print('100% done.')
q.join()


# Cleanup
for p in procs:
    q.put( None ) # Make sure the worker loop terminates
q.join()
for p in procs:
    p.join() # Terminate processes
print( "\nFinished everything ({} items processed).".format(len(q.get_count())) )
