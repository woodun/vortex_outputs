#!/bin/sh

# 6 Mars benchmarks - running on Inti
mkdir cache_sense
cd cache_sense

for benchmark in lulesh
do
              mkdir $benchmark
              cd $benchmark
              ln -s $benchmarks/cache_sense/$benchmark/gpgpu_ptx_sim__$benchmark .
              ln -s $benchmarks/cache_sense/$benchmark/data . 
              cp $applications/bash-scripts/run_scripts/cache_sense/mainscript_$benchmark .
              chmod 777 mainscript_$benchmark
              cd ../
done

for benchmark in BFS2S BFS2M BFS2L
do
              mkdir $benchmark
              cd $benchmark
              ln -s $benchmarks/cache_sense/BFS2/gpgpu_ptx_sim__BFS2 .
              ln -s $benchmarks/cache_sense/BFS2/data . 
              cp $applications/bash-scripts/run_scripts/cache_sense/mainscript_$benchmark .
              chmod 777 mainscript_$benchmark
              cd ../

done

for benchmark in KMNS KMNM KMNL
do
              mkdir $benchmark
              cd $benchmark
              ln -s $benchmarks/cache_sense/KMN/gpgpu_ptx_sim__KMN .
              ln -s $benchmarks/cache_sense/KMN/data . 
              cp $applications/bash-scripts/run_scripts/cache_sense/mainscript_$benchmark .
              chmod 777 mainscript_$benchmark
              cd ../
done

GPGPUSIM_CONFIG=$1
if [ "x$GPGPUSIM_CONFIG" = "x" ]; then 
    echo "Usage: $0 <GPGPU-Sim Config Name | --cleanup>"
    exit 0
fi

if [ "x$GPGPUSIM_ROOT" = "x" ]; then 
    GPGPUSIM_ROOT="$PWD/.."
fi

#BENCHMARKS=`ls CUDA | sed 's/\([^ ]\+\)/\.\/CUDA\/\1/'`

if [ $1 = "--cleanup" ]; then
    echo "Removing existing configs in the following directories:"
    for BMK in BFS2S BFS2M BFS2L KMNS KMNM KMNL lulesh; do
        if [ -f $BMK/gpgpusim.config ]; then
            echo "$BMK"
            OLD_ICNT=`awk '/-inter_config_file/ { print $2 }' $BMK/gpgpusim.config`
            rm $BMK/gpgpusim.config $BMK/$OLD_ICNT
        fi
    done
    exit 0
fi

GPU_CONFIG_FILE=$GPGPUSIM_ROOT/configs/$GPGPUSIM_CONFIG/gpgpusim.config
if [ -f $GPU_CONFIG_FILE ]; then
    echo "Found GPGPU-Sim config file: $GPU_CONFIG_FILE"
else
    echo "Unknown config: $GPGPUSIM_CONFIG"
    exit 0
fi

ICNT_CONFIG=`awk '/-inter_config_file/ { print $2 }' $GPU_CONFIG_FILE`
ICNT_CONFIG=$GPGPUSIM_ROOT/configs/$GPGPUSIM_CONFIG/$ICNT_CONFIG
if [ -f $GPU_CONFIG_FILE ]; then
    echo "Interconnection config file detected: $ICNT_CONFIG"
else
    echo "Interconnection config file not found: $ICNT_CONFIG"
    exit 0
fi

POWER_CONFIG=`awk '/-gpuwattch_xml_file/ { print $2 }' $GPU_CONFIG_FILE`
POWER_CONFIG=$GPGPUSIM_ROOT/configs/$GPGPUSIM_CONFIG/$POWER_CONFIG
if [ -f $GPU_CONFIG_FILE ]; then
    echo "Power config file detected: $POWER_CONFIG"
else
    echo "Power config file not found: $POWER_CONFIG"
    exit 0
fi

for BMK in BFS2S BFS2M BFS2L KMNS KMNM KMNL lulesh; do
    if [ -f $BMK/gpgpusim.config ]; then
        echo "Existing symbolic-links to config found in $BMK! Skipping... "
    else
        echo "Adding symbolic-links to configuration files for $BMK:"
        ln -v -s $GPU_CONFIG_FILE $BMK
        ln -v -s $ICNT_CONFIG $BMK
		ln -v -s $POWER_CONFIG $BMK
    fi
done

cd ../
sh gen_pbs_cache_sense.sh

