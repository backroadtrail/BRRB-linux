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

is_pi4() {
	[ "$(uname)" = 'Linux' ]
}

is_macos() {
	[ "$(uname)" = 'Darwin' ]
}

set_display_overscan() {
	if [ -f /boot/config.txt ]; then
		sed "s/^.*disable_overscan.*$/disable_overscan=1/g" < /boot/config.txt > /tmp/config.txt
		#mv /tmp/config.txt /boot/
	fi
}