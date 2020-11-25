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
cd "$HERE"
source "config.sh"
source "funct.sh"
##


usage_config_brrb(){
    echo "Usage: $0 <command> [arg1 [arg2] ... ]"
    echo "Where: command = (install | validate | config-home)"
    exit 1
}

usage_install(){
    echo "Usage: install (base | workstation | development | ham)"
    exit 1
}

usage_update(){
    echo "Usage: update (base | workstation | development | ham)"
    exit 1
}

usage_validate(){
    echo "Usage: validate (base | workstation | development | ham)"
    exit 1
}

usage_config_home(){
    echo "Usage: $0 config-home (base | workstation | development | ham | add-ssh-host) [<user-name>]"
    exit 1
}

usage_config_home_add_ssh_host(){
    echo "Usage: $0 config-home add-ssh-host <local-user> <host> [-send-key] [<remote-user> [<id-file>]] "
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

do_update(){
    if [  $# -eq 1 ]; then
        echo UPDATE "$@"
    else
        echo "Invalid number of arguments !!!"
        usage_update
    fi 


    case $1 in

        base)
            update_base        
            ;;

        workstation)
            update_workstation        
            ;;

        development)
            update_development
            ;;

        ham)
            update_ham
            ;;

        *)
            echo "Invalid argument: $1"
            usage_update
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

    if [  $# -ge 1 ]; then
        echo CONFIG-HOME "$@"
    else
        echo "Invalid number of arguments !!!"
        usage_config_home
    fi 

    # USER
    if [  $# -ge 2 ]; then
        user="$2"
    else
        user="$USER"
    fi

    case $1 in

        base)
            config_home_base "$user"        
            ;;

        workstation)
            config_home_workstation "$user"       
            ;;

        development)
            config_home_development "$user" 
            ;;

        ham)
            config_home_ham "$user" 
            ;;
        
        add-ssh-host)  # ARGS: <local-user> <host> [-send-key] [<remote-user> [<id-file>]]
           if [  $# -ge 3 ]; then
                shift
                local_user=$1
                shift
                run_user_script "$local_user" add-ssh-host.sh "$@"
            else
                echo "Invalid number of arguments !!!"
                usage_config_home_add_ssh_host
            fi 
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
    usage_config_brrb
fi 

case $command in

    install)
        shift
        do_install "$@"    
        ;;

    update)
        shift
        do_update "$@"    
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
        usage_config_brrb
        ;;
esac



