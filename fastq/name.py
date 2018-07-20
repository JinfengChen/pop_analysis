#!/opt/Python/2.7.3/bin/python
import sys
from collections import defaultdict
import numpy as np
import re
import os
import argparse
import glob
from Bio import SeqIO
sys.path.append('/rhome/cjinfeng/BigData/software/ProgramPython/lib')
from utility import gff_parser, createdir

def usage():
    test="name"
    message='''
python name.py --input rufipogon > mv.sh

    '''
    print message


def runjob(script, lines):
    cmd = 'perl /rhome/cjinfeng/BigData/software/bin/qsub-slurm.pl --maxjob 60 --lines 2 --interval 120 --task 1 --mem 15G --time 100:00:00 --convert no %s' %(lines, script)
    #print cmd 
    os.system(cmd)



def fasta_id(fastafile):
    fastaid = defaultdict(str)
    for record in SeqIO.parse(fastafile,"fasta"):
        fastaid[record.id] = 1
    return fastaid

#SRR5796818      WM01    MS1     Mangshan wild mandarin
#SRR5796635      WM02    MS2     Mangshan wild mandarin
#SRR5796820      WM03    DX3     Daoxian wild mandarin No.3
def readtable(infile):
    data = defaultdict(str)
    with open (infile, 'r') as filehd:
        for line in filehd:
            line = line.rstrip()
            if len(line) > 2: 
                unit = re.split(r'\t',line)
                data[unit[0]] = unit[1]
    return data


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--input')
    parser.add_argument('-t', '--table')
    parser.add_argument('-v', dest='verbose', action='store_true')
    args = parser.parse_args()
    try:
        len(args.input) > 0
    except:
        usage()
        sys.exit(2)

    names = readtable(args.table)
    r = re.compile(r'(.*)_\d+.f.*?q.gz')
    gzfiles = glob.glob('%s/SRR*.*.gz' %(args.input))
    for gzfile in sorted(gzfiles):
        fname = os.path.split(gzfile)[1]
        #print fname
        if not fname.startswith(r'nivara') and not fname.startswith(r'rufipogon'):
            #print gzfile, fname
            m = r.search(fname)
            acc = 'NA' if not m else m.groups(0)[0]
            #print acc, names[acc]
            newname = re.sub(r'%s' %(acc), r'%s' %(names[acc]), gzfile)
            #print newname
            cmd = 'mv %s %s' %(gzfile, newname)
            if names[acc] is not "":
                print cmd

if __name__ == '__main__':
    main()

