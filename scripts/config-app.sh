#!/usr/bin/env bash

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

# BASE FIRST
./config-base.sh

if is_pi4; then
    echo "Configuring Pi 4 application instance."
    # SET HOSTNAME
    echo "app" | sudo tee /etc/hostname
    # INSTALL APPS
    sudo apt-get install -y pulseaudio pulseaudio-module-bluetooth
    sudo apt-get install -y chirp
    # THIS HAS TO  BE LAST BECAUSE IT REBOOTS
    install_lcd_driver 
fi

if is_macos; then
    echo "Configuring MacOS application instance."
fi


