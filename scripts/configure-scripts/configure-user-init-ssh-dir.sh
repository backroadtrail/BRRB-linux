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
cd "$HERE/.."
source "config.sh"
source "funct.sh"
cd "$HERE"
##

cd "$HOME"

create_ssh_config(){
tee .ssh/config <<EOF >/dev/null
Host *
    ServerAliveInterval 300
    ServerAliveCountMax 2
    ForwardAgent yes
    
EOF
}

# .SSH DIR
if [ ! -d .ssh ]; then
	mkdir .ssh
	chmod 755 .ssh
fi

# KEYS
if [ -f .ssh/id_rsa ] || [ -f .ssh/id_rsa.pub ]; then
    echo "One or both keys exists, skipping key generation !!!"
else
    ssh-keygen -b 2048 -t rsa -f ".ssh/id_rsa" -q -N ""
fi

# CONFIG
if [ -f .ssh/config ]; then
    echo "Found .ssh/config, skipping creation !!!"
else
    create_ssh_config
fi

echo "Initialized the .ssh directory for '$USER'."

