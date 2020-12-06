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

is_macos(){
    [ "$(uname)" = 'Darwin' ]
}

is_raspi(){
    [ "$(uname)" = 'Linux' ]
}

#### COMMON CONSTANTS
export BRRB_HOME="/opt/brrb"
export BRRB_METADATA="$BRRB_HOME/metadata.json"
export BRRB_TEMP_DIR="/var/tmp"
export BRRB_OLSRD_CONFIG_DIR="/etc/olsrd"
export BRRB_OLSRD_DEFAULT_DIR="/etc/default"

#### OS ABSTRACTED CONSTANTS
if is_macos ;then
	export BRRB_BASE_PKGS=(jq dcfldd rlwrap zip cmake sbcl node)
	export BRRB_WORKSTATION_PKGS=(tmux mosh)
	export BRRB_DEVELOPMENT_PKGS=(shellcheck emacs f3)
	export BRRB_HAM_RADIO_PKGS=(chirp)

elif is_raspi ;then
	export BRRB_BASE_PKGS=(exfat-fuse exfat-utils jq dcfldd rlwrap zip g++ cmake sbcl nodejs)
	export BRRB_WORKSTATION_PKGS=(claws-mail pulseaudio pulseaudio-module-bluetooth tmux mosh ssh-askpass)
	export BRRB_DEVELOPMENT_PKGS=(shellcheck rpi-imager emacs f3)
	export BRRB_HAM_RADIO_PKGS=(chirp)
	export BRRB_MESH_NETWORK_PKGS=(olsrd olsrd-gui olsrd-plugins)
else
	echo "Unknown OS '$(uname)' to abstract constants !!!"
	exit 1
fi





