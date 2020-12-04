#!/usr/bin/env bash

# funct.sh

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

#### OS ABSTRACTION FUNCTIONS ####

if is_macos ;then
    install_pkgs(){
        brew update
        brew install -f "$@"
    }
    upgrade_pkgs(){
        brew update
        brew install -f "$@"
    }
elif is_raspi ;then
    install_pkgs(){
        sudo apt-get update
        sudo apt-get full-upgrade -y
        sudo apt-get install -y "$@"
    }
    upgrade_pkgs(){
        sudo apt-get update
        sudo apt-get full-upgrade -y
        sudo apt-get install -y "$@"
    }
else
    echo "Unknown OS '$(uname)' for function normalization !!!"
    exit 1
fi

run_as(){ # ARGS: <user-name> <script> [arg1 [arg2] ...]
    local_user=$1
    shift
    script=$1
    shift
    if [ "$local_user" = "$USER" ];then
        "$script" "$@"
    else
        sudo su "$local_user" -c "$script" "$@"
    fi
}

absolute_path(){
    /bin/readlink -f "$1"
}

umount_safe(){
    if grep "$1" < /proc/mounts; then
        umount "$1"
        sleep 5
    fi
}


#### DISPLAY FUNCTIONS ####

set_display_overscan() {
    if [ -f /boot/config.txt ]; then
        sed "s/^.*disable_overscan.*$/disable_overscan=1/g" < /boot/config.txt | sudo tee /tmp/config.txt >/dev/null
        sudo mv -f /tmp/config.txt /boot/
    fi
}

install_miuzei_driver() {
    cd "$HOME"
    sudo rm -rf LCD-show
    #git clone https://github.com/goodtft/LCD-show.git
    git clone https://github.com/backroadtrail/LCD-show.git
    chmod -R 755 LCD-show
    cd LCD-show
    sudo ./MPI4008-show
}

configure_miuzei() {
    if [ -f /boot/config.txt ]; then
        sed 's/^\(dtoverlay.*\)$/#\1/g' < /boot/config.txt | \
            sed 's/^\(max_framebuffers.*\)$/#\1/g' | \
            sudo tee /tmp/config.txt
        sudo mv -f /tmp/config.txt /boot/
        echo "hdmi_group=2" | sudo tee -a /boot/config.txt
        echo "hdmi_mode=87" | sudo tee -a /boot/config.txt
        echo "display_rotate=3"| sudo tee -a /boot/config.txt
        echo "hdmi_cvt 480 800 60 6 0 0 0" | sudo tee -a /boot/config.txt
    fi
}

install_miuzei_and_reboot() {
    install_pkgs matchbox-keyboard
    set_display_overscan
    configure_miuzei
    install_miuzei_driver # THIS HAS TO  BE LAST BECAUSE IT REBOOTS
}

install_lepow() {
    set_display_overscan
}

#### BRRB METADATA FUNCTIONS ####

set_metadatum(){ # ARGS: <json-path> <value>
    jq "$1 = \"$2\"" "$BRRB_METADATA" | sudo tee "$BRRB_METADATA.tmp" >/dev/null
    sudo mv "$BRRB_METADATA.tmp" "$BRRB_METADATA"
}

get_metadatum(){ # ARGS: <json-path>
    jq -r "$1" "$BRRB_METADATA"
}

is_bundle_installed(){ # ARGS: <bundle-name>
    [ ! "$(get_metadatum ".$1")" = 'null' ]
}

assert_bundle_is_installed(){
    if ! is_bundle_installed "$1"; then
        echo "!!! The required bundle isn't installed: $1"
        exit 1
    fi
}

assert_install_ok(){
    if is_bundle_installed "$1"; then
        echo "!!! The bundle is already installed, upgrade it instead: $1"
        exit 1
    fi
}

assert_upgrade_ok(){
    if ! is_bundle_installed "$1"; then
        echo "!!! The bundle is alrnoteady installed, install it instead: $1"
        exit 1
    fi
}

is_bundle_current(){ # ARGS: <bundle-name>
    [ "$(get_metadatum ".$1.version")" = "$BRRB_VERSION" ]
}

assert_bundle_is_current(){
    assert_bundle_is_installed "$1"
    if ! is_bundle_current "$1"; then
        echo "!!! The bundle's version isn't current: $1"
        echo "!!! bundle: $(get_metadatum ".$1.version") current: $BRRB_VERSION"
        exit 1
    fi
}

create_metadata_file(){
if [ ! -f "$BRRB_METADATA" ]; then

sudo mkdir -p "$BRRB_HOME"
sudo tee "$BRRB_METADATA" <<EOF >/dev/null
{
    "name": "$BRRB_NAME",
    "descr": "$BRRB_DESC",
    "hostname": "$BRRB_HOSTNAME",
    "version": "$BRRB_VERSION"
}
EOF

fi
}
