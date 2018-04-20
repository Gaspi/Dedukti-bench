#!/bin/bash

dir=$(pwd)
source $dir/paths.sh

uuid=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
date_unix_timestamp=$(date +%s)
date=$(date -d @$date_unix_timestamp)

# If database does not exist, start by creating it.
if [ ! -f $database ]
then
	bash $dir/fresh-db.sh "$database"
fi

echo ""
echo "-------------------------------------------------------------"
echo "                       Running bench"
echo "-------------------------------------------------------------"
echo "    Bench nb: $uuid"
echo "    Date:     $date"
echo "    Revision: $1"
echo "-------------------------------------------------------------"

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


echo ""
echo "-------------------------------------------------------------"
echo "                    Bench 0 : Compilation"
echo "-------------------------------------------------------------"
$timec -a -o $SOURCES/compile.csv make
log_file $SOURCES/compile.csv


echo ""
echo "-------------------------------------------------------------"
echo "                    Bench 1 : Tests"
echo "-------------------------------------------------------------"
$timec -a -o $SOURCES/tests.csv make tests
log_file $SOURCES/tests.csv


# Exporting DKCHECK and DKDEP to be used in following tests
export DKCHECK=$SOURCES/dkcheck.native
export DKDEP=$SOURCES/dkdep.native



echo ""
echo "-------------------------------------------------------------"
echo "                    Bench 2 : Matita"
echo "-------------------------------------------------------------"
mkdir $BENCHS/matita
cd $BENCHS/matita

wget -q https://deducteam.github.io/data/libraries/matita.tar.gz
tar zxf matita.tar.gz
# Editing factorial file : turning le_fact_10 into an axiom
sed -i '30816,33252d'  matita/matita_arithmetics_factorial.dk
sed -i '30815s/.*/\./'  matita/matita_arithmetics_factorial.dk
sed -i 's/def le_fact_10 :/le_fact_10 :/'  matita/matita_arithmetics_factorial.dk

$timec -a -o $BENCHS/matita/time.csv make -C matita
log_file $BENCHS/matita/time.csv



echo ""
echo "-------------------------------------------------------------"
echo "                    Bench 3 : Matita / Factorial"
echo "-------------------------------------------------------------"
# Reextracting original matita_arithmetics_factorial.dk
tar zxf matita.tar.gz matita/matita_arithmetics_factorial.dk
rm matita/matita_arithmetics_factorial.dko

$timec -a -o $BENCHS/matita/time_fact.csv make -C matita matita_arithmetics_factorial.dko
log_file $BENCHS/matita/time_fact.csv



echo ""
echo "-------------------------------------------------------------"
echo "                    Bench 4 : Examples"
echo "-------------------------------------------------------------"
cp $BENCHS/matita/matita/Makefile $SOURCES/examples/Makefile
$timec -a -o $SOURCES/examples.csv make -C $SOURCES/examples
log_file $SOURCES/examples.csv


# Exporting DKCHECK and DKDEP to be used in following tests
export DKCHECK=$SOURCES/dkcheck.native
export DKDEP=$SOURCES/dkdep.native



echo ""
echo "-------------------------------------------------------------"
echo "                    Bench 5 : DKlib"
echo "-------------------------------------------------------------"
mkdir $BENCHS/dklib
cd $BENCHS/dklib

git clone -q -b v2.6 https://github.com/rafoo/dklib.git

$timec -a -o $BENCHS/dklib/time.csv make -C dklib
log_file $BENCHS/dklib/time.csv






# --------- Run more benches here -------






echo ""
echo "-------------------------------------------------------------"
echo "                   Benchmarks are done !"
echo "-------------------------------------------------------------"

nb_lines=$(wc -l <$out_file)

if [ $nb_lines -eq 0 ]
then
	if grep "exited with non-zero" $out_file ;
	then
		echo -e "    \033[0;31mFAILURE !\033[0m"
		echo "    Some bench exited with non-zero return code."
		echo "    Something probably went wrong..."
	else
		# Removing conflicting lines in databases (probaly useless
		#sed -i '/^$uuid/ d' $database
		
		# Exporting results to database
		cat $out_file >> $database
		echo "" >> $database
		
		echo -e "    \033[0;32mSUCCESS !\033[0m"
		echo "    Results are saved in: $out_file"
		echo "    Database was updated: $database"
	fi
else
	echo -e "    \033[0;31mFAILURE !\033[0m"
	echo "    Output file has more than 1 line."
	echo "    Something probably went wrong..."
fi

echo "-------------------------------------------------------------"
