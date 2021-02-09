#!/usr/bin/bash

from subprocess import run
import os
from datetime import datetime

queries = [*range(1, 100)]
path = "./nvprof_TPCDS/"
if not os.path.isdir(path):
    os.makedirs(path)
for query in queries:
    print("Running GPU Query q" + str(query))
    print("Started at " + datetime.today().strftime('%Y-%m-%d-%H:%M:%S'))
    filename = path + str(query) + ".txt"
    f = open(filename, "w")
    try:
        output = run(["nsys profile -o " + str(query) + " python3 benchmark.py --benchmark tpcds --template template.txt --input ./tpcds-tables/100_none/ --input-format parquet --configs gpu --iterations 1 --query q" + str(query) +" 2>&1 | tee "+str(query)+"TPCDSprofiler.log"], stdout=f, shell=True, timeout=24*60*60)
    except:
        print("QUERY " + str(query) +" failed")
    finally:
        f.close()
