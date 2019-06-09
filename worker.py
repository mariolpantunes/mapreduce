# coding: utf-8


import string
import logging
import argparse


logging.basicConfig(level=logging.DEBUG,format='%(asctime)s %(name)-12s %(levelname)-8s %(message)s',datefmt='%m-%d %H:%M:%S')
logger = logging.getLogger('worker')


def tokenizer(txt):
    tokens = txt.lower()
    tokens = tokens.translate(str.maketrans('', '', string.digits))
    tokens = tokens.translate(str.maketrans('', '', string.punctuation))
    tokens = tokens.translate(str.maketrans('', '', '«»'))
    tokens = tokens.rstrip()
    return tokens.split()


def main(args):
    logger.debug('Connecting %d to %s:%d', args.id, args.hostname, args.port)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='MapReduce worker')
    parser.add_argument('--id', dest='id', type=int, help='worker id', default=0)
    parser.add_argument('--port', dest='port', type=int, help='coordinator port', default=8765)
    parser.add_argument('--hostname', dest='hostname', type=str, help='coordinator hostname', default='localhost')
    args = parser.parse_args()
    
    main(args)
