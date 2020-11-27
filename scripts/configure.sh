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
cd "$HERE"
source "config.sh"
source "funct.sh"
##


usage(){
    echo "Usage: $0 <topic> [arg1 [arg2] ... ]"
    echo "Where: topic = (user | release | workstation | development | ham-radio | mesh-network)"
    exit 1
}

if [  $# -ge 1 ]; then
    topic="$1"
else
    echo "Invalid number of arguments !!!"
    usage
fi 

case $topic in
    user)
        shift
        ./user-scripts/configure "$@"    
        ;;

     release)
        shift
        ./release-scripts/configure "$@"    
        ;;

     workstation)
        shift
        ./bundle-scripts/configure-mesh-network.sh "$@"    
        ;;

     development)
        shift
        ./bundle-scripts/configure-mesh-network.sh "$@"    
        ;;

     ham-radio)
        shift
        ./bundle-scripts/configure-mesh-network.sh "$@"    
        ;;

     mesh-network)
        shift
        ./bundle-scripts/configure-mesh-network.sh "$@"    
        ;;
        
    *)
        echo "Invalid topic: $topic"
        usage
        ;;
esac



