import subprocess                                                      
import re                                                              

def sqlesc(str):
        return str.replace('\'','\'\'')

pat = re.compile('^\t(..:..:..:..:..:..)\t(.*)$')

text = subprocess.Popen(["hcitool", "scan"], stdout=subprocess.PIPE).communicate
()[0];

n = 0
sql = 'insert into log (hwaddr,name) values'

for line in text.splitlines():
        if n != 0:
                sql = sql+','
        matchs = re.match(pat,line)
        if matchs == None:
                continue
        n=n+1
        sql = sql + '(\''+sqlesc(matchs.group(1))+'\',\''+sqlesc(matchs.group(2)
)+'\')'

sql = sql + ';'

if n != 0:
        print sql

