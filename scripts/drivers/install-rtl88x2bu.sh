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
# Source: https://github.com/cilynx/rtl88x2bu

assert_is_raspi "$0"


cd "$HOME"
git clone --branch raspi "https://github.com/backroadtrail/rtl88x2bu.git"
cd rtl88x2bu
VER=$(sed -n 's/\PACKAGE_VERSION="\(.*\)"/\1/p' dkms.conf)
sudo rsync -rvhP ./ "/usr/src/rtl88x2bu-${VER}"
sudo dkms add -m rtl88x2bu -v "${VER}"
sudo dkms build -m rtl88x2bu -v "${VER}"
sudo dkms install -m rtl88x2bu -v "${VER}"
sudo dkms status
sudo modprobe 88x2bu

cd "$HOME"
rm -rf rtl88x2bu
