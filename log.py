from __future__ import print_function

import subprocess
import re                                                              

def sqlesc(string):
    return string.replace("'","''")

if __name__ == "__main__":
    pipe = subprocess.Popen(["hcitool", "scan"], stdout=subprocess.PIPE)
    text = pipe.communicate()[0];

    pat = re.compile(r"^\t(..:..:..:..:..:..)\t(.*)$")
    bd_entries = []
    for line in text.splitlines():
        matchs = re.match(pat, line)
        if matchs is None:
            continue
        bd_entries.append("insert into log (hwaddr,name) values('%s','%s');"
                          % (sqlesc(matchs.group(1)), sqlesc(matchs.group(2))))
    print("".join(bd_entries))
