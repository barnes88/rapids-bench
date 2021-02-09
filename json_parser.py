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
(options, args) = parser.parse_args()

output_name = options.output_name.strip()
benchmark = options.benchmark.strip()
config = options.config.strip()

header = ['Query', 'Iter 0', 'Iter 1', '...']
with open(output_name, 'w') as outFile:
    csvwriter = csv.writer(outFile)
    csvwriter.writerow(header)
    for filename in glob.glob('./*' + benchmark + '*' + config + '*.json'):
        row = []
        f = open(filename)
        data = json.load(f)
        query = data['query']
        row.append(query)
        print("QUERY: " + query)
        i = 0
        for time in data['queryTimes']:
            print("Iteration " + str(i) + ": " + str(time) + " ms")
            row.append(time)
            i+=1
        csvwriter.writerow(row)
        f.close()
print("Script complete")
print("Output written to " + output_name)
