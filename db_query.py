#!/usr/bin/python
import argparse
import MySQLdb
import sys

parser = argparse.ArgumentParser(description="Generate row swap file.")
parser.add_argument('-o', help='Ouput Path')
args = parser.parse_args()

db = MySQLdb.connect(host="localhost",    # your host, usually localhost
                     user="root",         # your username
                     passwd="",  # your password
                     db="hg38")        # name of the data base

cur = db.cursor()

if args.o:
    sys.stdout = open(args.o, 'w')

# Queries
queryHugo = "select display_label from xref where xref_id in (select display_xref_id from gene where stable_id = %(ensembl_id)s)"
queryBases = "select seq_region_start,seq_region_end from gene where stable_id = %(ensembl_id)s"
queryChrom = "select name from seq_region where seq_region_id in (select seq_region_id from gene where stable_id = %(ensembl_id)s)"

print("%s\t%s\t%s\t%s\t%s" % ("Ensembl_Gene_ID", "HUGO_Gene_Symbol", "Chromosome", "Base_Start", "Base_End"))

for line in sys.stdin:
    ensembl = line.strip()
    if(ensembl.startswith("ENSG")):
        cur.execute(queryHugo, {'ensembl_id':ensembl})
        hugo = cur.fetchone()[0]
        cur.execute(queryBases, {'ensembl_id':ensembl})
        baseStart,baseEnd = cur.fetchone()
        cur.execute(queryChrom, {'ensembl_id':ensembl})
        chrom = cur.fetchone()[0]
        print("%s\t%s\t%s\t%s\t%s" % (ensembl,hugo,chrom,baseStart,baseEnd))
    else:
        print("%s\t%s\t%s\t%s\t%s" % (ensembl,ensembl,ensembl,ensembl,ensembl))

db.close()
