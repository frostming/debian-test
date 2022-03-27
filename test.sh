#!/bin/bash

set -eo pipefail

python_version=$1
python="python${python_version}"
pip="pip${python_version}"

log() {
    local line="$1"

    echo "-- $line"
}


install_python() {
    apt update > /dev/null
    local python="$1"
    if apt install -y "$python" > /dev/null; then
        echo "  Installed $python from system packages"
    else
        apt install -y software-properties-common gnupg > /dev/null
        add-apt-repository ppa:deadsnakes/ppa > /dev/null
        apt-get update > /dev/null
        apt install -y "$python" > /dev/null
        echo "  Installed $python from ppa"
    fi
}

install_pip() {
    # Install pip
    if apt install -y "${python}-pip" > /dev/null; then
        echo "  Installed pip from apt"
    else
        apt install -y curl > /dev/null
        curl https://bootstrap.pypa.io/get-pip.py | "$python" - > /dev/null
        echo "  Installed pip from script"
    fi
}

if which "$python" > /dev/null; then
    echo "  $python already installed"
else
    install_python "$python"
fi
log "Installed Python:"
which "$python"
$python --version

if which "pip${python_version}" > /dev/null; then
    echo "  $pip already installed"
else
    install_pip
fi
log "Installed pip:"
"$pip" --version

"$python" << EOF
import sysconfig, distutils.sysconfig, site
from pprint import pprint

print("- sysconfig.get_paths():")
pprint(sysconfig.get_paths())
print("\n- site.getsitepackages():")
print(site.getsitepackages())
print("\n- distutils.sysconfig.get_python_lib():")
print(distutils.sysconfig.get_python_lib())
EOF


"$pip" install -U --prefix myprefix click > /dev/null
log "Installed click:"
ls -l myprefix/lib/python*/

