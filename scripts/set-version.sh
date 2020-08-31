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
    echo "Usage: $0 <version> <type> [<rootfs-mount-point>] "
    exit 1
}
if [  $# -eq 3 ]; then
	rootfs="$3"
elif [  $# -eq 2 ]; then
	rootfs=/media/pi/rootfs
else
	usage
fi 

version="$1"
type="$2"

# VALIDATE ROOTFS MOUNT
if [ ! -d "$rootfs" ]; then
    echo "The rootfs mount point does not exist: $rootfs"
    usage
fi

sudo tee "$rootfs/backroadtrail.json" << EOF
{
	"app": "backroad-raspberry",
	"name": "Backroad Raspberry",
	"version": "$version",
	"type": "$type"
}
EOF

echo "$type" | sudo tee "$rootfs/etc/hostname"



