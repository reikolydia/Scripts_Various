#!/usr/bin/env python

# This Python script uses Pings to check for internet connectivity and reports it using BLINKT led colors
# Change SITES as required

import sys, os, signal
import subprocess
import blinkt
from blinkt import clear, set_brightness, set_pixel, show, set_all
import time
from time import sleep
import math
import colorsys

os.system('clear')
print(f'Starting Internet Check Script [{os.path.basename(__file__)}] ..')
print(f'Kill this process [{os.path.basename(__file__)}] using: sudo kill -9 {os.getpid()}')

DELAY_BETWEEN_PINGS = 1
DELAY_BETWEEN_TESTS = 60

SITES = ["cloudflare-dns.com", "dns.google", "1.1.1.1", "8.8.8.8"]

def debug_message(debug_indicator, output_message):
    # USAGE: script.py -debug
    if debug_indicator:
        print(output_message)

def handler(signum, frame):
    clear()
    show()
    exit(0)

signal.signal(signal.SIGTERM, handler)

def ping(site):
    cmd = "ping -c 1 -W 0.5 " + site
    try:
        output = subprocess.check_output(cmd, stderr=subprocess.STDOUT, shell=True)
    except subprocess.CalledProcessError as e:
        debug_message(debug, site + " : FAIL")
        return 0
    else:
        debug_message(debug, site + " : PASS")
        return 1

def ping_sites(site_list, wait_time, times):
    successful_pings = 0
    attempted_pings = times * len(site_list)
    for t in range(0, times):
        for s in site_list:
            successful_pings += ping(s)
            time.sleep(wait_time)
    debug_message(debug, " ")
    debug_message(debug, "Percentage successful: " + str(int(100 * (successful_pings / float(attempted_pings)))) + "%")
    return successful_pings / float(attempted_pings)

def connected_Y():
    set_all(0, 255, 0, 0.3)
    show()

def connected_N():
    set_all(255, 0, 0, 1)
    show()

def connected_H():
    set_all(255, 255, 0, 0.5)
    show()

def connecting():
    set_all(0, 0, 255, 0.3)
    show()

def connected_T():
    debug_message(debug, "Showing LED Splash..")
    clear()
    FALLOFF = 1.9
    SCAN_SPEED = 4
    start_time = time.time()
    cnt_T = 0
    while cnt_T <= 60:
        delta = (time.time() - start_time)
        offset = (math.sin(delta * SCAN_SPEED) + 1) / 2
        hue = int(round(offset * 360))
        max_val = blinkt.NUM_PIXELS - 1
        offset = int(round(offset * max_val))
        for x in range(blinkt.NUM_PIXELS):
            sat = 1.0
            val = max_val - (abs(offset - x) * FALLOFF)
            val /= float(max_val)
            val = max(val, 0.0)
            xhue = hue
            xhue += (1 - val) * 10
            xhue %= 360
            xhue /= 360.0
            r, g, b = [int(c * 255) for c in colorsys.hsv_to_rgb(xhue, sat, val)]
            set_pixel(x, r, g, b, val / 4)
        show()
        time.sleep(0.001)
        cnt_T += 1
    clear()
    show()
    debug_message(debug, " ")

# MAIN
blinkt.set_clear_on_exit(True)
clear()
show()

debug = False
if len(sys.argv) > 1:
    if sys.argv[1] == "-debug":
        debug= True
        print(" ")
        print("Debug mode activated.")
        print(" ")
    else:
        print(" ")
        print("Unknown option specified: " + sys.argv[1])
        sys.exit(1)
else:
    print(" ")
    print("Add a -debug if you wish to see debug messages.")
    print(" ")

connected_T()
sleep(1)
connecting()

test_cnt = 0
while True:
    test_delay = DELAY_BETWEEN_TESTS
    connecting()
    test_cnt += 1
    debug_message(debug, "----- TEST: " + str(test_cnt) + " -----")
    success = ping_sites(SITES, DELAY_BETWEEN_PINGS, 1)
    if success == 0:
        test_delay = round(int(float(test_delay / 4)))
        connected_N()
        subprocess.call(['sh', './restart-internet.sh'])
    elif success <= .50:
        test_delay = round(int(float(test_delay / 2)))
        connected_H()
    else:
        connected_Y()
    debug_message(debug, "Waiting " + str(test_delay) + " seconds until next test..")
    debug_message(debug, " ")
    time.sleep(test_delay)

clear()
show()
