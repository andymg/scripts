#!/usr/bin/env python

import os
import sys
from scapy.all import *

src='00:00:00:00:00:'
dst='00:00:00:00:11:'
for last in range(1,25,1):
    src_t = src + hex(last)[2:]
    dst_t = dst + hex(last)[2:]
    pack = Ether(dst = dst_t,src = src_t)
    sendp(pack,iface='eth2')

