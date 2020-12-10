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
    exit 1
}

save_originals(){
    sudo cp -f "$BRRB_OLSRD_CONFIG_DIR/olsrd.conf" "$BRRB_OLSRD_CONFIG_DIR/olsrd.conf.original"
    sudo cp -f "$BRRB_DEFAULT_DIR/olsrd" "$BRRB_DEFAULT_DIR/olsrd.original"
}

restore_originals(){
    sudo rm -f "$BRRB_INTERFACES_DIR/wlan1"
    sudo cp -f "$BRRB_OLSRD_CONFIG_DIR/olsrd.conf.original" "$BRRB_OLSRD_CONFIG_DIR/olsrd.conf"
    sudo cp -f "$BRRB_DEFAULT_DIR/olsrd.original" "$BRRB_DEFAULT_DIR/olsrd"
}

copy_config_files(){
    sudo cp -f "$BRRB_FILES_DIR/etc/network/interfaces.d/olsrd" "$BRRB_INTERFACES_DIR"
    sudo cp -f "$BRRB_FILES_DIR/etc/olsrd/olsrd.conf" "$BRRB_OLSRD_CONFIG_DIR"
    sudo cp -f "$BRRB_FILES_DIR/etc/default/olsrd" "$BRRB_DEFAULT_DIR"
}

do_install(){
    assert_install_ok "network.mesh_olsrd"
    assert_bundle_is_current "base"
    install_pkgs "${BRRB_MESH_OLSRD_PKGS[@]}"
    sudo systemctl disable olsrd
    sudo systemctl stop olsrd
    save_originals
    set_metadatum ".network.mesh_olsrd.version" "$BRRB_VERSION"
}

do_upgrade() {
    assert_upgrade_ok "network.mesh_olsrd"
    upgrade_pkgs "${BRRB_MESH_OLSRD_PKGS[@]}"
    set_metadatum ".network.mesh_olsrd.version" "$BRRB_VERSION"
}

do_enable(){
    assert_bundle_is_current "network.mesh_olsrd"
    sudo systemctl stop dhcpcd || echo "DHCP already stopped."
    sudo systemctl stop olsrd  || echo "OLSRD already stopped."
    
    copy_config_files

    sudo systemctl start dhcpcd
    sudo systemctl enable olsrd
    # A reboot is needed
}

do_disable(){
    assert_bundle_is_current "network.mesh_olsrd"
    sudo systemctl disable olsrd
    sudo systemctl stop olsrd
    restore_originals
    # A reboot is needed
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

