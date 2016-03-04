#!/bin/bash

#NN LIB
for benchmark in BFS SCP RAY kmeans BlackScholes 
do
	    cd  CUDA/$benchmark/
 	    qsub pbs_$benchmark.pbs
	    cd -
done
