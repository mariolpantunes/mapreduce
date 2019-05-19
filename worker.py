# coding: utf-8


import socket
import logging
import argparse


logging.basicConfig(level=logging.DEBUG,format='%(asctime)s %(name)-12s %(levelname)-8s %(message)s',datefmt='%m-%d %H:%M:%S')
logger = logging.getLogger('worker')


def main(args):
    pass


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='MapReduce worker')
    parser.add_argument('-p', dest='port', type=int, help='coordinator port', default=5000)
    args = parser.parse_args()
    
    main(args)

