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

for line in sys.stdin:
    value = line.strip()
    hugo = "select display_label from xref where xref_id in (select display_xref_id from gene where stable_id = %(ensembl_id)s))"
    cur.execute(hugo, {'ensembl_id':value})
    for row in cur.fetchall():
        print row[0]

# Use all the SQL you like
#cur.execute("SELECT * FROM gene")

# print all the first cell of all the rows
#for row in cur.fetchall():
#    print row[0]

db.close()
