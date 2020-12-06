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
source "configure.d/configure-mesh-network-funct.sh"
cd "$HERE"
##

assert_is_raspi "$0"

usage(){
    cat <<EOF
Usage: configure.sh mesh-network (install | enable | disable)
       configure.sh mesh-network configure [<interface> [<ip-address>]]
Defaults: <interface>  = "wlan"
          <ip-address> = "10.0.0.1"
EOF
    exit 1
}

do_install(){
    assert_install_ok "mesh_network"
    assert_bundle_is_current "base"
    install_pkgs "${BRRB_MESH_NETWORK_PKGS[@]}"
    install-olsrd
    project_root="$(absolute_path "$HERE/../../")"
    sudo mkdir -p "$BRRB_OLSRD_CONFIG_DIR"
    sudo cp -f "$project_root/files/raspi/etc/olsrd/olsrd.conf" "$BRRB_OLSRD_CONFIG_FILE"
    sudo cp -f "$project_root/files/raspi/etc/init.d/olsrd" "$BRRB_INIT_SCRIPT"
    sudo chmod 755 "$BRRB_INIT_SCRIPT"
    set_metadatum .mesh_network.version "$BRRB_VERSION"
}

do_enable(){
    assert_bundle_is_current "mesh_network"
    sudo sysv-rc-conf --level 2345 olsrd on
    sudo "$BRRB_INIT_SCRIPT" start
}

do_disable(){
    assert_bundle_is_current "mesh_network"
    sudo sysv-rc-conf --level 2345 olsrd off
    sudo "$BRRB_INIT_SCRIPT" stop
}

do_configure(){ # ARGS: [<interface> [<ip-address>]]
    assert_bundle_is_current "mesh_network"
    
    if [ -f "$BRRB_OLSRD_CONFIG_FILE" ]; then
        sudo mv "$BRRB_OLSRD_CONFIG_FILE" "$BRRB_OLSRD_CONFIG_FILE.bak"
        echo "Moved the existing config to: $BRRB_OLSRD_CONFIG_FILE.bak"
    fi

    if [ $# -ge 1 ]; then
        BRRB_OLSRD_INTERFACE="$1"
    else
        BRRB_OLSRD_INTERFACE="wlan0"
    fi

    if [ $# -ge 2 ]; then
        BRRB_OLSRD_MAIN_IP="$2"
    else
        BRRB_OLSRD_MAIN_IP="10.0.0.1"
    fi
    

    write_config_top "$BRRB_OLSRD_CONFIG_FILE"
    append_config_interface "$BRRB_OLSRD_CONFIG_FILE"
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

    configure)
        shift
        do_configure "$@"
        ;;

    enable)
        do_enable
        ;;

    disable)
        do_disable
        ;;

    *)
        echo "Invalid argument: $1"
        usage
        ;;
esac

