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

echo "Generating TPCH Tables of size $scaleFactor ..."
DBGEN_ROOT=$BASH_ROOT/tpch-dbgen
rm -f $DBGEN_ROOT/*.tbl
pushd $DBGEN_ROOT
./dbgen -vf -s $scaleFactor
popd

echo "Converting TPCH tables to parquet files"
TBL_ROOT="$BASH_ROOT/tpch-tables/${scaleFactor}_${compress}"
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
echo "TPCH Parquet tables generated to $TBL_ROOT"

echo "Generating TPDS Tables of size $scaleFactor ..."
TPCDS_KIT_ROOT=$BASH_ROOT/tpcds-kit
mkdir -p $TPCDS_KIT_ROOT/tables
rm -f $TPCDS_KIT_ROOT/tables/*.dat
pushd $TPCDS_KIT_ROOT/tools
./dsdgen -SCALE $scaleFactor \
    -VERBOSE Y \
    -DIR $TPCDS_KIT_ROOT/tables/
popd

echo "Converting TPCDS tables to parquet files"
TPCDS_TBL_ROOT="$BASH_ROOT/tpcds-tables/${scaleFactor}_${compress}"
mkdir -p $TPCDS_TBL_ROOT
$SPARK_HOME/bin/spark-submit \
    --master local[*] \
    --driver-memory ${mem} \
    --conf spark.sql.parquet.compression.codec="$compress" \
    --jars $SPARK_RAPIDS_PLUGIN_JAR,$CUDF_JAR,$SCALLOP_JAR \
    --class com.nvidia.spark.rapids.tests.tpcds.ConvertFiles \
    $SPARK_RAPIDS_PLUGIN_INTEGRATION_TEST_JAR \
    --input $TPCDS_KIT_ROOT/tables \
    --output $TPCDS_TBL_ROOT \
    --output-format parquet
echo "TPCDS Parquet tables generated to $TPCDS_TBL_ROOT"

# Remove .dat from foldernames
pushd $TPCDS_TBL_ROOT
mv call_center.dat call_center
mv catalog_page.dat catalog_page
mv catalog_returns.dat catalog_returns
mv catalog_sales.dat catalog_sales
mv customer.dat customer
mv customer_address.dat customer_address
mv customer_demographics.dat customer_demographics
mv date_dim.dat date_dim
mv household_demographics.dat household_demographics
mv income_band.dat income_band
mv inventory.dat inventory
mv item.dat item
mv promotion.dat promotion
mv reason.dat reason
mv ship_mode.dat ship_mode
mv store.dat store
mv store_returns.dat store_returns
mv store_sales.dat store_sales
mv time_dim.dat time_dim
mv warehouse.dat warehouse
mv web_page.dat web_page
mv web_returns.dat web_returns
mv web_sales.dat web_sales
mv web_site.dat web_site
popd
