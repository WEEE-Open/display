#!/bin/bash

echo

echo "Installing display by WEEE Open"

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo "This script needs to run with sudo."
  exec sudo "$0" "$@"  # Re-run the script with sudo
  exit 1
fi

echo "Installing MPlayer, fbi and rpd-plym-splash"

apt update && apt upgrade -y && apt install -y mplayer fbi rpd-plym-splash

echo "Creating /opt/display"

mkdir /opt/display

cd /opt/display

echo "Cloning"

git clone https://github.com/WEEE-Open/display.git /opt/display

echo "Enabling HDMI hotplug"

echo "hdmi_force_hotplug=1" >> /boot/firmware/config.txt

echo "Enabling TC35873"

echo "dtoverlay=tc358743" >> /boot/firmware/config.txt

echo "Setting resolution"

echo -n " video=HDMI-A-1:800x480M@25"

echo "Enabling autologin"

raspi-config nonint do_boot_behaviour B2

echo "Copying systemd service"

cp display.service /etc/systemd/system/

echo "Enabling systemd service"

systemctl daemon-reload
systemctl enable display

echo "Adding splash screen"

cp splashscreen.png /run/media/enrico/rootfs/usr/share/plymouth/themes/pix/splash.png
raspi-config nonint do_boot_splash 0

echo "Adding no video screen"

echo "sudo fbi -T 1 -d /dev/fb0 -noverbose -a /opt/display/novideo.png" >> ~/.bashrc

read -p "Would you like to disable non-essential proceses (including networking)? [y/n]: " choice

case "${choice,,}" in
  y|yes)
    echo "Disabling non-essential proceses"
    systemctl disable avahi-daemon
    systemctl disable bluetooth
    systemctl disable ModemManager
    systemctl disable NetworkManager
    systemctl disable NetworkManager-wait-online.service
    systemctl disable dphys-swapfile
    systemctl disable rpi-eeprom-update
    systemctl disable ssh
    systemctl disable triggerhappy
    systemctl disable cron
    systemctl disable polkit
    systemctl disable systemd-journal-flush
    systemctl disable systemd-timesyncd
    ;;
  n|no)
    echo "Skipping"
    ;;
  *)
    echo "Invalid input. Please enter y or n."
    ;;
esac

read -p "Would you like to lock the filesystem to preven overwrite? [y/n]: " choice
case "${choice,,}" in
  y|yes)
    echo "Locking file system"
    raspi-config nonint do_overlayfs 0
    sudo reboot
    ;;
  n|no)
    ;;
  *)
    echo "Invalid input. Please enter y or n."
    ;;
esac

echo
echo

echo "Everything is configured and will work at next boot"

read -p "Would you like to reboot the system now? [y/n]: " choice
case "${choice,,}" in
  y|yes)
    echo "Rebooting the system..."
    sudo reboot
    ;;
  n|no)
    ;;
  *)
    echo "Invalid input. Please enter y or n."
    ;;
esac

echo "Everything done, goodbye."

#ASD