#! /usr/local/env -S bash -e

f_module_main_tf() {
cat <<- EoF > main.tf 
resource "" "" {
    name = var.name
}
EoF
}

f_tfvars() {
cat <<- EoF > main.tf
    project = "ocs-dev"

    credentials = "~/.config/gcloud/configurations/oclouds-dev-default-sa.json"

    region = "us-central1"
EoF
}

f_variables_tf() {
cat <<- EoF > variables.tf
    variable "credentials" {
        type = string
    }

    variable "project" {
        type = string
    }

    variable "region" {
        type = string
    }
EoF
}
 
prog=${0##*/}

usage="\
        ${prog} -b <BACKEND> [bmp]
        -m      Bootstrap a terraform module
        -p      Bootstrap a terraform project
        -b      Set the backend provider type for the state file
"
env=$(get-env-dir)

getopt_flags=":b:mp"
backend=""
project=0
module=0
while getopts "$getopt_flags" OPT; do
    case "$OPT" in
        b)
            backend=$OPTARG      
            ;;
        p)
            project=1
            ;;
        m)
            module=1
            ;;
        *)
            echo "$usage" >&2
            exit 1
    esac    
done
shift $(( OPTINT - 1))

project=("main.tf" "version.tf" "terraform.tfvars" "variables.tf" "version.tf" "state.tf")
module=("main.tf" "variables.tf" "version.tf")
backend="gcs"
while getopts "${getopt_flags}" OPT; do
    case $OPT in 
    b)
        backend=$OPTARG
        ;;
    *)
        echo "$usage" >&2
        exit 1
        ;;
    esac
done
shift $((OPTIND - 1))

# TODO make arguments for project & modules specific resources (instances, static ips, dns, etc)

for file in "${files[@]}"; do
    if [[ ! -e ${file} ]]; then
        echo -e "Creating... ${file}"
        touch "${file}" # creates template terraform files
    fi
done

if (( module == 1 )); then
    f_module_main_tf
    f_variables_tf
    exit 0
elif (( project == 1)); then
    f_project_main_tf
    exit 0;
fi
