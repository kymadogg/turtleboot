#!/bin/bash

# Turtleboot Lite v2.0
# Reconfiguring the network settings / regenerating SSH Key only after a microSD clone
# status --> TESTED ON TURTLEBOT3 (RPi 3B+ and RPi 4B)

# exit on errors
set -e

# variables from cl args with defaults
TURTLEBOT_NAME="turtle_boot"
ROS_ID="30"
REBUILD="false"
REBOOT="false"

# handling cli args
while [[ $# -gt 0 ]]; do
    case $1 in
        --name|-n)
            TURTLEBOT_NAME="$2"
            shift 2
            ;;
        --ros-id|-id)
            ROS_ID="$2"
            shift 2
            ;;
        --rebuild)
            REBUILD="true"
            shift
            ;;
        --wifi)
            WIFI="true"
            shift
            ;;
        --reboot)
            REBOOT="true"
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [--name|-n NAME] [--ros-id|-id ID] [--rebuild| None] [--reboot| None]"
            exit 0
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
done

# fun ascii art :)
cat << "EOF"
 _____           _   _      ____              _   
|_   _|   _ _ __| |_| | ___| __ )  ___   ___ | |_ 
  | || | | | '__| __| |/ _ \  _ \ / _ \ / _ \| __|
  | || |_| | |  | |_| |  __/ |_) | (_) | (_) | |_ 
  |_| \__,_|_|   \__|_|\___|____/ \___/ \___/ \__|
            L      I       T       E
                   _____     ____
                 /      \  |  o | 
                |        |/ ___\| 
                |_________/     
                |_|_| |_|_|
EOF

echo "Welcome to TurtleBoot Lite!"
echo "developed by @kymadogg"

# confirm args
echo "TurtleBot Name: $TURTLEBOT_NAME"
echo "Rebuild flag: $REBUILD, Reboot flag: $REBOOT"
echo "ROS Domain ID: $ROS_ID"

# ask for password once
sudo -v
while true; do sudo -n true; sleep 60; done 2>/dev/null &

# delete old ssh key
sudo rm -v /etc/ssh/ssh_host_*

# regen SSH Key
sudo dpkg-reconfigure openssh-server

# restart ssh server
sudo systemctl restart ssh
echo "SSH keys regenerated!"

# cloud-init parameter change
sudo sed -i "15s/.*/preserve_hostname: true/" /etc/cloud/cloud.cfg

# writing in the new hostname
sudo hostnamectl set-hostname $TURTLEBOT_NAME
sudo sed -i "2s/.*/127.0.0.1 $TURTLEBOT_NAME/" /etc/hosts
echo "hostname set to $TURTLEBOT_NAME !"

# rebuild tb3 packages set with flag --rebuild
if [ "$REBUILD" = true ]; then
    # cd into turtlebot3_ws
    cd ~/turtlebot3_ws/

    # confirm the correct directory
    if [ -d ~/turtlebot3_ws ]; then
        # rebuild turtlebot3_ws
        colcon build --symlink-install 
    fi
fi

# confirm reconfig status
echo "Reconfiguration Finished!"

# made rebooting after setup optional, REBOOT is set with the --reboot flag
if [ "$REBOOT" = true ]; then
    reboot
fi

# warning if --reboot was not chosen in cli args
echo "Please reboot in order to see Turtleboot Lite's changes take effect!"

# kill sudo process
kill %1 2>/dev/null || true

# sucessful, so exit is 0
exit 0