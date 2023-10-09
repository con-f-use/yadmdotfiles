#!/usr/bin/env python
"""Visually compactly encodes binary data into an utf-8 glyph.

See:
  https://discuss.python.org/t/base-utf8-encoding-without-escape-sequences/30271/11
"""

import sys
import base64
import string


b64_chars = string.ascii_letters + string.digits + "+/"
u8_marks = "".join(chr(x) for x in range(0x300, 0x340))


def encode(data):
    tr = str.maketrans(b64_chars, u8_marks)
    return "a" + base64.b64encode(data).decode("ascii").translate(tr)


def decode(data):
    tr = str.maketrans(u8_marks, b64_chars)
    return base64.b64decode(data[1:].translate(tr).encode("ascii"))


def main(file_name):
    with open(file_name, "rb") as fh:
        data = fh.read()

    encoded = encode(data)
    decoded = decode(encoded)

    print(f"{' encoded '!s:=^40}\n{encoded}\n\n{' decoded ':=^40}\n{decoded}\n")

if __name__ == "__main__":
    main(sys.argv[1])
