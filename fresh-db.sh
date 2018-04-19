
db=$1


echo "-------------------------------------------------------------"
echo "                 Creating fresh database"
echo "-------------------------------------------------------------"

printf "bench_id" > $db

pr () {
	printf " | $1" >> $db
}

pr "bench_version"
pr "bench_timestamp"
pr "bench_argument"
pr "commit_hash"
pr "commit_timestamp"

pr_times () {
	pr "bench$1_real_time"
	pr "bench$1_user_time"
	pr "bench$1_kernel_time"
	pr "bench$1_max_memory"
	pr "bench$1_mean_memory"
	pr "bench$1_swaps"
	pr "bench$1_status"
}

pr_times 0
pr_times 1
pr_times 2
pr_times 3

echo "" >> $db
