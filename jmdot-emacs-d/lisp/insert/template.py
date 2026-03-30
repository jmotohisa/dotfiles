#!/usr/bin/env python
# -*- coding: utf-8 -*-

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import argparse
import glob

def get_args():
    """
    Argument parser
    """
    parser = argparse.ArgumentParser(
        description='template')
    # 標準入力以外の場合
    # if sys.stdin.isatty():
    #     parser.add_argument('basefname', help='base file name', type=str)
    # skeltons
    # float
    parser.add_argument('-s', '--start',
                        nargs='?',
                        type=float,
                        default=1,
                        help='starting wavelength')
    # integer
    parser.add_argument('-i', '--index',
                        nargs='?',
                        type=int,
                        help='starting index')
    # boolean
    parser.add_argument('-u', '--underscore',
                        action="store_true",
                        help='with underscore in file name')
    # string
    parser.add_argument('-o', '--out', type=str,
                        nargs='?',
                        help="output csv file name")
    # string with choics
    parser.add_argument('--mode', choices=['TE','TM'],default='TE',
                        help='mode')
    # multiple file names (with gglob)
    parser.add_argument('fnames', type=str,
                        nargs='+',
                        help='name of a XLSX file')
    args = parser.parse_args()
    return (args)


def main():
    args=get_args()
    fname_all = glob.glob(args.fnames) # glob
    
if __name__ == '__main__':
    main()
