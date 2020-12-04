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

export BRRB_HOSTNAME="brrb"
export BRRB_NAME="Backroad Raspberry"
export BRRB_DESC="Backroad Raspberry is a meshed smart node for off-grid vehicles."

get_version(){
	if gitdesc="$(git describe 2> /dev/null)"; then
		if [[ "$gitdesc" != *-* ]]; then
			echo "$gitdesc"
		else
			echo "development"
		fi
	else		
		echo "development"
	fi
}

export BRRB_VERSION
BRRB_VERSION="$(get_version)"

#### MACOS ####
export BRRB_HOME_MAC="/opt/brrb"
export BRRB_METADATA_MAC="$BRRB_HOME_MAC/metadata.json"

export BRRB_BASE_PKGS_MAC=(jq dcfldd rlwrap zip cmake sbcl node)
export BRRB_WORKSTATION_PKGS_MAC=(tmux mosh)
export BRRB_DEVELOPMENT_PKGS_MAC=(shellcheck emacs f3)
export BRRB_HAM_RADIO_PKGS_MAC=(chirp)

is_macos(){
    [ "$(uname)" = 'Darwin' ]
}

assert_is_macos(){
	if ! is_macos ;then
		echo "!!! This can only be executed on MacOS !!!"
OS		exit 1
	fi
}

#### RASPI ####
export BRRB_HOME_PI="/opt/brrb"
export BRRB_METADATA_PI="$BRRB_HOME_PI/metadata.json"

export BRRB_BASE_PKGS_PI=(exfat-fuse exfat-utils jq dcfldd rlwrap zip g++ cmake sbcl nodejs)
export BRRB_WORKSTATION_PKGS_PI=(claws-mail pulseaudio pulseaudio-module-bluetooth tmux mosh ssh-askpass)
export BRRB_DEVELOPMENT_PKGS_PI=(shellcheck rpi-imager emacs f3)
export BRRB_HAM_RADIO_PKGS_PI=(chirp)
export BRRB_MESH_NETWORK_PKGS_PI=(bison flex libgps-dev sysv-rc-conf)

is_raspi(){
    [ "$(uname)" = 'Linux' ]
}

assert_is_raspi(){
	if ! is_raspi ;then
		echo "!!! This can only be executed on Raspberry Pi OS !!!"
		exit 1
	fi
}

#### OS ABSTRACTED CONSTANTS
if is_macos ;then
	export BRRB_HOME="$BRRB_HOME_MAC"
	export BRRB_METADATA="$BRRB_METADATA_MAC"
	export BRRB_BASE_PKGS=("${BRRB_BASE_PKGS_MAC[@]}")
	export BRRB_WORKSTATION_PKGS=("${BRRB_WORKSTATION_PKGS_MAC[@]}")
	export BRRB_DEVELOPMENT_PKGS=("${BRRB_DEVELOPMENT_PKGS_MAC[@]}")
	export BRRB_HAM_RADIO_PKGS=("${BRRB_HAM_RADIO_PKGS_MAC[@]}")
elif is_raspi ;then
	export BRRB_HOME="$BRRB_HOME_PI"
	export BRRB_METADATA="$BRRB_METADATA_PI"
	export BRRB_BASE_PKGS=("${BRRB_BASE_PKGS_PI[@]}")
	export BRRB_WORKSTATION_PKGS=("${BRRB_WORKSTATION_PKGS_PI[@]}")
	export BRRB_DEVELOPMENT_PKGS=("${BRRB_DEVELOPMENT_PKGS_PI[@]}")
	export BRRB_HAM_RADIO_PKGS=("${BRRB_HAM_RADIO_KGS_PI[@]}")
	export BRRB_MESH_NETWORK_PKGS=("${BRRB_MESH_NETWORK_PKGS_PI[@]}")
else
	echo "Unknown OS '$(uname)' to abstract constants !!!"
	exit 1
fi





