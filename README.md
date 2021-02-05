# Nvidia Spark-Rapids plugins benchmarks
Get started in 5 minutes to run TPCH(like)

## Setup Instructions:

```
source setup_env.sh
./gen_tables.sh -s 1 -c none -m 8G
python3 benchmark.py --benchmark tpch --template template.txt --input ./tables/1_none/ --input-format parquet --configs gpu --query q3 --iterations 1
```
