import subprocess
def set_txpower(Dbm, interface):
    #get info
    result = subprocess.run(["iw", interface, "info"], capture_output=True, text=True)
    print(result.stdout)
