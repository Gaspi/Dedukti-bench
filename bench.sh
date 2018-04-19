#!/bin/bash

sep='|'
default_output_file=results.csv
sources_folder=dedukti


uuid=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
date=$(date)

echo "-------------------------------------------------------------"
echo "                 Dedukti Benchmarking Tool"
echo "-------------------------------------------------------------"
echo "    Bench nb: $uuid"
echo "    Date:     $date"
echo "    Revision: $1"
echo "-------------------------------------------------------------"


output="${output:-$default_output_file}"
dir=$(pwd)
out_file=$dir/$output
SOURCES=$dir/$sources_folder/
DKCHECK=$SOURCES/dkcheck.native

timec=/usr/bin/time
time_format=" $sep %E $sep %U $sep %S $sep %M $sep %K $sep %W"
export TIME="$time_format"

printf "$uuid" > $out_file

log () {
	printf " $sep $1" >> $out_file
}

log "$date"
log "$1"

rm -rf $SOURCES
git clone https://github.com/Deducteam/Dedukti.git $SOURCES
cd $SOURCES
git checkout $1

hashrev=$(git rev-parse HEAD)

log "$hashrev"

$timec -a -o $out_file make



# Run tests here





echo "-------------------------------------------------------------"
echo "                    Benchmarks done !"
echo "-------------------------------------------------------------"
echo "    Results are saved in: $out_file"
echo "-------------------------------------------------------------"
