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

is_macos(){
    [ "$(uname)" = 'Darwin' ]
}

is_raspi(){
    [ "$(uname)" = 'Linux' ]
}

#### COMMON CONSTANTS
export BRRB_HOME="/opt/brrb"
export BRRB_FILES_DIR="$BRRB_HOME/files"
export BRRB_METADATA="$BRRB_HOME/metadata.json"
export BRRB_TEMP_DIR="/var/tmp"
export BRRB_OLSRD_CONFIG_DIR="/etc/olsrd"
export BRRB_DEFAULT_DIR="/etc/default"
export BRRB_DHCP_DIR="/etc/dhcp"
export BRRB_DHCPCD_DIR="/etc"
export BRRB_DNSMASQ_DIR="/etc"
export BRRB_SYSCTL_DIR="/etc/sysctl.d"
export BRRB_HOSTAPD_DIR="/etc/hostapd"
export BRRB_INTERFACES_DIR="/etc/network/interfaces.d"

export BRRB_REPO_ROOT
BRRB_REPO_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../" && pwd )"

#### OS ABSTRACTED CONSTANTS
if is_macos ;then
	export BRRB_PROJECT_FILES_DIR="$BRRB_REPO_ROOT/files/macos"
	export BRRB_BASE_PKGS=(jq dcfldd rlwrap zip cmake sbcl node)
	export BRRB_WORKSTATION_PKGS=(tmux mosh)
	export BRRB_DEVELOPMENT_PKGS=(shellcheck emacs f3)
	export BRRB_HAM_RADIO_PKGS=(chirp)

elif is_raspi ;then
	export BRRB_PROJECT_FILES_DIR="$BRRB_REPO_ROOT/files/raspi"
	export BRRB_BASE_PKGS=(exfat-fuse exfat-utils jq dcfldd rlwrap zip g++ cmake sbcl nodejs build-essential dkms)
	export BRRB_WORKSTATION_PKGS=(claws-mail pulseaudio pulseaudio-module-bluetooth tmux mosh ssh-askpass)
	export BRRB_DEVELOPMENT_PKGS=(shellcheck rpi-imager emacs f3)
	export BRRB_HAM_RADIO_PKGS=(chirp)
	export BRRB_MESH_OLSRD_PKGS=(olsrd olsrd-gui olsrd-plugins)
	export BRRB_ACCESS_POINT_PKGS=(hostapd dnsmasq dnsutils netfilter-persistent iptables-persistent)
else
	echo "Unknown OS '$(uname)' to abstract constants !!!"
	exit 1
fi

get_version(){
	branch="$(git rev-parse --abbrev-ref HEAD 2> /dev/null)"
	if [ "$branch" = 'master' ];then
		git describe 2> /dev/null
	else
		echo "$branch"
	fi
}

export BRRB_VERSION
BRRB_VERSION="$(get_version)"






