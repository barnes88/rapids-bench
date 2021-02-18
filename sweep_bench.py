#!/usr/bin/bash

from subprocess import run
import os
from shutil import copyfile
from datetime import datetime

queries = [*range(1, 23)]
partitions = [*range(1,129,2)]
for query in queries:
    for partition in partitions:
        print("Running GPU Query q" + str(query) + " with partition: " + str(partition))
        copyfile('./gpu_base.properties','./gpu_temp.properties')
        with open("./gpu_temp.properties", "a") as f:
            f.write('spark.rapids.sql.concurrentGpuTasks='+str(partition)+'\n')
            f.write('spark.sql.shuffle.partitions='+str(partition)+'\n')
        print("Started at " + datetime.today().strftime('%Y-%m-%d-%H:%M:%S'))
        try:
            output = run(["python3 benchmark.py --gc-between-runs --benchmark tpch --template template.txt --input ../tpcdslike100G/tpch-tables/100_none/ --input-format parquet --configs gpu_temp --iterations 10 --query q" + str(query) +" 2>&1 | tee "+str(query)+"_"+str(partition)+"TPCH_BATCHSIZE.log"], stdout=None, shell=True, timeout=24*60*60)
        except:
            print("QUERY " + str(query) +" failed")
        finally:
            os.remove("./gpu_temp.properties")
