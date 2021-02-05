#!/bin/bash

## Generate parquet tables for a given scale factor size and compression codec

export BASH_ROOT="$( cd "$( dirname "$BASH_SOURCE" )" && pwd )"
if [ -z ${RAPIDS_BENCH_SETUP_WAS_RUN+1} ]
then echo "Error: run setup_env.sh first!"; exit 1
fi

usage() { echo "Usage: $0 [-s <scaleFactor>] [-c <snappy|none>] [-m <driverMemSize>]" 1>&2; exit 1; }

while getopts "c:s:m:" flag
do
    case "${flag}" in
        s) scaleFactor=${OPTARG};;
        c) compress=${OPTARG};;
        m) mem=${OPTARG};;
        *) usage;;
    esac
done

if [ -z "${scaleFactor}" ]; then
    usage
fi
if [ -z "${mem}" ]; then
    mem=4G
fi
if [ -z "${compress}" ]; then
    compress=snappy
fi

echo "Generating Tables of size $scaleFactor ..."
DBGEN_ROOT=$BASH_ROOT/tpch-dbgen
rm -f $DBGEN_ROOT/*.tbl
pushd $DBGEN_ROOT
./dbgen -vf -s $scaleFactor
popd

echo "Converting to parquet files"
TBL_ROOT="$BASH_ROOT/tables/${scaleFactor}_${compress}"
mkdir -p $TBL_ROOT
$SPARK_HOME/bin/spark-submit \
    --master local[*] \
    --driver-memory ${mem} \
    --conf spark.sql.parquet.compression.codec="$compress" \
    --jars $SPARK_RAPIDS_PLUGIN_JAR,$CUDF_JAR,$SCALLOP_JAR \
    --class com.nvidia.spark.rapids.tests.tpch.ConvertFiles \
    $SPARK_RAPIDS_PLUGIN_INTEGRATION_TEST_JAR \
    --input $DBGEN_ROOT \
    --output $TBL_ROOT \
    --output-format parquet
echo "Parquet tables generated to $TBL_ROOT"
