from __future__ import print_function

import psycopg

def sqlesc(string):
    return string.replace("'","''")

if __name__ == "__main__":
    remote_ip="192.168.24.3"

    conn = connect("dbname=test user=test")
    curs = conn.cursor()
    curs.execute("SELECT * FROM atable")
    rows = curs.fetchall()
    for i in range(len(rows)):
        print("".join(["Row", i, "name", rows[i][0], "value", rows[i][1]]))
