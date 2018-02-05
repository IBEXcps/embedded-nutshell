# Enable driver dwc2
# /boot/config.txt
echo 'dtoverlay=dwc2 >> /boot/config.txt

# Update command line with `modules-load=dwc2,g_ether`
# /boot/cmdline.txt
root=/dev/mmcblk0p2 rw rootwait modules-load=dwc2,g_ether console=ttyAMA0,115200 console=tty1 selinux=0 plymouth.enable=0 smsc95xx.turbo_mode=N kgdboc=ttyAMA0,115200 elevator=noop

# Create a new configuration
# /etc/systemd/network/usb.network
[Match]
Name = usb*

[Network]
Address = 192.168.2.2/24

# ssh
alarm@ ip a usb device
pass: alarm

# connect wifi
# where wlp10s0b1 is your wifi card
wpa_supplicant -B -D nl80211,wext -i wlp10s0b1 -c <(wpa_passphrase $SSID $PASSWORD)

# install dialog and run wifi-menu 
pacman -S dialog
wifi-menu
systemctl enable netctl
systemctl start netctl
reboot
