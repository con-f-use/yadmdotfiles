#!/usr/bin/env python
"""
Demonstrates that the cache decorator can save time on some computations.
"""

from functools import cache


def fib(n):  # yes, yes, we could make this tail-recursive
    if n <= 1:
        return n
    return fib(n-1) + fib(n-2)


if __name__ == "__main__":
    import sys
    if len(sys.argv) < 2:
        sys.stderr.write("ERR: Run with 'cache' or 'nocache' argument!\n")
        raise SystemExit(1)
    if "cache" in sys.argv:
        # Note that now integers mayb be limted to 4300 digits in some
        # Python versions, unless:
        # sys.set_int_max_str_digits(0)
        # See: https://github.com/python/cpython/issues/95778
        fib = cache(fib)

    for i in range(400):
        print(f"fib({i}) = {fib(i)}")
    print("done")
