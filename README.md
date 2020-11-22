# Backroad Raspberry - Linux System
Backroad Raspberry is a meshed smart node for off-grid vehicles.

## Bootstrap a new instance

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

## Install and configure optional components

To install the optional Workstation components
  * cd $HOME
  * git clone https://github.com/backroadtrail/BRRB-linux.git
  * ./BRRB-linux/scripts/config-brrb.sh install workstation
  * ./BRRB-linux/scripts/config-brrb.sh configure-home workstation pi

To install the optional software Development components
  * cd $HOME
  * git clone https://github.com/backroadtrail/BRRB-linux.git
  * ./BRRB-linux/scripts/config-brrb.sh install development
  * ./BRRB-linux/scripts/config-brrb.sh configure-home development pi

To install the optional Ham radio components
  * cd $HOME
  * git clone https://github.com/backroadtrail/BRRB-linux.git
  * ./BRRB-linux/scripts/config-brrb.sh install ham
  * ./BRRB-linux/scripts/config-brrb.sh configure-home ham pi
