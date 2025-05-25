#alink logic

import subprocess
import time
import re
bitrate=60
ip="192.168.0.131"
interval=5
bitratemax=60

import subprocess

def get_average_ping():
    try:
        cmd = ["ping", "192.168.0.131"]
        output = subprocess.check_output(cmd, stderr=subprocess.STDOUT, universal_newlines=True)

        # Exemple de ligne à parser :
        # rtt min/avg/max/mdev = 24.292/25.081/25.975/0.705 ms
    except subprocess.CalledProcessError as e:
        print("[PING ERROR] Échec du ping ou timeout.")
        return None

    match = re.search(r"Maximum\s*=\s*(\d+)\s*ms", output)
    if match:
        max_rtt = int(match.group(1))
        return max_rtt
    else:
        print("[ERROR] Aucune valeur Maximum trouvée.")
        return None

# Exemple de test :


####LOGIC FUNCTION ON TIMEOUT GS

while True:
    time.sleep(2)
    if(get_average_ping(ip) > 100):
        #set your encoder behavior here
        bitrate=bitrate-interval
        print(f'{bitrate} Mbps')
    else:
        #set your encoder behavior here
        bitrate=bitrate+interval
        print(f'{bitrate} Mbps')
  