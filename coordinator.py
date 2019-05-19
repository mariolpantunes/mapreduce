# coding: utf-8

import socket
import logging
import argparse

logging.basicConfig(level=logging.DEBUG,format='%(asctime)s %(name)-12s %(levelname)-8s %(message)s',datefmt='%m-%d %H:%M:%S')
logger = logging.getLogger('coordinator')


def main(args):
    with args.file as file:
        while True:
            blob = file.read(args.blob_size)
        if not blob:
            break
        logger.debug('Blob: %s', blob)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='MapReduce Coordinator')
    parser.add_argument('-p', dest='port', type=int, help='coordinator port', default=5000)
    parser.add_argument('-f', dest='file', type=argparse.FileType('r'), help='file path')
    parser.add_argument('-b', dest ='blob_size', type=int, help='blob size', default=128)
    args = parser.parse_args()
    
    main(args)

