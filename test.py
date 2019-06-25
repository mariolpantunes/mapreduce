# coding: utf-8


import csv
import logging
import argparse
import locale
from functools import cmp_to_key


logging.basicConfig(level=logging.DEBUG,format='%(asctime)s %(name)-12s %(levelname)-8s %(message)s',datefmt='%m-%d %H:%M:%S')
logger = logging.getLogger('test')

locale.setlocale(locale.LC_ALL, 'pt_PT.UTF-8')
c = cmp_to_key(locale.strcoll)


def binary_search(A, l, h, k, compare):
    if h >= l:
        mid = int(l + (h - l)/2)
        if compare(A[mid], k) == 0:
            return mid
        elif compare(A[mid], k) > 0:
            return binary_search(A, l, mid-1, k, compare)
        else:
            return binary_search(A, mid+1, h, k, compare)
    else:
        return -1


def load_csv(file):
    hist=[]
    with file as f:
        csv_reader = csv.reader(f, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
        for row in csv_reader:
            hist.append((row[0], int(row[1])))
    hist.sort(key=lambda t: c(t[0]))
    return hist


def total(res):
    total = 0
    for w,c in res:
        total += c
    return total


def diff(res, out):
    diff_a = [x for x in res if binary_search(out, 0, len(out)-1, x, lambda a, b: locale.strcoll(a[0], b[0])) < 0]
    diff_b = [x for x in out if binary_search(res, 0, len(res)-1, x, lambda a, b: locale.strcoll(a[0], b[0])) < 0]
    d = diff_a + diff_b
    d.sort(key=lambda t: c(t[0]))
    return d


def main(args):
    res = load_csv(args.res)
    out = load_csv(args.out)
    t = total(res)
    d = diff(res, out)
    td = total(d)
    for w,c in res:
        idx = binary_search(out, 0, len(out)-1, (w,c), lambda a, b: locale.strcoll(a[0], b[0]))
        if idx >= 0:
            td += abs(c - out[idx][1])
    ss = 1.0 - (td/(t*1.0))
    print('Similarity Score: {}'.format(ss))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Test Output vs Result')
    parser.add_argument('-r', dest='res', type=argparse.FileType('r', encoding='UTF-8'), help='result file path')
    parser.add_argument('-o', dest='out', type=argparse.FileType('r', encoding='UTF-8'), help='output file path', default='output.csv')
    args = parser.parse_args()
    
    main(args)