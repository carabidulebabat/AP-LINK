# lr-lowlatency-ap
##OPENSOURCE VIDEO SYSTEM FOR UAV, RC CAR, ROBOTS, OVER WIFI NETWORK## 
##OPENSOURCE VIDEO SYSTEM FOR UAV, RC CAR, ROBOTS, OVER WIFI NETWORK##
AUTHOR:
DEPENCIES : IW, HOSTAPD, Realtek driver,
WORK WITH MAJESTICS, GSTREAMER, VLC
Made for longrange via udp stream,
AUTO MODE : CHANNEL AND TX POWER ARE SET AUTOMATICLY
MANUAL MODE : Channel need to set manualy

USE HOSTAPD, NEED TO ADD CORRECT WIFI DRIVER FOR YOU CHIPSET

Max bitrate will be 50mbps video stream, add 10mbps for telemetry and data, so 60mbps max bitrate 
OSD can be render on air or gs, by default is air for better compatibility
note air render consume more processing power, can be problematics with ip cam soc, like ssc338q or other sigmastar.
Can be use with raspberry pi, radxa zero or other device that can run Linux
Not related to openipc or wfb ng or ruby, just a wifi protocol.
basic command: 
low_latency_ap --help will show every command avaible
low_latency_ap --mode manual / auto 
low_latency_ap start <ip> <port> <5.8ghz or 2.4ghz> will start video stream
low_latency_ap stop <ip> <port>
low_latency_ap cli will show a terminal prompt with receive data packet
low_latency_ap --get ratio show how many packet are lost by receive packet
Usage exempel : 
low_latency_ap start 192.168.1.10 5000 5.8ghz --video stream.mp4 / dev/video0 --mode manual=chan 5745
will output start on <chan> <dbm> 