#!/usr/bin/env python3
"""Code qualitly often reminds me of spelling

color -- colour -- kaller -- quàhllähr -- kʌlər

Are some of these more sensible than others?

Zen of Python tells us:
    "{obvious}"

But there are many.

Obvious to whom?

The last one is the IPA (International Phonetic Alphabet) spelling...
It has letters for every phonem that exists in human language.
It is more general and precise than the others.

IPA is only "obvious" to people who know and comprehensible to those
who spend significant time learning it.
Understanding requires knowledge.
The "under" in undertstand does not mean "beneath".
It means "under these circumstances".
"Under these circumstances, I can stand, be confident with this."
So to talk objectivly about code quality, is to talk about
what knowledge is presumed and what the possibilities to express the
underlying concept are.

These two:

{fib_gen}

{Fib_cls}

...spell out the same ideas.

Translated differently into code.
Two Spellings of the same concept.

One requires more time to read AND more knowledge.
The other is better.
"""

def fib(a=1, b=1):
    while True:
        yield b
        a, b = b, a+b


class Fib:
    def __init__(self, a=1, b=1):
        self.a = a
        self.b = b

    __iter__ = lambda s: s

    def __next__(self):
        self.a, self.b = self.b, self.a + self.b
        return self.a


def get_zen(needle=''):
    import io
    from contextlib import redirect_stdout

    with io.StringIO() as buf, redirect_stdout(buf):
        import this
        zen = buf.getvalue().splitlines()

    return [x for x in zen if needle in x]


import inspect
obvious = get_zen('obvious')[0]
fib_gen = inspect.getsource(fib)
Fib_cls = inspect.getsource(Fib)


__doc__ = __doc__.format(**globals())


if __name__ == "__main__":
    print(__doc__)
    for f, F in zip(fib(), Fib()):
        print("{:3d} {:3d}".format(f, F))
        if f>20:
            break

