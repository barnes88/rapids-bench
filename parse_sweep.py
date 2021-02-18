#!/usr/bin/env python

import json
import csv
import glob
from optparse import OptionParser

parser = OptionParser()
parser.add_option("-o", "--output_name", dest="output_name",
                  help="The csv filename to dump the stats", default="stats.csv")
parser.add_option("-b", "--benchmark", dest="benchmark",
                                    help="The name of the bencmark run (Tpcds or Tpch)", default="")
parser.add_option("-c", "--config", dest="config",
                                    help="The config (*.properties) file used for the run", default="")
parser.add_option("-q", "--subquery", dest="subquery",
                                    help="which query to parse", default="")
(options, args) = parser.parse_args()

output_name = options.output_name.strip()
benchmark = options.benchmark.strip()
config = options.config.strip()
subquery = options.subquery.strip()

queries = range(1,23)
header = ['Query', 'ConcGpuTasks','Iter 0', 'Iter 1', '...']
with open(output_name, 'w') as outFile:
    csvwriter = csv.writer(outFile)
    csvwriter.writerow(header)
    for q in queries:
        for filename in glob.glob('./*' + benchmark + '*' + config + '*.json'):
            row = []
            try:
                f = open(filename)
                data = json.load(f)
                query = data['query']
                if str(query).strip() == ('q' + str(q)):
                    row.append(query)
                    print("QUERY: " + query)
                    concTask = data['env']['sparkConf']['spark.rapids.sql.concurrentGpuTasks']
                    row.append(concTask)
                    print("CONCTASK: " + str(concTask))
                    i = 0
                    j = 0
                    sum_tot = 0
                    for time in data['queryTimes']:
                        print("Iteration " + str(i) + ": " + str(time) + " ms")
                        i+=1
                        time_int = int(time)
                        row.append(time)
                        if (i != 1) and time_int != -1:
                            sum_tot += int(time)
                            j += 1
                    avg = "" if j == 0 else sum_tot / j
                    row.append("---")
                    row.append(avg)
                    csvwriter.writerow(row)
            except:
                print ("could not parse json file: " + str(filename))
            finally:
                f.close()
print("Script complete")
print("Output written to " + output_name)
