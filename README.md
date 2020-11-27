# Backroad Raspberry - Linux System
Backroad Raspberry is a meshed smart node for off-grid vehicles.

## Bootstrap a new Raspberry Pi OS instance

To bootstrap a Raspberry Pi 4 with a Miuzei touch LCD screen:
  * cd $HOME
  * git clone https://github.com/backroadtrail/BRRB-linux.git
  * ./BRRB-linux/scripts/bootstrap.sh miuzei
  * ./BRRB-linux/scripts/post-bootstrap.sh

To bootstrap a Raspberry Pi 4 with with a Lepow HDMI monitor:
  * cd $HOME
  * git clone https://github.com/backroadtrail/BRRB-linux.git
  * ./BRRB-linux/scripts/bootstrap.sh lepow
  * ./BRRB-linux/scripts/post-bootstrap.sh

To bootstrap a Raspberry Pi 4 with with a generic HDMI monitor:
  * cd $HOME
  * git clone https://github.com/backroadtrail/BRRB-linux.git
  * ./BRRB-linux/scripts/bootstrap.sh hdmi
  * ./BRRB-linux/scripts/post-bootstrap.sh

## Install optional components on Raspberry Pi OS and MacOS

To install the optional Workstation components
  * cd $HOME
  * git clone https://github.com/backroadtrail/BRRB-linux.git
  * ./BRRB-linux/scripts/config-brrb.sh workstation install
  * ./BRRB-linux/scripts/config-brrb.sh workstation cfg-user <user-name>

To install the optional software Development components
  * cd $HOME
  * git clone https://github.com/backroadtrail/BRRB-linux.git
  * ./BRRB-linux/scripts/config-brrb.sh development install
  * ./BRRB-linux/scripts/config-brrb.sh development cfg-user <user-name>

To install the optional Ham Radio components
  * cd $HOME
  * git clone https://github.com/backroadtrail/BRRB-linux.git
  * ./BRRB-linux/scripts/config-brrb.sh ham-radio install
  * ./BRRB-linux/scripts/config-brrb.sh ham-radio cfg-user <user-name>

To install the optional Mesh Network components
  * cd $HOME
  * git clone https://github.com/backroadtrail/BRRB-linux.git
  * ./BRRB-linux/scripts/config-brrb.sh mesh-network install
  * ./BRRB-linux/scripts/config-brrb.sh mesh-network cfg-user <user-name>
