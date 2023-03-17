#! /usr/bin/env -S bash -e
#
# This is a terraform wrapper that adds some flexibility
# to the open cloud solution's projects. It ensures the
# current directory has the correct version of terraform
# It also sets the proper project credentials relative path
#
# author: Nick Sladic

prog=${0##*/}

# Retrieve the defined terraform version
version=$(expand *.tf | grep "required_version =*" \
    | tr -d '[:space:]' | sed -e 's/required_version=\"~>//g' -e 's/\"//g')

if [[ -z "${version}" ]]; then 
    echo "${prog}: couldn't find any terraform files" >&2
    exit 1;
fi

version="${version%.*}"

if [[ ! -f $(which "terraform-${version}") ]]; then
    echo "Required terraform-${version} not found. Use \"get-tf\" to download terraform" >&2
    exit 2
fi

# Check for the specific "version" defined in the version file
if [[ -z $(which "terraform-${version}" | :) ]]; then
        tf_exe=$(which "terraform-${version}")
        exec $tf_exe "$@"
fi
