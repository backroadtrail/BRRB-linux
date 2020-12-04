#!/usr/bin/env bash

# install-devel-bundles.sh

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

# BASE
if [ ! -f "$BRRB_METADATA" ]; then
    ../configure.sh base install
elif ! is_bundle_installed "base"; then
    ../configure.sh base install
elif ! is_bundle_current "base"; then
    ../configure.sh base upgrade
fi
../configure.sh base cfg-user "$USER"

# WORKSTATION
if ! is_bundle_installed "workstation"; then
    ../configure.sh workstation install
elif ! is_bundle_current "workstation"; then
    ../configure.sh workstation upgrade
fi
../configure.sh workstation cfg-user "$USER"

#DEVELOPMENT
if ! is_bundle_installed "development"; then
    ../configure.sh development install
elif ! is_bundle_current "development"; then
    ../configure.sh development upgrade
fi
../configure.sh development cfg-user "$USER"
