#!/bin/bash

dir=$(pwd)

while bash $dir/main.sh; do sleep 300; done
