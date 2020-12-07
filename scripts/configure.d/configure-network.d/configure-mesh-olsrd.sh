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
cd "$HERE/../.."
source "config.sh"
source "funct.sh"
cd "$HERE"
##

assert_is_raspi "$0"

usage(){
    echo "Usage: configure.sh network mesh-olsrd (install | upgrade | enable | disable)"
    echo "Usage: configure.sh network mesh-olsrd del-interface <interface-name>"
    echo "Usage: configure.sh network mesh-olsrd add-interface <interface-name> <net-mask> <ip-address>"
    exit 1
}

save_originals(){
    sudo cp -f "$BRRB_OLSRD_CONFIG_DIR/olsrd.conf" "$BRRB_OLSRD_CONFIG_DIR/olsrd.conf.original"
    sudo cp -f "$BRRB_DEFAULT_DIR/olsrd" "$BRRB_DEFAULT_DIR/olsrd.original"
}

restore_originals(){
    sudo cp -f "$BRRB_OLSRD_CONFIG_DIR/olsrd.conf.original" "$BRRB_OLSRD_CONFIG_DIR/olsrd.conf"
    sudo cp -f "$BRRB_DEFAULT_DIR/olsrd.original" "$BRRB_DEFAULT_DIR/olsrd"
}

copy_config_files(){
    sudo cp "$BRRB_PROJECT_ROOT/files/raspi/etc/olsrd/olsrd.conf" "$BRRB_OLSRD_CONFIG_DIR"
    sudo cp "$BRRB_PROJECT_ROOT/files/raspi/etc/default/olsrd" "$BRRB_DEFAULT_DIR"
}

do_install(){
    assert_install_ok "mesh_olsrd"
    assert_bundle_is_current "base"
    install_pkgs "${BRRB_MESH_OLSRD_PKGS[@]}"
    sudo systemctl disable olsrd
    sudo systemctl stop olsrd
    save_originals
    set_metadatum "network.mesh_olsrd.version" "$BRRB_VERSION"
}

do_upgrade() {
    assert_upgrade_ok "mesh_olsrd"
    upgrade_pkgs "${BRRB_MESH_OLSRD_PKGS[@]}"
    set_metadatum "network.mesh_olsrd.version" "$BRRB_VERSION"
}

add_interface(){ #ARGS: <name> <net-mask> <ip-address>
    name="$1"
    set_metadatum "network.mesh_olsrd.interface.$name.net_mask" "$2"
    set_metadatum "network.mesh_olsrd.interface.$name.ip_address" "$3"
}

del_interface(){ #ARGS: <name>
    name="$1"
    del_metadatum "network.mesh_olsrd.interface.$name"
}

append_daemon_opts(){ #ARGS: <interface-name> ...
    # shellcheck disable=SC2016
    opts='DAEMON_OPTS="-d $DEBUGLEVEL' 
    for name in "$@"; do
        opts="$opts -i $name"
    done
    opts="$opts\""

    sudo tee -a "$BRRB_OLSRD_DEFAULT_DIR/olsrd" <<< "$opts" > /dev/null
}

enable_interface(){ #ARGS: <interface-name>
    name="$1"
    net_mask="$(get_metadatum "network.mesh_olsrd.interface.$name.net_mask")"
    ip_address="$(get_metadatum "network.mesh_olsrd.interface.$name.ip_address")"

    sudo iwconfig "$name" mode Ad-Hoc
    sudo iwconfig "$name" essid "BRRB-MESH-V1"
    sudo ifconfig "$name" "$ip_address" netmask "$net_mask" up
}

do_enable(){
    assert_bundle_is_current "mesh_olsrd"
    sudo systemctl stop dhcpcd || echo "DHCP already stopped."
    sudo systemctl stop olsrd  || echo "OLSRD already stopped."
    
    copy_config_files
    sudo rfkill unblock wifi
    sudo rfkill unblock all

    if ! get_metadatum ".network.mesh_olsrd.interface | to_entries[].key" > /dev/null; then
        echo "You must add an interface first!"
        exit -1    
    fi

    names=()
    for name in $(get_metadatum "network.mesh_olsrd.interface | to_entries[].key"); do
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
    assert_bundle_is_current "mesh_olsrd"
    sudo systemctl disable olsrd
    sudo systemctl stop olsrd
    restore_originals
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

