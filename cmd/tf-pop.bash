#! /usr/bin/env -S bash -e

f_module_main_tf() {
cat <<- EoF > main.tf
resource "" "" {
    name = var.name
}
EoF
}

f_project_main_tf() {
cat <<- EoF > main.tf
module "" {
  name   = var.name
  region = var.region

  #  source = "../../../../terraform-modules/gcp/<MODULE_PATH>"
  source = "git::git@github.com:OpenCloudSolutions/tools.git?ref=main/<MODULE_PATH>"
}
EoF
}

f_project_tfvars() {
env=$(get-env-dir)
cat <<- EoF > terraform.tfvars
project = "ocs-${env}}"

credentials = "~/.config/gcloud/configurations/oclouds-${env}-default-sa.json"

region = "us-central1"
EoF
}

f_project_backend() {
cat <<- EoF > backend.tf
terraform {
  backend "gcs" {}
}
EoF
}

f_project_version() {
cat <<- EoF > version.tf
terraform {
  required_version = "~>1.3.0"

  required_providers {
    # Hasicorp Google Provider
    google = {
      source  = "hashicorp/google"
      version = "~> 4.56.0"
    }
  }
}
EoF
}

f_project_google_provider() {
cat <<- EoF > provider.tf
provider "google" {
  credentials = file(var.credentials)
  project     = var.project
  region      = var.region
}
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

getopt_flags="b:m:p"
export backend=""
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
shift $((OPTIND - 1))

if (( module == 1 )); then
    echo -e "\U1F4C1 Populating terraform module files..."
    f_module_main_tf
    f_variables_tf
    f_project_version
    echo -e "\U1F44D Complete..."
elif (( project == 1)); then
    echo -e "\U1F4C1 Populating terraform project files..."
    f_project_main_tf
    f_project_backend
    f_project_google_provider
    f_project_tfvars
    f_variables_tf
    f_project_version
    echo -e "\U1F44D Complete..."
fi

# Format terraform files
if [[ -f version.tf ]]; then
  exec tf fmt
fi
