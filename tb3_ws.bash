#!/bin/bash

# exit on error
set -e

# fun ascii art :)
cat << "EOF"
 _____           _   _      ____              _   
|_   _|   _ _ __| |_| | ___| __ )  ___   ___ | |_ 
  | || | | | '__| __| |/ _ \  _ \ / _ \ / _ \| __|
  | || |_| | |  | |_| |  __/ |_) | (_) | (_) | |_ 
  |_| \__,_|_|   \__|_|\___|____/ \___/ \___/ \__|
          T B 3 _ W S    R E B U I L D          
                   _____     ____
                 /      \  |  o | 
                |        |/ ___\| 
                |_________/     
                |_|_| |_|_|
EOF
echo "Welcome to TurtleBoot turtlebot3_ws rebuild!"
echo "developed by @kymadogg"
# start sudo session
sudo -v
while true; do sudo -n true; sleep 60; done 2>/dev/null &

# make turtlebot workspace
mkdir -p ~/turtlebot3_ws/src
cd ~/turtlebot3_ws/src

# check for duplicate dir or accidental root owned dir
if [ -d "turtlebot3" ]; then
  echo "Removing existing turtlebot3 directory (may be root-owned or incomplete)..."
  sudo rm -rf turtlebot3
fi

# Clone Packages from GitHub, make sure branches are there as well
if ! git clone -b jazzy https://github.com/ROBOTIS-GIT/turtlebot3.git; then
  echo "Failed to clone turtlebot3 repository. Check if the branch 'jazzy' exists."
  exit 1
fi
if ! git clone -b jazzy https://github.com/ROBOTIS-GIT/ld08_driver.git; then
  echo "Failed to clone ld08_driver repository. Check if the branch 'jazzy' exists."
  exit 1
fi

# remove cartographer and nav2 packages
cd ~/turtlebot3_ws/src/turtlebot3
rm -rf turtlebot3_cartographer turtlebot3_navigation2 || true
cd ~/turtlebot3_ws/

# Prevent duplicate lines in .bashrc
grep -qxF 'source /opt/ros/jazzy/setup.bash' ~/.bashrc || echo 'source /opt/ros/jazzy/setup.bash' >> ~/.bashrc

# building turtlebot workspace
cd ~/turtlebot3_ws/
colcon build --symlink-install --parallel-workers 1

# prevent ~/.bashrc clutter
grep -qxF 'source ~/turtlebot3_ws/install/setup.bash' ~/.bashrc || echo 'source ~/turtlebot3_ws/install/setup.bash' >> ~/.bashrc
source /opt/ros/jazzy/setup.bash
source ~/turtlebot3_ws/install/setup.bash

PKG_PREFIX=$(ros2 pkg prefix turtlebot3_bringup)
if [ -z "$PKG_PREFIX" ]; then
  echo "Could not find turtlebot3_bringup package. Exiting."
  exit 1
fi
sudo cp "$PKG_PREFIX/share/turtlebot3_bringup/script/99-turtlebot3-cdc.rules" /etc/udev/rules.d/

sudo udevadm control --reload-rules
sudo udevadm trigger

# export variables for configuring the turtlebot, prevent duplicates
grep -qxF "export ROS_DOMAIN_ID=$ROS_ID #TURTLEBOT3" ~/.bashrc || echo "export ROS_DOMAIN_ID=$ROS_ID #TURTLEBOT3" >> ~/.bashrc
grep -qxF "export LDS_MODEL=LDS-0$LIDAR # lidar config" ~/.bashrc || echo "export LDS_MODEL=LDS-0$LIDAR # lidar config" >> ~/.bashrc
grep -qxF "export TURTLEBOT3_MODEL=$MODEL # model" ~/.bashrc || echo "export TURTLEBOT3_MODEL=$MODEL # model" >> ~/.bashrc
grep -qxF "export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp # switch to cyclone dds" ~/.bashrc || echo "export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp # switch to cyclone dds" >> ~/.bashrc

# Kill sudo process
kill %1 2>/dev/null || true

# confirm sucess
echo "Set up complete!"
exit 0