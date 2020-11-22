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

set_display_overscan() {
    if [ -f /boot/config.txt ]; then
        sed "s/^.*disable_overscan.*$/disable_overscan=1/g" < /boot/config.txt | sudo tee /tmp/config.txt
        sudo mv -f /tmp/config.txt /boot/
    fi
}

install_miuzei_driver() {
    cd "$HOME" || exit
    sudo rm -rf LCD-show
    #git clone https://github.com/goodtft/LCD-show.git
    git clone https://github.com/backroadtrail/LCD-show.git
    chmod -R 755 LCD-show
    cd LCD-show || exit
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
    sudo apt-get install -y matchbox-keyboard
    set_display_overscan
    configure_miuzei
    install_miuzei_driver # THIS HAS TO  BE LAST BECAUSE IT REBOOTS
}

install_lepow() {
    set_display_overscan
}


## BASE SYSTEM PACKAGES
install_base() {
    echo "install_base"
    sudo apt-get update
    sudo apt-get full-upgrade -y
    sudo apt-get install -y "${BRRB_BASE_PKGS[@]}"
    validate_base
}

validate_base() {
    echo "validate_base"
}

config_home_base() { # ARGS: <user-name>
    echo "config_home_base: $1"

}

# WORKSTATION PACKAGES
install_workstation(){
    install_base
    sudo apt-get install -y "${BRRB_WORKSTATION_PKGS[@]}"
    validate_workstation
}

validate_workstation() {
    echo "validate_workstation"
}

config_home_workstation() { # ARGS: <user-name>
    echo "config_home_workstation: $1"
    create_ssh_keys "$1"

}

# DEVELOPMENT PACKAGES
install_development(){
    install_workstation
    sudo apt-get install -y "${BRRB_DEVELOPMENT_PKGS[@]}"
    validate_development
}

validate_development() {
    echo "validate_development"
    # TEST C++
    cd "$HERE/../src/hello-world" || exit 1
    build_cmake
    ./build/hello-world
    rm -rf build
}

config_home_development() { # ARGS: <user-name>
    echo "config_home_development: $1"
}

# HAM RADIO PACKAGES
install_ham(){
    install_workstation
    sudo apt-get install -y "${BRRB_HAM_PKGS[@]}"
    validate_ham
}

validate_ham() {
    echo "validate_ham"
}

config_home_ham() { # ARGS: <user-name>
    echo "config_home_ham: $1"
}

umount_safe(){
    if grep "$1" < /proc/mounts; then
        umount "$1"
        sleep 5
    fi
}

build_cmake(){
    mkdir -p build
    pushd build || exit 1
    cmake ..
    make
    popd || exit 1
}

create_ssh_keys(){ # ARGS: <user-name>

    home_dir="/home/$1"
    
    if [ ! -d "$home_dir" ]; then
        echo "The home directory doesn't exist: $home_dir"
        exit 1
    fi

    ssh_dir="$home_dir/.ssh"

    if [ ! -d "$ssh_dir" ]; then
        sudo mkdir "$ssh_dir"
        sudo chown "$1:$1" "$ssh_dir"
        sudo chmod 700 "$ssh_dir"
    fi

    if [ -f "$ssh_dir/id_rsa" ] || [ -f "$ssh_dir/id_rsa.pub" ]; then
        echo "Skipping key generation because at l;east one of the keys exist!"
    else
        ssh-keygen -b 2048 -t rsa -f "$ssh_dir/id_rsa" -q -N ""
        sudo chown "$1:$1" "$ssh_dir/id_rsa"
        sudo chmod 600 "$ssh_dir/id_rsa"
        sudo chown "$1:$1" "$ssh_dir/id_rsa.pub"
        sudo chmod 600 "$ssh_dir/id_rsa.pub"
    fi
}

