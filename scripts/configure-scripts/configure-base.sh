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
    echo "Usage: $0 ( install | validate )"
    echo "Usage: $0 cfg-user <user-name>"
    exit 1
}

do_install(){
    install_pkgs "${BRRB_BASE_PKGS[@]}"
    validate
    create_metadata_file
    set_metadatum .base.version "$BRRB_VERSION"
}

validate(){
    src="$HERE/../../../src"
    ( cd "$src/hello-c";    ./build.sh; ./test.sh; ./clean.sh ) 
    ( cd "$src/hello-c++";  ./build.sh; ./test.sh; ./clean.sh ) 
    ( cd "$src/hello-lisp";  ./build.sh; ./test.lisp; ./clean.sh ) 
}

cfg_user() { # ARGS: <user-name>
    assert_bundle_is_current "base"
    run_as "$1" configure-user-quicklisp.sh 
}

if [  $# -lt 1 ]; then
    echo "Invalid number of arguments !!!"
    usage
fi 

case $1 in
    install)
        do_install
        ;;

    validate)
        validate
        ;;

    cfg-user)   
        if [  $# -lt 2 ]; then
            echo "Invalid number of arguments !!!"
            usage
        fi 
        cfg_user "$2"
        ;;

    *)
        echo "Invalid argument: $1"
        usage
        ;;
esac

