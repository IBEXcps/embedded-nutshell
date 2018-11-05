# Socat Commands

Here you can find some useful socat commands, for network forwading data, exposing serials on the internet and others.

## Serial Only
- Create two linked serial ports

  `socat PTY,link=/dev/ttyVirtual1 PTY,link=/dev/ttyVirtual2`

## Serial-UDP

- Create an UDP SERVER to expose a local serial device `/dev/ttyUSB0` with `115200` baud in UDP port `4777`

  `socat -dd UDP-LISTEN:4777,fork,reuseaddr,ignoreeof FILE:/dev/ttyUSB0,b115200,raw,ignoreeof`
  
 - Create an local virtual serial device with `115200` baud connected to remote device at server `127.0.0.1` and UDP port `6676` (this exits immediately, remember to kill socat later or change script so it waits for it.)
   
  ```
#!/usr/bin/env bash
socat PTY,link=/dev/ttyUSB0,group=uucp,perm=0660,user=root UDP:127.0.0.1:6676&
sleep 1
chown -h root:uucp /dev/ttyUSB0
  ```

## Serial-TCP

- Create an UDP SERVER to expose a local serial device with `115200` baud in TCP port `4777`
   
   `//TODO`
 - Create an local virtual serial device with `115200` baud connected to remote device at server `127.0.0.1` and TCP port `115200`
      
   `//TODO`
