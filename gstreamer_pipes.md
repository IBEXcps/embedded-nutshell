## Capture av converted image, crop, encode h264, send via udp 
```
  gst-launch-1.0 v4l2src ! \                            # Capture v4l device
  video/x-raw,width=720,height=480 ! \                  # Caps, set input video size
  videocrop top=38 left=75 right=55 bottom=20 ! \       # Crop image (camera had black bars)
  videorate ! \                                         # Change framerate
  video/x-raw,framerate=9/1 ! \                         # Target framerate
  videoscale ! \                                        # Resize image
  video/x-raw,width=336,height=256 ! \                  # Target size
  deinterlace ! \                                       # Deinterlace
  omxh264enc target-bitrate=500000 control-rate=1 ! \   # Encode h264 via hardware
  video/x-h264,profile=high !                           # Encoding options
  \h264parse ! \                                        # Parse encoded file (not sure if required)
  rtph264pay config-interval=1 pt=96 !                  # Payload data to rpt
  \queue !                                              # Buffer
  \udpsink host=127.0.0.1 port=8009                     # Send
  ```

## capture h264 from raspberry pi camera and send via rtp

```
    gst-launch-1.0 rpicamsrc rotation=0 bitrate=1000000 \                      #
    keyframe-interval=30 do-timestamp=true ! \                                 # Capture using raspicam
    video/x-h264,width=1280,height=720,framerate=30/1,profile=baseline ! \     # More capture options
    h264parse ! \                                                              # Parse stream
    rtph264pay config-interval=1 pt=96 ! \                                     # Payload
    queue ! \                                                                  # Buffer
    udpsink host=127.0.0.1 port=8004 qos-dscp=40                               # Send
 ```

## Simple pipe to split stream into two ports

```
  /usr/bin/gst-launch-1.0 -v udpsrc port=8004 ! \             # Receives data on port 8004
  multiudpsink clients="127.0.0.1:8008,127.0.0.1:8004" \      # Sends to ports 8008 and 8004 
  > /var/log/gstreamerlogrelay3 2>&1 &                        # Redirects stdout and stderr to logfile, detaches process

```

## Generates fake h264 stream, payloads, sends via UDP (for testing purposes)

```
  gst-launch-1.0 videotestsrc pattern=ball ! \    # Generates a bouncing ball video
  video/x-raw,width=640,height=480 ! \            # Sets generated video format
  videoconvert ! x264enc bitrate=5000 ! \         # Encodes video
  video/x-h264, profile=baseline ! \              # Encoding caps
  rtph264pay ! \                                  # Payload into RTP
  udpsink host=localhost port=8004                # Sends via UDP

```
