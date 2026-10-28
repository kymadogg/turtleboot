#!/bin/bash

# Turtleboot Pre-ROS v1.3
# Prepares for installing ROS
# status --> TESTED ON TURTLEBOT3 (RPi 3B+ and RPi 4B)

set -e # exit on errors
cat << "EOF"
 _____           _   _      ____              _   
|_   _|   _ _ __| |_| | ___| __ )  ___   ___ | |_ 
  | || | | | '__| __| |/ _ \  _ \ / _ \ / _ \| __|
  | || |_| | |  | |_| |  __/ |_) | (_) | (_) | |_ 
  |_| \__,_|_|   \__|_|\___|____/ \___/ \___/ \__|
              P  R  E  -  R  O  S            
                   _____     ____
                 /      \  |  o | 
                |        |/ ___\| 
                |_________/     
                |_|_| |_|_|
EOF
echo "Welcome to TurtleBoot pre-ros!"
echo "developed by @kymadogg"

# ask for sudo permisison
sudo -v
while true; do sudo -n true; sleep 60; done 2>/dev/null &

# change automatic update settings
sudo sed -i "1s/.*/APT::Periodic::Update-Package-Lists "0";/" /etc/apt/apt.conf.d/20auto-upgrades
sudo sed -i "2s/.*/APT::Periodic::Unattended-Upgrade "0";/" /etc/apt/apt.conf.d/20auto-upgrades

# prevent boot-up delay
sudo systemctl mask systemd-networkd-wait-online.service
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

# reboot
reboot

# sucessfully completed!
exit 0