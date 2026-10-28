#!/bin/bash

# exit on error
set -e

UPDATE="false"

# handling cli args
while [[ $# -gt 0 ]]; do
    case $1 in
        --update)
            UPDATE="true"
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [--update]"
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
           T P - L I N K    D R I V E R          
                   _____     ____
                 /      \  |  o | 
                |        |/ ___\| 
                |_________/     
                |_|_| |_|_|
EOF
echo "Welcome to TurtleBoot TP-Link driver installation!"
echo "developed by @kymadogg"

# start sudo session
sudo -v
while true; do sudo -n true; sleep 60; done 2>/dev/null &

if [ "$UPDATE" = false ]; then # this is to update the driver
    echo "updating driver with dkms..."

    # remove old driver 
    sudo dkms remove rtw88/0.6 --all
    sudo rm -r /usr/src/rtw88-0.6/

    # pull changes
    cd ~/rtw88
    git pull

    # reinstall
    sudo dkms install $PWD

else # this is for installing the driver

    # clone the driver repository if it does not exist
    if [ ! -d "~/rtw88" ]; then
        cd ~
        git clone https://github.com/lwfinger/rtw88.git # see this for docs on the driver
    fi

    # upgrade, update, and install kernel headers
    sudo apt update && sudo apt upgrade
    sudo apt install -y raspberrypi-linux-header build-essential
    sudo apt install -y dkms mokutil

    # build and install the driver using dkms
    cd ~/rtw88
    sudo dkms install $PWD
    sudo make install_fw

    # not sure if this is needed (only if secure boot is on)
    sudo mokutil --import /var/lib/shim-signed/mok/MOK.der

    # load the kernel module with modprobe
    sudo modprobe rtw_8821au
    echo "module loaded!"
fi

# kill sudo process
kill %1 2>/dev/null || true

# sucessful, so exit is 0
exit 0