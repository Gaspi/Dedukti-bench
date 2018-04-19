#!/bin/bash

dir=$(pwd)
source $dir/paths.sh

db=$1

echo "-------------------------------------------------------------"
echo "    Creating fresh database: $db"

printf "bench_id" > $db

pr () {
	printf " $sep $1" >> $db
}

for field in $base_fields
do
	pr "$field"
done

pr_times () {
	for field in $bench_fields
	do
		pr "bench$1_$field"
	done
}

for i in $(seq 0 $nb_benchs)
do
	pr_times $i
done

echo "" >> $db


echo "    Done."
echo "-------------------------------------------------------------"
