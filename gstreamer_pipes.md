## Capture av converted image, crop, encode h264, send via udp 
```
  gst-launch-1.0 v4l2src ! \                            #capture v4l device
  video/x-raw,width=720,height=480 ! \                  #caps, set input video size
  videocrop top=38 left=75 right=55 bottom=20 ! \       #crop image (camera had black bars)
  videorate ! \                                         #change framerate
  video/x-raw,framerate=9/1 ! \                         #target framerate
  videoscale ! \                                        #resize image
  video/x-raw,width=336,height=256 ! \                  #target size
  deinterlace ! \                                       #deinterlace
  omxh264enc target-bitrate=500000 control-rate=1 ! \   #encode h264 via hardware
  video/x-h264,profile=high !                           #encoding options
  \h264parse ! \                                        #parse encoded file (not sure if required)
  rtph264pay config-interval=1 pt=96 !                  #payload data to rpt
  \queue !                                              #buffer
  \udpsink host=127.0.0.1 port=8009                     #send
  ```

## capture h264 from raspberry pi camera and send via rtp

```
    gst-launch-1.0 rpicamsrc rotation=0 bitrate=1000000 \                      #
    keyframe-interval=30 do-timestamp=true ! \                                 # capture using raspicam
    video/x-h264,width=1280,height=720,framerate=30/1,profile=baseline ! \     # more capture options
    h264parse ! \                                                              # parse stream
    rtph264pay config-interval=1 pt=96 ! \                                     # payload
    queue ! \                                                                  # buffer
    udpsink host=$ground port=8004 qos-dscp=40                                 # send
 ```

 Simple pip to split stream into two ports

```
  /usr/bin/gst-launch-1.0 -v udpsrc port=8004 ! \             # Receives data on port 8004
  multiudpsink clients="127.0.0.1:8008,"$server":8004" \      # sends to ports 8008 and 8004 
  > /var/log/gstreamerlogrelay3 2>&1 &                        # redirects stdout and stderr to logfile, detaches process

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
