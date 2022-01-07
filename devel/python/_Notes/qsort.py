#!/usr/bin/env python
import random


def qsort_outofplace(arr):
    if len(arr) <= 1:
        return arr

    return (
        qsort_outofplace([x for x in arr[1:] if x < arr[0]]) +
        [arr[0]] +
        qsort_outofplace([x for x in arr[1:] if x >= arr[0]])
    )


def qsort_inplace(arr, fst=0, lst=None):
    def _qsort(arr, fst, lst):
        if fst >= lst:
            return

        i, j = fst, lst
        pivot = arr[random.randint(fst, lst)]

        while i <= j:
            while arr[i] < pivot:
                i += 1
            while arr[j] > pivot:
                j -= 1

            if i <= j:
                arr[i], arr[j] = arr[j], arr[i]
                i, j = i + 1, j - 1

        _qsort(arr, fst, j)
        _qsort(arr, i, lst)

    _qsort(arr, fst, len(arr)-1 if lst is None else lst)
    return arr

arr = [ 12, 15, 3, 101, 7, 8, 8, 9 ]

print(qsort_outofplace(arr))
print(qsort_inplace(arr))
print(arr)
