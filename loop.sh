#!/bin/bash

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

while bash $dir/main.sh; do sleep 300; done
