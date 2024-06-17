#!/usr/bin/env python3

class A:
    def f(self):
        print("A.f called")
        super().f()

class B:
    def f(self):
        print("B.f called")

class C(A, B):
    pass

print(
    f"Super get the next class in in the MRO {C.__mro__=},\n"
    "thus, calling C().f() successes, because while class A does not\n"
    "inherit from anython with a method f, class B is next in the MRO\n"
    "as seen from C and B.f is a method.\n\n"
    "*MRO: Method Resolution Order"
)
C().f()

