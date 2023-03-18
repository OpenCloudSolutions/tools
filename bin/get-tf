#! /usr/bin/env -S bash -e

prog="${0##*/}"

usage="\
        ${prog} -v <TERRAFORM_VERSION> [v,d]

        -v      The specified version of terraform to retrieve (REQUIRED)
        -h      Display usage (OPTIONAL)
        -d      Sets debugger (OPTIONAL)
        -a      Installs ARM binary (default x86)
        -p      Path to install the binary to (default /usr/local/bin)
"

perequisites() {

    if [[ ! -f $(which wget) ]]; then
        echo "${prog}: \"wget\" not installed, please install wget before running this againt" >&2
        exit 1
    fi

    if [[ ! -f $(which gpg) ]]; then
        echo "${prog}: \"gpg\" not installed, please install gpg before running this againt" >&2
        exit 1
    fi

    if [[ ! -f $(which unzip) ]]; then
        echo "${prog}: \"unzip\" not installed, please install unzip before running this againt" >&2
        exit 1
    fi
}

optstrings="v:p:ahd"
export debug=0
export version=0
export amd=0
export binary_path="/usr/local/bin"
while getopts "${optstrings}" OPT; do
    case "$OPT" in 
        v)
            version="$OPTARG"
            ;;
        d)
            debug=1
            set -x
            ;;
        h)
            echo "$usage" >&2
            exit 0
            ;;
        p)
            binary_path="$OPTARG"
            ;;
        *)
            echo "$usage" >&2
            exit 0
            ;;
    esac
done
shift $(("$OPTIND" - 1))

if (( "$version" == 0 )); then
    echo "Please provide a valid terraform version"
    exit 2;
fi
# Check prereqs
perequisites

# Find out what machine type is being used
if [[ $(uname -o) == "Darwin" ]]; then
    os="darwin"
elif [[ $(uname -o) == "linux" ]]; then
    os="linux"
fi

if [[ $(uname -m ) == "x86_64" ]]; then
    machine_type="amd64"
elif [[ $(uname -o) == "arm" ]]; then
    machine_type="arm"
fi



# prepare install directory
tmp_dir="/tmp/${prog}.$$"
# set up a command to run on signal to ensure directory clean up
trap "rm -rf ${tmp_dir:?}" 0
mkdir -p "${tmp_dir}"

pushd "${tmp_dir}" &> /dev/null
terraform_fn="terraform-${version%.*}"
# terraform links
pushd "${tmp_dir}" &> /dev/null

if (( "$debug" == 0)); then
    echo "$machine_type"
    echo "$os"
    echo "$tmp_dir"
    echo "$terraform_fn"
fi

set -x

wget \
"https://releases.hashicorp.com/terraform/${version}/terraform_${version}_${os}_${machine_type}.zip" \
"https://releases.hashicorp.com/terraform/${version}/terraform_${version}_SHA256SUMS" \
"https://releases.hashicorp.com/terraform/${version}/terraform_${version}_SHA256SUMS.sig" \

hashicorp_finger_print="C874011F0AB405110D02105534365D9472D7468F"
actual_hashicorp_finger_print="$(gpg --fingerprint security@hashicorp.com | head -2 | tail -1 | tr -d '[:space:]')"

if [[ "${hashicorp_finger_print}" != "${actual_hashicorp_finger_print}" ]]; then
    echo "Invalid hashicorp fingerprints" >&2
    exit 2
fi

wget -O hashicorp.asc "https://keybase.io/hashicorp/key.asc"

# import public key
gpg --import hashicorp.asc

# verify checksunms
gpg --verify "terraform_${version}_SHA256SUMS.sig" "terraform_${version}_SHA256SUMS"

# Check shasums
shasum -a 256 -c --ignore-missing -q "terraform_${version}_SHA256SUMS"

# Unzip the binary
unzip "terraform_${version}_${os}_${machine_type}.zip"

# Copy to an active /bin directory
if [[ -d "${binary_path}" && -f terraform ]]; then
    echo "Saving terraform binary as ${terraform_fn} to ${binary_path}"
    cp -c ./terraform "${binary_path}/${terraform_fn}"
else
    exit 3
fi 

exit 0
