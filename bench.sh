#!/bin/bash

log_file=$dir/log
sep='|'

SOURCES=$dir/dedukti/

timec=/usr/bin/time

time_format="%E $sep %U $sep %S $sep %M $sep %K $sep %W"

dir=$(pwd)
date=$(date)
uuid=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

echo "-------------------------------------------------------"
echo "             Dedukti Benchmarking Tool"
echo "-------------------------------------------------------"
echo "  Bench nb: $uuid"
echo "  Date:     $date"
echo "  Revision: $1"
echo "-------------------------------------------------------"

DKCHECK=$SOURCES/dkcheck.native

export TIME="$time_format"

printf "$uuid" > $log_file

log () {
	printf " $sep $1" >> $log_file
}

log "$date"
log "$1"

rm -rf $SOURCES
git clone https://github.com/Deducteam/Dedukti.git $SOURCES
cd $SOURCES
git checkout $1

hashrev=$(git rev-parse HEAD)

log "$hashrev"

$timec -a -o $log_file make

cd $dir
