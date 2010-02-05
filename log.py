from __future__ import print_function

import subprocess
import re                                                              
import MySQLdb
import httplib

# TODO Rewrite this script to build SQL queries with prepare

def sqlesc(string):
    return string.replace("'","''")

if __name__ == "__main__":
    pipe = subprocess.Popen(["hcitool", "scan"], stdout=subprocess.PIPE)
    text = pipe.communicate()[0];

    pat = re.compile(r"^\t(..:..:..:..:..:..)\t(.*)$")
    sql_entries = []

    # We need a temporary table for this raw data
    sql_entries.append("CREATE TEMPORARY TABLE log (hwaddr char(17), name text);")
    
    for line in text.splitlines():
        matchs = re.match(pat, line)
        if matchs is None:
            continue
        sql_entries.append("insert into log (hwaddr,name) values('%s','%s');"
                          % (sqlesc(matchs.group(1)), sqlesc(matchs.group(2))))

    # Propagate temporary table contents to right tables
    sql_entries.append("CALL update_tables;")

    conn = MySQLdb.connect (host = "localhost",
                            user = "logger",
                            passwd = "loglog",
                            db = "bluetooth")

    cursor = conn.cursor()
    cursor.execute ("".join(sql_entries))
    cursor.close ()
    conn.close ()

    # replicate
    repl = httplib.HTTPConnection('192.168.24.1',timeout=60)
    repl.request('GET','/bt-logger/trigger_replication')
    print(repl.getresponse().read())

