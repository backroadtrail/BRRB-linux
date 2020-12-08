#!/usr/bin/env bash

# configure-adhoc-wifi.sh

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
    echo "Usage: configure.sh network adhoc-wifi (install | upgrade | enable | disable)"
    exit 1
}

save_originals(){
    sudo cp -f "$BRRB_DEFAULT_DIR/isc-dhcp-server" "$BRRB_DEFAULT_DIR/isc-dhcp-server.original"
    sudp cp -f "$BRRB_DHCP_DIR/dhcpd.conf" "$BRRB_DHCP_DIR/dhcpd.conf.original"
}

restore_originals(){
    sudo rm -f "$BRRB_INTERFACES_DIR/wlan0"
    sudo cp -f "$BRRB_DEFAULT_DIR/isc-dhcp-server.original" "$BRRB_DEFAULT_DIR/isc-dhcp-server"
    sudp cp -f "$BRRB_DHCP_DIR/dhcpd.conf.original" "$BRRB_DHCP_DIR/dhcpd.conf"
}

copy_config_files(){
    sudo cp -f "$BRRB_PROJECT_ROOT/files/raspi/etc/network/interfaces.d/wlan0" "$BRRB_INTERFACES_DIR"
    sudo cp -f "$BRRB_PROJECT_ROOT/files/raspi/etc/default/isc-dhcp-server" "$BRRB_DEFAULT_DIR"
    sudo cp -f "$BRRB_PROJECT_ROOT/files/raspi/etc/dhcp/dhcpd.conf" "$BRRB_DHCP_DIR"
}

do_install(){
    assert_install_ok "network.adhoc_wifi"
    assert_bundle_is_current "base"
    install_pkgs "${BRRB_ADHOC_WIFI_PKGS[@]}"
    save_originals
    sudo systemctl disable isc-dhcp-server
    sudo systemctl stop isc-dhcp-server
    set_metadatum ".network.adhoc_wifi.version" "$BRRB_VERSION"
}

do_upgrade() {
    assert_upgrade_ok "network.adhoc_wifi"
    upgrade_pkgs "${BRRB_ADHOC_WIFI_PKGS[@]}"
    set_metadatum ".network.adhoc_wifi.version" "$BRRB_VERSION"
}

do_enable(){
    assert_bundle_is_current "network.adhoc_wifi"
    copy_config_files
    sudo systemctl enable isc-dhcp-server
    sudo systemctl start isc-dhcp-server
    # A reboot is needed
}

do_disable(){
    assert_bundle_is_current "network.adhoc_wifi"
    sudo systemctl disable isc-dhcp-server
    sudo systemctl stop isc-dhcp-server
    restore_config_files
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

