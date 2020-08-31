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

usage(){
    echo "Usage: $0 [<boot-mount-point>]"
    exit 1
}
if [  $# -eq 1 ]; then
	boot=/media/pi/boot
elif [  $# -eq 2 ]; then
	boot=/media/pi/boot
else
	usage
fi 

# VALIDATE BOOT MOUNT
if [ ! -d "$boot" ]; then
    echo "The boot mount point does not exist: $boot"
    usage
fi

# VALIDATE CMDLINE.TXT
if [ ! -f "$boot/cmdline.txt" ]; then
    echo "The cmdline.txt file does not exist: $boot/cmdline.txt"
    usage
fi

mv "$boot/cmdline.txt" "$boot/cmdline.txt.bak"
tee "$boot/cmdline.txt" <<EOF
console=serial0,115200 console=tty1 root=PARTUUID=58ce116e-02 rootfstype=ext4 elevator=deadline fsck.repair=yes rootwait quiet init=/usr/lib/raspi-config/init_resize.sh splash plymouth.ignore-serial-consoles
EOF



