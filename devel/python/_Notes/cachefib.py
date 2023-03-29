#!/usr/bin/env python
"""
Demonstrates that the cache decorator can save time on some computations.

The naive Fibonacci implementation is by far the fastest, when cached
because we fully leverage the power of lookups, which are fast.
Of course, our loop here duplicates a lot of work between individual
iderations but that happens in the real world a lot, too.

Note that now integers may be limted to 4300 digits in some
Python versions, unless:
    sys.set_int_max_str_digits(0)
See: https://github.com/python/cpython/issues/95778
"""

import time
from functools import cache


def main(variant):
    start = time.monotonic()
    for i in range(400):
        print(f"{variant.__name__}({i}) = {variant(i)}")
    cache_satus = f"{' (used cache)' if 'cache' in variant.__class__.__name__ else ''}"
    print(f"done. took {time.monotonic()-start:.5f}s{cache_satus}.")


def rec(n):
    """Naive Fibonacci, recursive."""
    if n>1:
        return rec(n-1) + rec(n-2)
    return n


def tail(n, a=0, b=1):
    """Tail-recursive Fibonacci. However, caching is surprisingly good."""
    if n == 0:
        return a
    if n == 1:
        return b
    return tail(n-1, b, a+b)


def itr(n, a=0, b=1):
    """Iterative Fibonacci. Doesn't benefit much from caching either."""
    for _ in range(n):
        a, b = b, a+b
    return a


# smoke tests
assert rec(0) == 0; assert rec(1) == 1; assert rec(5) == 5
for x in range(10): assert rec(x) == tail(x) == itr(x), f"failed for {x}"


if __name__ == "__main__":
    # Boring argument handling
    import sys

    if len(sys.argv) < 2 or sys.argv[1] not in ["rec", "tail", "itr"]:
        sys.stderr.write(
            "ERR: Use one of 'rec', 'tail', 'itr' and optional 'cache' argument!\n"
        )
        raise SystemExit(1)

    if "cache" in sys.argv:
        rec, tail, itr = cache(rec), cache(tail), cache(itr)
    variant = getattr(sys.modules[__name__], sys.argv[1])
    main(variant)

