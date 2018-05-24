# Board open as a usb-storage
create a file /etc/modprobe.d/stlink.conf and add: options usb-storage quirks=0483:3744:i
Reload usb_storage driver with: `sudo modprobe -rf usb_storage && sudo modprobe usb_storage`
