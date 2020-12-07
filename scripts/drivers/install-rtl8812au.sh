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
cd "$HERE/.."
source "config.sh"
source "funct.sh"
cd "$HERE"
##
#source: https://github.com/gnab/rtl8812au

assert_is_raspi "$0"

cd "$HOME"
git clone --branch raspi "https://github.com/backroadtrail/rtl8812au.git"
cd rtl8812au
make
sudo insmod 8812au.ko
sudo cp 8812au.ko "/lib/modules/$(uname -r)/kernel/drivers/net/wireless"
sudo depmod

DRIVER_VERSION="$(grep '#define DRIVERVERSION' include/rtw_version.h | awk '{print $3}' | tr -d v\")"
sudo mkdir -p "/usr/src/8812au-$DRIVER_VERSION"
sudo cp -r ./* "/usr/src/8812au-$DRIVER_VERSION"
sudo dkms add -m 8812au -v "$DRIVER_VERSION"
sudo dkms build -m 8812au -v "$DRIVER_VERSION"
sudo dkms install -m 8812au -v "$DRIVER_VERSION"
sudo dkms status
sudo echo 8812au | sudo tee -a /etc/modules

cd "$HOME"
#rm -rf rtl8812au
