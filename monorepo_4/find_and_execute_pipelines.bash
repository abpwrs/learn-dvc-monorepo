#!/usr/bin/env bash
# Author: "alex"
# Date: 20230220

# args:
# 1 --
# 2 --

#if [[ $# -ne 1 ]]; then
#    echo "Usage: $0 <param-1> <param-2> ..."
#    exit
#fi


# script:

for pipeline_file in $(find . -name dvc.yaml); do
    pipeline_dir=$(dirname $pipeline_file)
    if [[ ! $pipeline_dir == '.' ]]; then
        pushd $pipeline_dir &> /dev/null
        dvc repro
        popd
    fi
done
