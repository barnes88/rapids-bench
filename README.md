# Nvidia Spark-Rapids plugins benchmarks
Get started in 5 minutes to run TPCH(like)

## Setup Instructions:

```
source setup_env.sh
./gen_tables.sh -s 1 -c none -m 8G
python3 benchmark.py --benchmark tpch --template template.txt --input ./tpch-tables/1_none/ --input-format parquet --configs gpu --query q3 --iterations 1
python3 benchmark.py --benchmark tpcds --template template.txt --input ./tpcds-tables/1_none/ --input-format parquet --configs cpu --query q1 --iterations 1
```

## To Generate traces in Accelsim:
Create `spark-env.sh` file in `$SPARK_HOME/conf/` which defines `LD_PRELOAD` and points to your tracer_tool.so file
