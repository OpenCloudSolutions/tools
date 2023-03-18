#! /usr/bin/env -S bash -e
#
# This with get the relative hierarchal enivronment
# inside the terraform-projects
#
# This will need
#
# author: Nick Sladic

# program name
prog=${0##/}

# assuming this is run inside terraform-projects
# we can recursively loop backwards in the current
# working directory to find the root project

cur_dir=$(PWD)
env=""
# echo $cur_dir
exe_status=0
while [[ $cur_dir ]]; do
    if [[ (${cur_dir##*/} == dev || ${cur_dir##*/} == prod ) ]]; then
        # found current env
        env=${cur_dir##*/}
        exe_status=1
        cur_dir=${cur_dir%/*}
    else
        cur_dir=${cur_dir%/*}
    fi
done

if (( exe_status < 1 )); then
    exit "$exe_status"
fi

echo "${env}"

