#!/usr/bin/env bash

# configure-access-point.sh

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
    echo "Usage: configure.sh network access-point (install | upgrade | enable | disable)"
    exit 1
}

save_originals(){
    sudo cp -f "$BRRB_DNSMASQ_DIR/dnsmasq.conf" "$BRRB_DNSMASQ_DIR/dnsmasq.conf.original"
}

restore_originals(){
    sudo rm -f "$BRRB_INTERFACES_DIR/wlan0"
    sudp cp -f "$BRRB_DNSMASQ_DIR/dnsmasq.conf.original" "$BRRB_DNSMASQ_DIR/dnsmasq.conf"
}

copy_config_files(){
    sudo cp -f "$BRRB_PROJECT_ROOT/files/raspi/etc/network/interfaces.d/wlan0" "$BRRB_INTERFACES_DIR"
    sudo cp -f "$BRRB_PROJECT_ROOT/files/raspi/etc/dnsmasq.conf" "$BRRB_DNSMASQ_DIR"
}

do_install(){
    assert_install_ok "network.access_point"
    assert_bundle_is_current "base"
    install_pkgs "${BRRB_ADHOC_WIFI_PKGS[@]}"
    save_originals
    sudo systemctl disable dnsmasq
    sudo systemctl stop dnsmasq
    set_metadatum ".network.access_point.version" "$BRRB_VERSION"
}

do_upgrade() {
    assert_upgrade_ok "network.access_point"
    upgrade_pkgs "${BRRB_ADHOC_WIFI_PKGS[@]}"
    set_metadatum ".network.access_point.version" "$BRRB_VERSION"
}

do_enable(){
    assert_bundle_is_current "network.access_point"
    copy_config_files
    sudo systemctl enable dnsmasq
    sudo systemctl start dnsmasq
    # A reboot is needed
}

do_disable(){
    assert_bundle_is_current "network.access_point"
    sudo systemctl disable dnsmasq
    sudo systemctl stop dnsmasq
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

