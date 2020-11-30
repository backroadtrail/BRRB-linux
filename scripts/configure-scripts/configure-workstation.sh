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

usage(){
    echo "Usage: configure.sh workstation install"
    echo "Usage: configure.sh workstation cfg-user <user-name> [<ssh-passphrase>]"
    echo "Usage: configure.sh workstation add-ssh-host <user-name> <server> [-send-key] [<remote-user> [<id-file>]]"
    exit 1
}

if [  $# -lt 1 ]; then
    echo "Invalid number of arguments !!!"
    usage
fi 

do_install() {
    assert_update_instead "workstation"
    assert_bundle_is_current "base"
    install_pkgs "${BRRB_WORKSTATION_PKGS[@]}"
    set_metadatum .workstation.version "$BRRB_VERSION"
}

cfg_user() { # ARGS: <user-name>
    assert_bundle_is_current "workstation"
    run_as "$1" "$HERE/configure-user-init-ssh-dir.sh" 
}

add-ssh-host() { # ARGS: <user-name> <server> [-send-key] [<remote-user> [<id-file>]]
    assert_bundle_is_current "workstation"
    user="$1"
    shift
    run_as "$user" "$HERE/configure-user-add-ssh-host.sh" "$@" 
}

case $1 in
    install)
        do_install
        ;;

    cfg-user)   
        if [  $# -lt 2 ]; then
            echo "Invalid number of arguments !!!"
            usage
        fi 
        shift
        cfg_user "$@"
        ;;
    
    add-ssh-host)   
        if [  $# -lt 3 ]; then
            echo "Invalid number of arguments !!!"
            usage
        fi 
        shift
        add-ssh-host "$@"
        ;;

    *)
        echo "Invalid argument: $1"
        usage
        ;;
esac

