#!/usr/bin/env python

def nums(n):
    yield n
    yield from nums(n+1)

def sieve(s):
    n = next(s)
    yield n
    yield from sieve(i for i in s if i%n!=0)

p = sieve(nums(2))
for x in range(20):
    print(next(p))


def repeat(v):
    while True:
        yield v


def print_grid(g):
    print( str(g).replace("],", "],\n") )


size_ = 9
grid = [ [next(repeat(0)) for x in range(size_)] for y in range(size_) ]


def possible(y, x, n):
    global grid

    # Check column
    for i in range(0, size_):
        if grid[y][i] == n:
            return False

    # Check row
    for i in range(0, size_):
        if grid[i][x] == n:
            return False

    # Check square
    x0, y0 = (x//3)*3, (y//3)*3
    for i in range(0,3):
        for j in range(0,3):
            if grid[y0+i][x0+j] == n:
                return False

    return True


def sudoku():
    global grid

    for y in range(size_):
        for x in range(size_):
            if grid[y][x] == 0:
                for n in range(1, size_+1):
                    if possible(y, x, n):
                        grid[y][x] = n
                        yield from sudoku()
                        grid[y][x] = 0
                return
    yield grid


print_grid(next(sudoku()))
print_grid(next(sudoku()))
print_grid(next(sudoku()))
