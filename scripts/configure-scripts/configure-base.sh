#!/usr/bin/env bash

# config-brrb.sh

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

usage(){
    echo "Usage: configure.sh base ( install | upgrade | validate )"
    echo "Usage: configure.sh base (cfg-user | val_user) vi<user-name>"
    exit 1
}

do_install(){
    if [ -f "$BRRB_METADATA" ];then
        echo "The Base bundle is already installed, upgrade instead!"
        exit 1
    else
        install_pkgs "${BRRB_BASE_PKGS[@]}"
        create_metadata_file
        set_metadatum .base.version "$BRRB_VERSION"
    fi
    do_validate
}

do_upgrade(){
    assert_upgrade_ok "base"
    upgrade_pkgs "${BRRB_BASE_PKGS[@]}"
    do_validate
    set_metadatum .base.version "$BRRB_VERSION"
}

do_validate(){
    src="$HERE/../../src"
    ( cd "$src/hello-c";    ./build.sh; ./test.sh; ./clean.sh ) 
    ( cd "$src/hello-c++";  ./build.sh; ./test.sh; ./clean.sh ) 
}

cfg_user() { # ARGS: <user-name>
    assert_bundle_is_current "base"
    run_as "$1" "$HERE/configure-user-quicklisp.sh"
    val_user  "$1"
}

val_user(){ # ARGS: <user-name>
    src="$HERE/../../src"
    ( cd "$src/hello-lisp";  ./build.sh; ./test.lisp; ./clean.sh ) 
}


if [  $# -lt 1 ]; then
    echo "Invalid number of arguments !!!"
    usage
fi 

case $1 in
    install)
        do_install
        ;;

    upgrade)
        do_upgrade
        ;;

    validate)
        do_validate
        ;;

    cfg-user)   
        if [  $# -lt 2 ]; then
            echo "Invalid number of arguments !!!"
            usage
        fi 
        cfg_user "$2"
        ;;
    
    val-user)   
        if [  $# -lt 2 ]; then
            echo "Invalid number of arguments !!!"
            usage
        fi 
        val_user "$2"
        ;;

    *)
        echo "Invalid argument: $1"
        usage
        ;;
esac

