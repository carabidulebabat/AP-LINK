#alink logic
import cv2
import subprocess
import socket
import threading
import time
##ADAPTIVE EXEMPLE WORKS WITH FFMEG NEED TO ADAPT WITH YOUR STREAMER"""

DEST_IP = "192.168.1.28"  # IP of groundstation
DEST_PORT = 5000           # UDP port
ACK_PORT = 4321           # Port local pour recevoir ACK (facultatif)

# Initial config
resolutions = (1280, 720)  # progressive levels
bitrates = ['2000k', '10000k', '20000k', '50000k']
quality_level = 4

ack_received = True
last_ack_time = time.time()

def ack_listener():
    global ack_received, last_ack_time
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind(('', ACK_PORT))
    while True:
        try:
            data, _ = sock.recvfrom(1024)
            if data == b'ACK':
                ack_received = True
                last_ack_time = time.time()
        except Exception:
            pass

threading.Thread(target=ack_listener, daemon=True).start()

def launch_ffmpeg(width, height, bitrate):
    print(f"[FFMPEG] Resolution: {width}x{height}, Bitrate: {bitrate}")
    return subprocess.Popen([
        'ffmpeg',
        '-f', 'rawvideo',
        '-pix_fmt', 'bgr24',
        '-s', f'{width}x{height}',
        '-r', '25',
        '-i', '-',
        '-c:v', 'libx264',
        '-preset', 'ultrafast',
        '-tune', 'zerolatency',
        '-b:v', bitrate,
        '-f', 'mpegts',
        f'udp://{DEST_IP}:{DEST_PORT}?pkt_size=1316'
    ], stdin=subprocess.PIPE)

cap = cv2.VideoCapture(0)
cap.set(cv2.CAP_PROP_FPS, 60)

current_ffmpeg = launch_ffmpeg(*resolutions[quality_level], bitrates[quality_level])
last_adjust = time.time()

while True:
    ret, frame = cap.read()
    if not ret:
        break

    try:
        current_ffmpeg.stdin.write(frame_resized.tobytes())
    except (BrokenPipeError, IOError):
        print("FFmpeg pipe broken. Exiting.")
        break

    if time.time() - last_adjust > 0.5:
        now = time.time()
        timeout = now - last_ack_time

        if timeout > 1.0 and quality_level > 0:
            quality_level -= 1
            print(f"[ADAPT] ↓ Network degraded. Switching to level {bitrates}")
            current_ffmpeg.stdin.close()
            current_ffmpeg.wait()
            current_ffmpeg = launch_ffmpeg(bitrates[quality_level])
        elif timeout < 0.5 and quality_level < len(resolutions) - 1:
            quality_level += 1
            print(f"[ADAPT] ↑ Network stable. Increasing to level {bitrates}")
            current_ffmpeg.stdin.close()
            current_ffmpeg.wait()
            current_ffmpeg = launch_ffmpeg(bitrates[quality_level])

        last_adjust = now

cap.release()
current_ffmpeg.stdin.close()
current_ffmpeg.wait()
