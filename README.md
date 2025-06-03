# display
Use a Raspberry Pi as a monitor

## Run

```bash
wget https://raw.githubusercontent.com/WEEE-Open/display/master/install.sh
chmod +x install.sh
./install.sh
```

If wget is missing install with `sudo apt install wget`

## Cloning

If you want to make multiple devices with the same config, it is recommended that you make an image (with another computer) of the sd card with `sudo dd if=/dev/mccblk0 of=display.img status=progress` and replace the if with the device you find with `lsblk` aand then you shrink it with [PiShrink](https://github.com/Drewsif/PiShrink)