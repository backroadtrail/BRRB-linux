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
# Source: https://www.raspberrypi.org/documentation/configuration/wireless/access-point-routed.md

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
    echo "Usage: configure.sh network access-point lan <ip-address> <low-ip> <high-ip>"
    echo "Usage: configure.sh network access-point wifi <essid> <password>"
    echo "Usage: configure.sh network access-point dns <lan-domain> <brrb-name>"
    exit 1
}

save_originals(){
    sudo cp -f "$BRRB_DNSMASQ_DIR/dnsmasq.conf" "$BRRB_DNSMASQ_DIR/dnsmasq.conf.original"
}

restore_originals(){
    sudo rm -f "$BRRB_DHCPCD_DIR/dhcpcd.conf"
    sudo rm -f "$BRRB_HOSTAPD_DIR/hostapd.conf"
    sudo rm -f "$BRRB_DNSMASQ_DIR/routed-ap.conf"
    sudp cp -f "$BRRB_DNSMASQ_DIR/dnsmasq.conf.original" "$BRRB_DNSMASQ_DIR/dnsmasq.conf"
}

copy_config_files(){
    sudo cp -f "$BRRB_PROJECT_ROOT/files/raspi/etc/dhcpcd.conf" "$BRRB_DHCPCD_DIR"
    sudo cp -f "$BRRB_PROJECT_ROOT/files/raspi/etc/hostapd/hostapd.conf" "$BRRB_HOSTAPD_DIR"
    sudo cp -f "$BRRB_PROJECT_ROOT/files/raspi/etc/sysctl.d/routed-ap.conf" "$BRRB_SYSCTL_DIR"
    sudo cp -f "$BRRB_PROJECT_ROOT/files/raspi/etc/dnsmasq.conf" "$BRRB_DNSMASQ_DIR"
}

do_install(){
    assert_install_ok "network.access_point"
    assert_bundle_is_current "base"
    install_pkgs "${BRRB_ACCESS_POINT_PKGS[@]}"
    save_originals
    sudo rfkill unblock wlan
    sudo systemctl unmask dnsmasq
    sudo systemctl unmask hostapd
    sudo systemctl disable dnsmasq
    sudo systemctl stop dnsmasq
    set_metadatum ".network.access_point.version" "$BRRB_VERSION"
}

do_upgrade() {
    assert_upgrade_ok "network.access_point"
    upgrade_pkgs "${BRRB_ACCESS_POINT_PKGS[@]}"
    set_metadatum ".network.access_point.version" "$BRRB_VERSION"
}

do_enable(){
    assert_bundle_is_current "network.access_point"
    copy_config_files
    sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    sudo netfilter-persistent save
    sudo systemctl enable hostapd
    sudo systemctl start hostapd
    sudo systemctl enable dnsmasq
    sudo systemctl start dnsmasq
    # A reboot is needed
}

do_disable(){
    assert_bundle_is_current "network.access_point"
    sudo systemctl disable hostapd
    sudo systemctl stop hostapd
    sudo systemctl disable dnsmasq
    sudo systemctl stop dnsmasq 
    sudo iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
    sudo netfilter-persistent save
   
    restore_config_files
    # A reboot is needed
}

do_lan(){ #ARGS: <ip-address> <low-ip> <high-ip>
    assert_bundle_is_current "network.access_point"

    sed_file "$BRRB_PROJECT_ROOT/files/raspi/etc/dnsmasq.conf" \
      "s|dhcp-range=.*|dhcp-range=$2,$3,255.255.255.0,24h|" \
      "s|address=/(.*)/.*|address=/\\1/$1|"

    sed_file "$BRRB_PROJECT_ROOT/files/raspi/etc/dhcpcd.conf" \
      "s| static ip_address=.*| static ip_address=$1/24|"
    
}

do_wifi(){ #ARGS: <essid> <password>
    assert_bundle_is_current "network.access_point"
}

do_dns(){ #ARGS: <lan-domain> <brrb-name>
    assert_bundle_is_current "network.access_point"
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

    lan)
        if [  $# -lt 4 ]; then
          echo "Invalid number of arguments !!!"
            usage
        fi
        shift
        do_lan "$@"
        ;;

    wifi)
        if [  $# -lt 3 ]; then
          echo "Invalid number of arguments !!!"
            usage
        fi
        shift
        do_wifi "$@"
        ;;

   dns)
        if [  $# -lt 3 ]; then
          echo "Invalid number of arguments !!!"
            usage
        fi
        shift
        do_dns "$@"
        ;;

    *)
        echo "Invalid argument: $1"
        usage
        ;;
esac

