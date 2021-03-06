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

if [ -f .emacs ]; then
	echo "The file '~/.emacs' exists, skipping configuration !!!"
	exit 0
fi

sbcl_path="$(command -v  sbcl)"

tee .emacs <<EOF >/dev/null
(add-to-list 'load-path "$BRRB_HOME/slime")
(require 'slime-autoloads)
(setq inferior-lisp-program "$sbcl_path")
(load (expand-file-name "~/quicklisp/slime-helper.el"))
EOF

echo "Configured Emacs for '$USER'."





