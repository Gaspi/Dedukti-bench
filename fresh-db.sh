
db=$1
nb_benchs=5

base_fields="bench_version bench_timestamp bench_argument commit_hash commit_timestamp"
bench_fields="real_time user_time kernel_time max_memory mean_memory swaps status"

echo "-------------------------------------------------------------"
echo "    Creating fresh database: $db"

printf "bench_id" > $db

pr () {
	printf " | $1" >> $db
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
