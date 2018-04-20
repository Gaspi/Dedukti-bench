#!/bin/bash

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $dir/paths.sh

# If database does not exist, start by creating it.
if [ ! -f $database ]
then
	bash $dir/fresh-db.sh "$database"
fi

echo ""
echo "-------------------------------------------------------------"
echo "                 Dedukti Benchmarking Tool"
echo "-------------------------------------------------------------"
echo "    Looking for a bench to run in whitelist: $whitelist"

# Variable storing the commit chosen to be benched
chosen_bench=""

for i in $(cat "$whitelist")
do
	# Counting number of entries for this commit in the databsae
	nbbenchs=$(grep "| $i" "$database" | wc -l)
	if [ "$nbbenchs" -lt "$benchs_required" ]
	then
		chosen_bench=$i # If we need more there chose this bench
		break  # Skip entire rest of loop.
	fi
done

if [ -z "$chosen_bench" ]
then
	echo "    No further bench to run."
	exit 0   # Success, stop running benches
else
	echo "    Found one: $chosen_bench"
	bash $dir/bench.sh $chosen_bench
	exit 1   # Keep running benches
fi
