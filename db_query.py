#!/usr/bin/python
import MySQLdb
import sys

db = MySQLdb.connect(host="localhost",    # your host, usually localhost
                     user="root",         # your username
                     passwd="",  # your password
                     db="hg38")        # name of the data base

# you must create a Cursor object. It will let
#  you execute all the queries you need
cur = db.cursor()

# Queries
queryHugo = "select display_label from xref where xref_id in (select display_xref_id from gene where stable_id = %(ensembl_id)s)"
queryBases = "select seq_region_start,seq_region_end from gene where stable_id = %(ensembl_id)s)"
queryChrom = "select name from seq_region where seq_region_id in (select seq_region_id from gene where stable_id = %(ensembl_id)s)"

for line in sys.stdin:
    value = line.strip()
    cur.execute(queryHugo, {'ensembl_id':value})
    hugo = cur.fetchone()[0]
    cur.execute(queryBases, {'ensembl_id':value})
    baseStart = cur.fetchone()[0]
    baseEnd = cur.fetchone()[1]
    cur.execute(queryChrom, {'ensembl_id':value})
    chrom = cur.fetchone()[0]
    print("%s\t%s\t%s\t%s" % (hugo,chrom,baseStart,baseEnd))

# Use all the SQL you like
#cur.execute("SELECT * FROM gene")

# print all the first cell of all the rows
#for row in cur.fetchall():
#    print row[0]

db.close()
