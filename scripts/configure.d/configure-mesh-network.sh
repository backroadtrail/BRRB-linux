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
    echo "Usage: configure.sh mesh-network del-interface <interface-name>"
    echo "Usage: configure.sh mesh-network add-interface <interface-name> <net-mask> <ip-address>"
    exit 1
}

cache_config_files(){
    echo cache_config_files
    #SAVE ORIGINALS
    sudo cp -f "$BRRB_OLSRD_CONFIG_DIR/olsrd.conf" "$BRRB_OLSRD_CONFIG_DIR/olsrd.conf.original"
    sudo cp -f "$BRRB_OLSRD_DEFAULT_DIR/olsrd" "$BRRB_OLSRD_CONFIG_DIR/olsrd.original"
    #CACHE BRRB FILES
    sudo cp "$HERE/../../files/raspi/etc/olsrd/olsrd.brrb.conf" "$BRRB_OLSRD_CONFIG_DIR"
    sudo cp "$HERE/../../files/raspi/etc/default/olsrd.brrb" "$BRRB_OLSRD_DEFAULT_DIR"
}

copy_config_files(){
    echo copy_config_files
    sudo cp -f "$BRRB_OLSRD_CONFIG_DIR/olsrd.brrb.conf" "$BRRB_OLSRD_CONFIG_DIR/olsrd.conf"
    sudo cp -f "$BRRB_OLSRD_DEFAULT_DIR/olsrd.brrb" "$BRRB_OLSRD_DEFAULT_DIR/olsrd"
}

do_install(){
    assert_install_ok "mesh_network"
    assert_bundle_is_current "base"
    install_pkgs "${BRRB_MESH_NETWORK_PKGS[@]}"
    sudo systemctl disable olsrd
    sudo systemctl stop olsrd
    cache_config_files
    set_metadatum .mesh_network.version "$BRRB_VERSION"
}

do_upgrade() {
    assert_upgrade_ok "mesh_network"
    upgrade_pkgs "${BRRB_MESH_NETWORK_PKGS[@]}"
    set_metadatum .mesh_network.version "$BRRB_VERSION"
}

add_interface(){ #ARGS: <name> <net-mask> <ip-address>
    name="$1"
    set_metadatum ".mesh_network.interface.$name.net_mask" "$2"
    set_metadatum ".mesh_network.interface.$name.ip_address" "$3"
}

del_interface(){ #ARGS: <name>
    name="$1"
    del_metadatum ".mesh_network.interface.$name"
}

append_daemon_opts(){ #ARGS: <interface-name> ...

    opts='DAEMON_OPTS="-d $DEBUGLEVEL' 
    for name in "$@"; do
        echo "append_daemon_opts - Name: $name"
        opts="$opts -i $name"
    done
    opts="$opts\""

    sudo tee -a "$BRRB_OLSRD_DEFAULT_DIR/olsrd" <<< "$opts" > /dev/null
}

enable_interface(){ #ARGS: <interface-name>
    name="$1"
    echo "enable_interface - Name: $name"
    net_mask="$(get_metadatum ".mesh_network.interface.$name.net_mask")"
    ip_address="$(get_metadatum ".mesh_network.interface.$name.ip_address")"

    sudo iwconfig "$name" mode Ad-Hoc
    sudo iwconfig "$name" essid "BRRB-MESH-V1"
    sudo ifconfig "$name" "$ip_address" netmask "$net_mask" up
}

do_enable(){
    assert_bundle_is_current "mesh_network"
    sudo systemctl stop dhcpcd || echo "DHCP already stopped."
    sudo systemctl stop olsrd  || echo "OLSRD already stopped."
    
    copy_config_files

    names=()
    for name in $(get_metadatum ".mesh_network.interface | to_entries[].key"); do
        names+=("$name")
    done

    if [ ${#names[@]} -lt 1 ]; then
        echo "You must add an interface first!"
        exit -1    
    fi

    append_daemon_opts "${names[@]}"
    for name in "${names[@]}"; do
        enable_interface "$name"
    done

    sudo systemctl start dhcpcd
    sudo systemctl enable olsrd
    sudo systemctl start olsrd
}

do_disable(){
    assert_bundle_is_current "mesh_network"
    sudo systemctl disable olsrd
    sudo systemctl stop olsrd
    sudo rm -f "$BRRB_OLSRD_DEFAULT_FILE"
}

if [  $# -lt 1 ]; then
    echo "Invalid number of arguments !!!"
    usage
fi 

case $1 in
    install)
        do_install
        ;;

    upgrade)
        do_upgrade
        ;;

    add-interface)
        if [  $# -lt 4 ]; then
            echo "Invalid number of arguments !!!"
            usage
        fi 
        shift
        add_interface "$@"
        ;;

    del-interface)
        if [  $# -lt 2 ]; then
            echo "Invalid number of arguments !!!"
            usage
        fi 
        shift
        del_interface "$@"
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

