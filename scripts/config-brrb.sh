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
cd "$HERE"
source "config.sh"
source "funct.sh"
##


usage(){
    echo "Usage: $0 <command> [arg1 [arg2] ... ]"
    echo "Where: command = (install | validate | config-home)"
    exit 1
}

usage_install(){
    echo "Usage: install (base | workstation | development | ham)"
    exit 1
}

usage_validate(){
    echo "Usage: validate (base | workstation | development | ham)"
    exit 1
}

usage_config_home(){
    echo "Usage: $0 config-home (base | workstation | development | ham) <user-name>"
    exit 1
}

do_install(){
    if [  $# -eq 1 ]; then
        echo INSTALL "$@"
    else
        echo "Invalid number of arguments !!!"
        usage_install
    fi 


    case $1 in

        base)
            install_base        
            ;;

        workstation)
            install_workstation        
            ;;

        development)
            install_development
            ;;

        ham)
            install_ham
            ;;

        *)
            echo "Invalid argument: $1"
            usage_install
            ;;
    esac
}

do_validate(){

    if [  $# -eq 1 ]; then
        echo VALIDATE "$@"
    else
        echo "Invalid number of arguments !!!"
        usage_validate
    fi 

    case $1 in

        base)
            validate_base        
            ;;

        workstation)
            validate_workstation        
            ;;

        development)
            validate_development
            ;;

        ham)
            validate_ham
            ;;

        *)
            echo "Invalid argument: $1"
            usage_validate
            ;;
    esac
}

do_config_home(){

    if [  $# -eq 2 ]; then
        echo CONFIG-HOME "$@"
    else
        echo "Invalid number of arguments !!!"
        usage_config_home
    fi 

    case $1 in

        base)
            config_home_base "$2"        
            ;;

        workstation)
            config_home_workstation "$2"        
            ;;

        development)
            config_home_development "$2" 
            ;;

        ham)
            config_home_ham "$2" 
            ;;

        *)
            echo "Invalid argument: $1"
            usage_config_home
            ;;
    esac
}

if [  $# -ge 1 ]; then
    command="$1"
else
    echo "Invalid number of arguments !!!"
    usage
fi 

case $command in

    install)
        shift
        do_install "$@"    
        ;;    

    validate)
        shift
        do_validate "$@"    
        ;;    

    config-home)
        shift
        do_config_home "$@"      
        ;;

    *)
        echo "Invalid command: $command"
        usage
        ;;
esac



