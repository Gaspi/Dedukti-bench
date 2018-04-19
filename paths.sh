#!/bin/bash

# Number of bench expected
benchs_required=5

# Separator between fields of the csv database
sep='|'

# Main database file where the bench resuts should be pushed
database=~/bench.csv

# Source folder for dedukti
sources_folder=dedukti

# Folder for the several bench auxiliary files
benchs_folder=benchs

# File with the list of commits to run the bench on
whitelist=$dir/whitelist


#########################################
#                                       #
#     Modify below at your own risk     #
#                                       #
#########################################

# Version of this script
script_version=0.1

# Number of different bench available
nb_benchs=5

# First fields, general information
base_fields="bench_version bench_timestamp bench_argument commit_hash commit_timestamp"

# Time and memory usage fields for each different bench
bench_fields="real_time user_time kernel_time max_memory mean_memory swaps status"

# Auxiliary csv output this contains the whole row to be added.
# It is overwritten at each run.
out_file=$dir/out.csv

# Path to bench folder
BENCHS=$dir/$benchs_folder/

# Path to source folder
SOURCES=$dir/$sources_folder/
