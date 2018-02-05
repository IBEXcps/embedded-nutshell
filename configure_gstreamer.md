
# add bcm2835-v4l2 in a new line to create /dev/video0 on boot
sudo nano /etc/modules-load.d/raspberrypi.conf

# Load module to get /dev/video0 in this section
modprobe bcm2835-v4l2

# For more information
sudo v4l2-ctl -d /dev/video0 --all

# Install gst
yaourt -S gstreamer v4l-utils --noconfirm
yaourt -S gst-plugins-bad  gst-plugins-good gst-plugins-ugly --noconfirm
