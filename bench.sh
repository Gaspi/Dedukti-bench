#!/bin/bash

dir=$(pwd)
date=$(date)

NEW_UUID=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

export TIME='%E | %U | %S | %M | %K | %W'

timec=/usr/bin/time

log_file=$dir/log

echo "-------------------------------"
echo "Date: $date"
echo "Running benchmark for: $1"
echo "Bench n° $NEW_UUID"
echo "-------------------------------"

rm $log_file
echo "$NEW_UUID |" >> $log_file
echo "$date |" >> $log_file
echo "$1 |" >> $log_file

rm -rf ./dedukti

git clone https://github.com/Deducteam/Dedukti.git dedukti
cd dedukti
git checkout $1

$timec -a -o $log_file make

cd $dir
