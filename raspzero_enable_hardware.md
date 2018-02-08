# rasp-config
## User friendly interface for hardware configuration
yaourt -s rasp-config

# SPI
## To enable the /dev/spidev* devices:
# /boot/config.txt
dtparam=spi=on


# I2C
## Install i2c-tools
# /boot/config.txt
dtparam=i2c=on
dtparam=i2c_baudrate=400000

# /etc/modules-load.d/raspberrypi.conf
i2c-dev
i2c-bcm2708

Reboot and run `i2cdetect -y 1` (/dev/i2c-1)

# For more information
[/boot/config.txt manual](https://github.com/raspberrypi/firmware/blob/master/boot/overlays/README)
