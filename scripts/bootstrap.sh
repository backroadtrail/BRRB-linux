#!/usr/bin/env bash

# bootstrap.sh

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
cd "$HERE"
source "config.sh"
source "funct.sh"
##

assert_is_raspi "$0"

usage(){
    echo "Usage: $0 <display>"
    echo "Where: display = ( miuzei | lepow | hdmi )"
    exit 1
}

if [  $# -eq 1 ]; then
    display="$1"
else
    usage
fi 

# HOSTNAME
echo "$BRRB_HOSTNAME" | sudo tee /etc/hostname

./configure.sh base install
set_metadatum .display "$display"
./configure.sh base cfg-user "$USER"


# DISPLAY
case $display in

    miuzei)
        install_miuzei_and_reboot        
        ;;

    lepow)
        install_lepow
        sudo reboot
        ;;

    hdmi)
        sudo reboot
        ;;

    *)
        echo "Unknown display: $display"
        exit 1
        ;;
esac


