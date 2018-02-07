# SPI
## To enable the /dev/spidev* devices:
# /boot/config.txt
device_tree_param=spi=on


# I2C
## Install i2c-tools
# /boot/config.txt
dtparam=i2c_arm=on

# /etc/modules-load.d/raspberrypi.conf
i2c-dev
i2c-bcm2708

Reboot and run `i2cdetect -y 1` (/dev/i2c-1)
