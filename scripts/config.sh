#!/usr/bin/env bash

# config.sh

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

export BRRB_VERSION_MAJOR="1"
export BRRB_VERSION_MINOR="2"
export BRRB_VERSION_PATCH="1"

#############################

export BRRB_HOSTNAME="brrb"
export BRRB_NAME="Backroad Raspberry"
export BRRB_DESC="Backroad Raspberry is a meshed smart node for off-grid vehicles."

#############################
# DANGER ZONE BELOW
#############################

export BRRB_VERSION="V$BRRB_VERSION_MAJOR.$BRRB_VERSION_MINOR.$BRRB_VERSION_PATCH"

# RASPBERRY PI
export BRRB_HOME_PI="/opt/brrb"
export BRRB_METADATA_PI="$BRRB_HOME_PI/metadata.json"
export BRRB_BASE_PKGS_PI=(exfat-fuse exfat-utils jq dcfldd rlwrap zip g++ cmake sbcl nodejs)
export BRRB_WORKSTATION_PKGS_PI=(pulseaudio pulseaudio-module-bluetooth tmux mosh)
export BRRB_DEVELOPMENT_PKGS_PI=(shellcheck rpi-imager emacs f3)
export BRRB_HAM_PKGS_PI=(chirp)

# MACOS
export BRRB_HOME_MAC="/opt/brrb"
export BRRB_METADATA_MAC="$BRRB_HOME_MAC/metadata.json"
export BRRB_BASE_PKGS_MAC=(jq dcfldd rlwrap zip cmake sbcl node)
export BRRB_WORKSTATION_PKGS_MAC=(tmux mosh)
export BRRB_DEVELOPMENT_PKGS_MAC=(shellcheck emacs f3)
export BRRB_HAM_PKGS_MAC=(chirp)

# NORMALIZATION TESTS
is_mac(){
    [ "$(uname)" = 'Darwin' ]
}
is_pi(){
    [ "$(uname)" = 'Linux' ]
}

# NORMALIZED CONSTANTS
if is_mac ;then
	export BRRB_HOME="$BRRB_HOME_MAC"
	export BRRB_METADATA="$BRRB_METADATA_MAC"
	export BRRB_BASE_PKGS=("${BRRB_BASE_PKGS_MAC[@]}")
	export BRRB_WORKSTATION_PKGS=("${BRRB_WORKSTATION_PKGS_MAC[@]}")
	export BRRB_DEVELOPMENT_PKGS=("${BRRB_DEVELOPMENT_PKGS_MAC[@]}")
	export BRRB_HAM_PKGS=("${BRRB_HAM_PKGS_MAC[@]}")
elif is_pi ;then
	export BRRB_HOME="$BRRB_HOME_PI"
	export BRRB_METADATA="$BRRB_METADATA_PI"
	export BRRB_BASE_PKGS=("${BRRB_BASE_PKGS_PI[@]}")
	export BRRB_WORKSTATION_PKGS=("${BRRB_WORKSTATION_PKGS_PI[@]}")
	export BRRB_DEVELOPMENT_PKGS=("${BRRB_DEVELOPMENT_PKGS_PI[@]}")
	export BRRB_HAM_PKGS=("${BRRB_HAM_PKGS_PI[@]}")
else
	echo "Unknown OS '$(uname)' for constant normalization !!!"
	exit 1
fi





