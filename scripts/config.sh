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

export BRRB_VERSION_MAJOR="1"
export BRRB_VERSION_MINOR="1"
export BRRB_VERSION_PATCH="1"

export BRRB_HOSTNAME="brrb"
export BRRB_DISPLAY_NAME="Backroad Raspberry"
export BRRB_DISPLAY_DESC="Backroad Raspberry is a meshed smart node for off-grid vehicles."

#########################
# EDIT ABOVE ONLY
#########################
export BRRB_VERSION="V$BRRB_VERSION_MAJOR.$BRRB_VERSION_MINOR.$BRRB_VERSION_PATCH"

export BRRB_BASE_PKGS=(exfat-fuse exfat-utils jq dcfldd rlwrap zip g++ cmake sbcl nodejs)
export BRRB_WORKSTATION_PKGS=(pulseaudio pulseaudio-module-bluetooth tmux mosh)
export BRRB_DEVELOPMENT_PKGS=(shellcheck rpi-imager emacs)
export BRRB_HAM_PKGS=(chirp)