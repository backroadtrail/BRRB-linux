#!/usr/bin/env bash

# config-brrb.sh

# Copyright 2020 OpsResearch LLC
#
# This file is part of Backroad Raspberry.
#
# Backroad Raspberry is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Backroad Raspberry is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Backroad Raspberry.  If not, see <https://www.gnu.org/licenses/>.
##

# BASH BOILERPLATE
set -euo pipefail
IFS=$'\n\t'
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$HERE/.."
source "config.sh"
source "funct.sh"
cd "$HERE"
##

assert_is_raspi "$0"

usage(){
    echo "Usage: $0 install"
    exit 1
}

do_install(){
    assert_bundle_is_current "base"
    install_pkgs "${BRRB_MESH_NETWORK_PKGS[@]}"
    install-olsrd
    project_root="$(absolute_path "$HERE/../../")"
    sudo cp -f "$project_root/files/raspi/etc/olsrd/olsrd.conf" /etc/olsrd/
    sudo cp -f "$project_root/files/raspi/etc/init.d/olsrd" /etc/init.d/
    sudo chmod 755 /etc/init.d/olsrd
    sudo sysv-rc-conf --level 2345 olsrd on
    set_metadatum .mesh_network.version "$BRRB_VERSION"
}

install-olsrd(){
    pushd /var/tmp > /dev/null
    rm -rf olsrd
    git clone --branch master "https://github.com/backroadtrail/olsrd.git"
    (
        cd olsrd
        make
        sudo make install
        make libs
        sudo make libs_install
        sudo mv /usr/local/sbin/olsrd /usr/sbin/
        sudo mv /usr/local/lib/olsrd_* /usr/lib/
    )
    rm -rf olsrd
    popd > /dev/null
}

if [  $# -lt 1 ]; then
    echo "Invalid number of arguments !!!"
    usage
fi 

case $1 in
    install)
        do_install
        ;;

    *)
        echo "Invalid argument: $1"
        usage
        ;;
esac

