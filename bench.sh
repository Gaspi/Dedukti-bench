#!/bin/bash

script_version=0.1

sep='|'
database=~/bench.csv
sources_folder=dedukti
benchs_folder=benchs

uuid=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
date_unix_timestamp=$(date +%s)
date=$(date -d @$date_unix_timestamp)

echo "-------------------------------------------------------------"
echo "                 Dedukti Benchmarking Tool"
echo "-------------------------------------------------------------"
echo "    Bench nb: $uuid"
echo "    Date:     $date"
echo "    Revision: $1"
echo "-------------------------------------------------------------"

if [ ! -f $database ]
then
	bash fresh-db.sh "$database"
fi

dir=$(pwd)
out_file=$dir/out.csv
BENCHS=$dir/$benchs_folder/
SOURCES=$dir/$sources_folder/

rm -rf $BENCHS $SOURCES
mkdir $BENCHS

timec=/usr/bin/time
time_format=" $sep %e $sep %U $sep %S $sep %M $sep %K $sep %W $sep %x"
export TIME="$time_format"

printf "$uuid" > $out_file

log () {
	printf " $sep $1" >> $out_file
}

log_file () {
	cat $1 | tr -d "\n" >> $out_file
}

log "$script_version"
log "$date_unix_timestamp"
log "$1"

git clone https://github.com/Deducteam/Dedukti.git $SOURCES
cd $SOURCES
git checkout $1

commit_hash=$(git rev-parse HEAD)
commit_date=$(git --no-pager log -1 --format=%ct)

log "$commit_hash"
log "$commit_date"


echo "-------------------------------------------------------------"
echo "                    Bench 0 : Compilation"
echo "-------------------------------------------------------------"
$timec -a -o $SOURCES/compile.csv make
log_file $SOURCES/compile.csv


echo "-------------------------------------------------------------"
echo "                    Bench 1 : Tests"
echo "-------------------------------------------------------------"
$timec -a -o $SOURCES/tests.csv make tests
log_file $SOURCES/tests.csv


# Exporting DKCHECK and DKDEP to be used in following tests
export DKCHECK=$SOURCES/dkcheck.native
export DKDEP=$SOURCES/dkdep.native



echo "-------------------------------------------------------------"
echo "                    Bench 2 : Matita"
echo "-------------------------------------------------------------"
mkdir $BENCHS/bench2
cd $BENCHS/bench2

wget -q https://deducteam.github.io/data/libraries/matita.tar.gz
tar zxf matita.tar.gz
rm matita/matita_arithmetics_factorial.dk
rm matita/matita_arithmetics_binomial.dk
rm matita/matita_arithmetics_chebyshev_*.dk
rm matita/matita_arithmetics_chinese_reminder.dk
rm matita/matita_arithmetics_congruence.dk
rm matita/matita_arithmetics_fermat_little_theorem.dk
rm matita/matita_arithmetics_gcd.dk
rm matita/matita_arithmetics_ord.dk
rm matita/matita_arithmetics_primes.dk

$timec -a -o $BENCHS/bench2/time.csv make -C matita
log_file $BENCHS/bench2/time.csv



echo "-------------------------------------------------------------"
echo "                    Bench 3 : DKlib"
echo "-------------------------------------------------------------"
mkdir $BENCHS/bench3
cd $BENCHS/bench3

git clone -q -b v2.6 https://github.com/rafoo/dklib.git

$timec -a -o $BENCHS/bench3/time.csv make -C dklib
log_file $BENCHS/bench3/time.csv






# --------- Run further tests here -------






echo "-------------------------------------------------------------"
echo "                   Benchmarks are done !"
echo "-------------------------------------------------------------"

nb_lines=$(wc -l <$out_file)

if [ $nb_lines -eq 0 ]
then	
	# Removing conflicting lines in databases (probaly useless
	#sed -i '/^$uuid/ d' $database
	
	# Exporting results to database
	cat $out_file >> $database
	echo "" >> $database
	
	echo -e "    \033[0;32mSUCCESS !\033[0m"
	echo "    Results are saved in: $out_file"
	echo "    Database was updated: $database"
else
	echo -e "    \033[0;31mFAILURE !\033[0m"
	echo "    Output file has more than 1 line."
	echo "    Something probably went wrong..."
fi

echo "-------------------------------------------------------------"
