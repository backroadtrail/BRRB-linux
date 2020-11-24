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

cd "$HOME" || exit 1

usage(){
    echo "<server> [-send-key] [<remote-user> [<id-file>]]"
    echo 
    exit 1
}

append_config_user(){ # ARGS: <host> <remote-user>
tee ".ssh/config" <<EOF >/dev/null
Host $1
     User $2

EOF
}

append_config_user_id(){ # ARGS: <host> <remote-user> <id-file> 
cat >> ".ssh/config" <<EOF >/dev/null
Host $1
     User $2
     IdentityFile $3
     
EOF
}

if [  $# -lt 1 ]; then
    echo "Invalid number of arguments !!!"
    usage
fi

# HOST 
host="$1"

# SEND KEY?
if [  $# -ge 2 ] && [ "$2" = "-send-key" ]; then
    shift
    do_send_key=true
else
    do_send_key=false
fi

# USER
if [  $# -ge 2 ]; then
    user="$2"
    do_add_user=true
else
    user="$USER"
    do_add_user=false
fi

# ID
if [  $# -ge 3 ]; then
    id="$3"
    do_add_user_id=true
else
    id=".ssh/id_rsa"
    do_add_user_id=false
fi

# SEND PUBLIC KEY
if [ "$do_send_key" = true ]; then
    if [ ! -f "$id.pub" ]; then
        echo "The public key doesn't exist: $id.pub"
        echo -n "Would you like to create it? (y/n): "
        read -r resp
        if [ "$resp" = "y" ]; then
            ssh-keygen -y -f "$id" >"$id.pub"
            chmod 644 "$id.pub"
        fi

    fi
    ssh-copy-id -i "$id" "$user@$host"
fi

# APPEND HOST
if [ "$do_add_user_id" = true ]; then
    append_config_user_id "$host" "$user" "$id"
elif [ "$do_add_user" = true ]; then
    append_config_user "$host" "$user"
fi

echo "Added SSH configure-host entry for '$USER': $user@$host"




