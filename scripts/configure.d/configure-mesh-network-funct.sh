#!/usr/bin/env bash

# configure-mesh-network-funct.sh

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

append_config_interface(){
sudo tee -a "$1" << EOF > /dev/null
Interface "$BRRB_OLSRD_INTERFACE"
{
}
EOF
}

write_config_top(){
sudo tee "$1" << EOF > /dev/null
MainIp $BRRB_OLSRD_MAIN_IP

LoadPlugin "/usr/lib/olsrd_jsoninfo.so.1.1" {
}
EOF

}
