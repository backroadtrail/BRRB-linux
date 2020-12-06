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
    echo "Usage: configure.sh mesh-network (install | enable | disable)"
    echo "Usage: configure.sh mesh-network cfg-interface <interface> <net-mask> <ip-address>"
    exit 1
}

do_install(){
    assert_install_ok "mesh_network"
    assert_bundle_is_current "base"
    install_pkgs "${BRRB_MESH_NETWORK_PKGS[@]}"

    sudo systemctl disable olsrd
    sudo systemctl stop olsrd
    
    if [ -f "$BRRB_OLSRD_CONFIG_FILE" ]; then
        sudo mv "$BRRB_OLSRD_CONFIG_FILE" "$BRRB_OLSRD_CONFIG_FILE.original"
        echo "Moved the existing config to: $BRRB_OLSRD_CONFIG_FILE.original"
    fi
    sudo cp "$HERE/../../files/raspi/etc/olsrd.brrb.config" "$BRRB_OLSRD_CONFIG_FILE"
    set_metadatum .mesh_network.version "$BRRB_VERSION"
}

cfg_interface(){ #ARGS: <interface> <net-mask> <ip-address>
    set_metadatum .mesh_network.interface "$1"
    set_metadatum .mesh_network.net_mask "$2"
    set_metadatum .mesh_network.ip_address "$3"

    sudo systemctl stop dhcpcd || echo "DHCP already stopped."
    sudo iwconfig "$1" mode Ad-Hoc
    sudo iwconfig "$1" essid "BRRB-MESH-V1"
    sudo ifconfig "$1" "$3" netmask "$2" up
    sudo systemctl start dhcpcd
}

do_enable(){
    assert_bundle_is_current "mesh_network"
    sudo systemctl enable olsrd
    sudo systemctl start olsrd
}

do_disable(){
    assert_bundle_is_current "mesh_network"
    sudo systemctl disable olsrd
    sudo systemctl stop olsrd
}

if [  $# -lt 1 ]; then
    echo "Invalid number of arguments !!!"
    usage
fi 

case $1 in
    install)
        do_install
        ;;

    cfg-interface)
        if [  $# -lt 4 ]; then
            echo "Invalid number of arguments !!!"
            usage
        fi 
        shift
        cfg-interface
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

