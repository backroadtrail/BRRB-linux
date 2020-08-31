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
    echo "Usage: $0 <disk-device> <image-directory> <version> <type>"
    exit 1
}

if [  $# -ne 4 ]; then
	usage
fi 

# ARGUMENTS
disk="$1"
image_dir="$2"
version="$3"
type="$4"

export image_base="backroad-raspberry-${version}-${type}"

#./reset-root-expansion.sh
./set-version.sh "$version" "$type"
./shrink-disk.sh "$disk"
./create-disk-image.sh "$disk" "$image_dir" "$image_base"







