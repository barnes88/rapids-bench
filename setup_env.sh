#!/bin/bash
export BASH_ROOT="$( cd "$( dirname "$BASH_SOURCE" )" && pwd )"

# Setup Spark 3.0.0 (scala 2.12) for spark submit
SPARK_SUBDIR="/spark-3.0.0-bin-hadoop3.2/"
SPARK_HOME=$BASH_ROOT$SPARK_SUBDIR
if [ ! -d $SPARK_HOME ]; then
    wget https://archive.apache.org/dist/spark/spark-3.0.0/spark-3.0.0-bin-hadoop3.2.tgz
    tar xzvf spark-3.0.0-bin-hadoop3.2.tgz -C $BASH_ROOT
    rm spark-3.0.0-bin-hadoop3.2.tgz
fi
export SPARK_HOME=$SPARK_HOME

# Setup Rapids Jars (scala 2.12) and dependencies they don't include
LIB_SUBDIR="/lib"
LIB_ROOT=$BASH_ROOT$LIB_SUBDIR

if [ ! -d $LIB_ROOT ]; then
    wget https://repo1.maven.org/maven2/com/nvidia/rapids-4-spark-integration-tests_2.12/0.3.0/rapids-4-spark-integration-tests_2.12-0.3.0.jar -P $LIB_ROOT
    wget https://repo1.maven.org/maven2/org/rogach/scallop_2.12/3.5.1/scallop_2.12-3.5.1.jar -P $LIB_ROOT
    wget https://repo1.maven.org/maven2/ai/rapids/cudf/0.17/cudf-0.17.jar -P $LIB_ROOT
    wget https://repo1.maven.org/maven2/com/nvidia/rapids-4-spark_2.12/0.3.0/rapids-4-spark_2.12-0.3.0.jar -P $LIB_ROOT
fi
export SPARK_RAPIDS_PLUGIN_JAR=$LIB_ROOT/rapids-4-spark_2.12-0.3.0.jar
export SPARK_RAPIDS_PLUGIN_INTEGRATION_TEST_JAR=$LIB_ROOT/rapids-4-spark-integration-tests_2.12-0.3.0.jar
export CUDF_JAR=$LIB_ROOT/cudf-0.17.jar
export SCALLOP_JAR=$LIB_ROOT/scallop_2.12-3.5.1.jar

# Install DBGEN for TPCH
DBGEN_ROOT=$BASH_ROOT/tpch-dbgen

if [ ! -d $DBGEN_ROOT ]; then
    git clone https://github.com/electrum/tpch-dbgen.git $DBGEN_ROOT
    rm $DBGEN_ROOT/makefile
    cp $BASH_ROOT/Makefile-dbgen $BASH_ROOT/tpch-dbgen/Makefile
    make -C $DBGEN_ROOT
fi

mkdir -p $BASH_ROOT/spark-event-logs
export RAPIDS_BENCH_SETUP_WAS_RUN=
