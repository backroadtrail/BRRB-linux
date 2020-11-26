#!/usr/bin/env bash

# backup.sh

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
    echo "Usage: $0 ( copy | archive ) <output-dir> [<src-dir>...]"
    echo " Backup archives or copies the default directories in the config file to the output directory."
    echo " The output directory is excluded from the backup."
    echo " You can add additional source directories on the command line."
    exit 1
}

if [  $# -lt 2 ]; then
    echo "Invalid number of arguments !!!"
    usage
fi 

opt="$1"
shift
output="$(cd "$1"; pwd)"
shift

if [ ! -d "$output" ]; then
    echo "Can't find the output directory: $output"
fi

stamp="$(date '+%Y-%m-%d_%H-%M-%S.%N')"
dest="$output/$(hostname)_$stamp"

if [ "$opt" = 'archive' ]; then
    tar "--exclude=$output" -czf "$dest.tgz" "${BRRB_BACKUP_DIRS[@]}" "$@"
elif [ "$opt" = 'copy' ]; then
    rsync -a --exclude "$output" "$@" "${BRRB_BACKUP_DIRS[@]}" "$dest.d"
else
    echo "Invalid option: $opt" 
    exit 1
fi







