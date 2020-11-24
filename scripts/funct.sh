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

# NORMALIZED FUNCTIONS
if is_mac ;then
    install_pkgs(){
        brew update
        brew install -f "$@"
    }
elif is_pi ;then
    install_pkgs(){
        sudo apt-get update
        sudo apt-get full-upgrade -y
        sudo apt-get install -y "$@"
    }
else
    echo "Unknown OS '$(uname)' for function normalization !!!"
    exit 1
fi

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
    install_pkgs matchbox-keyboard
    set_display_overscan
    configure_miuzei
    install_miuzei_driver # THIS HAS TO  BE LAST BECAUSE IT REBOOTS
}

install_lepow() {
    set_display_overscan
}

create_metadata_file(){
if [ ! -f "$BRRB_METADATA" ]; then

sudo mkdir -p "$BRRB_HOME"
sudo tee "$BRRB_METADATA" << EOF
{
    "name": "$BRRB_NAME",
    "descr": "$BRRB_DESC",
    "hostname": "$BRRB_HOSTNAME",
    "version": "$BRRB_VERSION",
}
EOF

fi
}

## BASE SYSTEM PACKAGES
install_base() {
    echo "install_base"
    install_pkgs "${BRRB_BASE_PKGS[@]}"
    validate_base
    create_metadata_file   
}

update_base() {
    echo "Update-base isn't implemented!"
}

validate_base() {
    echo "validate_base"
    src="$HERE/../src"
    
    ( cd "$src/hello-c" || exit 1;    ./build.sh; ./test.sh; ./clean.sh ) 
    ( cd "$src/hello-c++" || exit 1;  ./build.sh; ./test.sh; ./clean.sh ) 
    ( cd "$src/hello-lisp" || exit 1;  ./build.sh; ./test.lisp; ./clean.sh ) 

}

config_home_base() { # ARGS: <user-name>
    echo "config_home_base: $1"
    run_user_script "$1" configure-quicklisp.sh 
}

# WORKSTATION PACKAGES
install_workstation(){
    install_base
    install_pkgs "${BRRB_WORKSTATION_PKGS[@]}"
    validate_workstation
    sudo jq ".development.version = \"$BRRB_VERSION\"" "$BRRB_METADATA"
}

update_workstation() {
    echo "Update-workstation isn't implemented!"
}

validate_workstation() {
    echo "validate_workstation"
}

config_home_workstation() { # ARGS: <user-name>
    echo "config_home_workstation: $1"
    run_user_script "$1" init_ssh_dir.sh 

}

# DEVELOPMENT PACKAGES
install_development(){
    install_workstation
    install_pkgs "${BRRB_DEVELOPMENT_PKGS[@]}"
    install_vscode
    install_slime
    validate_development
    sudo jq ".development.version = \"$BRRB_VERSION\"" "$BRRB_METADATA"
}

update_development() {
    echo "Update-development isn't implemented!"
}

validate_development() {
    echo "validate_development"
}

config_home_development() { # ARGS: <user-name>
    echo "config_home_development: $1"
    run_user_script "$1" configure-slime.sh 
}

# HAM RADIO PACKAGES
install_ham(){
    install_workstation
    install_pkgs "${BRRB_HAM_PKGS[@]}"
    validate_ham
    sudo jq ".ham.version = \"$BRRB_VERSION\"" "$BRRB_METADATA"
}

update_ham() {
    echo "Update-ham isn't implemented!"
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

run_user_script(){ # ARGS: <user-name> <script> [arg1 [arg2] ...]
    local_user=$1
    shift
    script=$1
    shift
    sudo su "$local_user" -c "./user-scripts/$script" "$@" 
}

install_vscode(){
    if is_mac; then
        brew update
        brew tap homebrew/cask
        brew cask install visual-studio-code
    elif is_mac; then
        wget -O vscode.deb "https://aka.ms/linux-armhf-deb"
        install_pkgs ./vscode.deb
        rm vscode.deb
    else
        echo "Unknown OS '$(uname)' for install_vscode !!!"
        exit 1
    fi
}

install_slime(){
    pushdir "$BRRB_HOME"
    sudo git clone "https://github.com/slime/slime.git" 
    popdir
}


