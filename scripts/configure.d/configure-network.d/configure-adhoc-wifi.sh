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

do_install(){
    assert_install_ok "adhoc_wifi"
    assert_bundle_is_current "base"
    install_pkgs "${BRRB_ADHOC_WIFI_PKGS[@]}"
    set_metadatum .network.adhoc_wifi.version "$BRRB_VERSION"
}

do_upgrade() {
    assert_upgrade_ok "adhoc_wifi"
    upgrade_pkgs "${BRRB_ADHOC_WIFI_PKGS[@]}"
    set_metadatum .network.adhoc_wifi.version "$BRRB_VERSION"
}


do_enable(){
    assert_bundle_is_current "adhoc_wifi"
}

do_disable(){
    assert_bundle_is_current "adhoc_wifi"
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

