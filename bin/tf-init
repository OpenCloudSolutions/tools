#! /usr/bin/env -S bash -e
#
# This will be used to sync the backend with remote
# terraform state.
#
# author: Nick Sladic

terraform() {
    local version
    version=$(expand version.tf | grep "required_version =*" \
        | tr -d '[:space:]' | sed -e 's/required_version=\"~>//g' -e 's/\"//g')
    local tf_exe
    tf_exe=$(which terraform-"${version}")
    [[ -z ${tf_exe} ]] && tf_exe=terraform
    (set -x; "$tf_exe" "$@")
}

verify_file() {
    [[ ! -f $1 ]] && return 1
    return 0;
}

get_state_prefix() {
    cur_dir=$(pwd)
    prefix=""
    while [[ $cur_dir ]]; do
        if [[ (${cur_dir##*/} == dev || ${cur_dir##*/} == prod ) ]]; then
            # found current env
            env=${cur_dir##*/}
            break;
        else
            prefix="${cur_dir##*/}"/"${prefix}"
            cur_dir=${cur_dir%/*}
        fi
    done
    echo "${prefix}"
}

get_tf_var() {
    local name=${1}
    env_var=$(expand -- *.tfvars | grep -E "^${name} *=" \
    | tr -d '[:space:]' | sed -e "s/^${name} *= *//" -e "s/\"//g")
    [[ ! -z "$env_var" ]] && echo -e "$env_var"
}

prog=${0##/}

# State Bucket format
files=("main.tf" "terraform.tfvars" "variables.tf" "version.tf" "backend.tf")

for file in "${files[@]}"; do
    verify_file "$file"
    exe_status=$?
    if (( "$exe_status" == 1 )); then
        echo "$prog: file not found: $exe_status"
        break;
    fi
done

env=$(get-env-dir)
tf_init_args=()
backend=$(expand backend.tf | grep "backend *" \
        | tr -d '[:space:]' | sed -e 's/backend\"//g' -e 's/\".*//g')

echo "backend: ${backend}"
if [[ ${backend} == "gcs" ]]; then
    project=$(get_tf_var project)
    credentials=$(get_tf_var "credentials")
    # Replacing relative path with absolute
    credentials="${HOME}$(echo "${credentials}" | sed -e 's/~//g')"

    if [[ ! -f "${credentials}" ]]; then
        echo "Couldn't find credentials file: $credentials"
        exit 1
    fi
    # prepare backend-config arguments
    bucket="oclouds-${env}-tf-state"
    prefix=$(get_state_prefix)
    echo "prefix: $prefix"
    echo "bucket: $bucket"
    backend_configs=()
    backend_configs+=(--backend-config "bucket=$bucket")
    backend_configs+=(--backend-config "prefix=$prefix")
    backend_configs+=(--backend-config credentials="$credentials")
    
    # terraform version
    terraform init "${backend_configs[@]}"
fi

