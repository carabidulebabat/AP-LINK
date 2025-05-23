#!/usr/bin/env python3

import subprocess
import re
import statistics

# === CONFIGURATION ===
bestchan = 0
iw_out="""
* 5075 MHz [15] (30.0 dBm)
* 5080 MHz [16] (30.0 dBm)
* 5085 MHz [17] (30.0 dBm)
* 5090 MHz [18] (30.0 dBm)
* 5100 MHz [20] (30.0 dBm)
* 5120 MHz [24] (30.0 dBm)
* 5140 MHz [28] (30.0 dBm)
* 5160 MHz [32] (23.0 dBm)
* 5180 MHz [36] (23.0 dBm)
* 5200 MHz [40] (23.0 dBm)
* 5220 MHz [44] (23.0 dBm)
* 5240 MHz [48] (23.0 dBm)
* 5260 MHz [52] (24.0 dBm) (radar detection)
* 5280 MHz [56] (24.0 dBm) (radar detection)
* 5300 MHz [60] (24.0 dBm) (radar detection)
* 5320 MHz [64] (24.0 dBm) (radar detection)
* 5340 MHz [68] (24.0 dBm) (radar detection)
* 5360 MHz [72] (30.0 dBm)
* 5380 MHz [76] (30.0 dBm)
* 5400 MHz [80] (30.0 dBm)
* 5420 MHz [84] (30.0 dBm)
* 5440 MHz [88] (30.0 dBm)
* 5460 MHz [92] (30.0 dBm)
* 5480 MHz [96] (24.0 dBm) (radar detection)
* 5500 MHz [100] (24.0 dBm) (radar detection)
* 5520 MHz [104] (24.0 dBm) (radar detection)
* 5540 MHz [108] (24.0 dBm) (radar detection)
* 5560 MHz [112] (24.0 dBm) (radar detection)
* 5580 MHz [116] (24.0 dBm) (radar detection)
* 5600 MHz [120] (24.0 dBm) (radar detection)
* 5620 MHz [124] (24.0 dBm) (radar detection)
* 5640 MHz [128] (24.0 dBm) (radar detection)
* 5660 MHz [132] (24.0 dBm) (radar detection)
* 5680 MHz [136] (24.0 dBm) (radar detection)
* 5700 MHz [140] (24.0 dBm) (radar detection)
* 5720 MHz [144] (24.0 dBm) (radar detection)
* 5745 MHz [149] (30.0 dBm)
* 5765 MHz [153] (30.0 dBm)
* 5785 MHz [157] (30.0 dBm)
* 5805 MHz [161] (30.0 dBm)
* 5825 MHz [165] (30.0 dBm)
* 5845 MHz [169] (27.0 dBm)
* 5865 MHz [173] (27.0 dBm)
* 5885 MHz [177] (27.0 dBm)
"""
def parse_5ghz_frequencies():
    # Exécute la commande iw list
    #iw_output = subprocess.run(['iw', 'list'], capture_output=True, text=True).stdout

    # Cherche les sections 5 GHz
    #band_5ghz_section = ""
    #capture = False

    #for line in iw_out.splitlines():
    #    if "Frequencies:" in line and "5180 MHz" in line:
    #        capture = True
    #    elif capture and not line.strip().startswith("*"):
    #        # Fin de la section (prochaine partie non fréquence)
    #        break
    #    elif capture:
    #        band_5ghz_section += line + "\n"

    # Parse les fréquences
    freq_pattern = r"\*\s+(\d+)\s+MHz\s+\[(\d+)\]\s+\(([\d\.]+)\s+dBm\)(\s+\(radar detection\))?"

    channels = []
    for match in re.finditer(freq_pattern, iw_out):
        frequency = int(match.group(1))
        channel = int(match.group(2))
        tx_power = float(match.group(3))
        radar = bool(match.group(4))
        channels.append({
            "frequency": frequency,
            "channel": channel,
            "tx_power": tx_power,
            "radar_detection": radar,
        })
    return channels        
iwoutput = parse_5ghz_frequencies()

print(iwoutput)
