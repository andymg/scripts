#! /usr/bin/env python
import os
import sys
from scapy.all import *

conf.iface = 'eth2'
conf.iface6 = 'eth2'
mldv1 = rdpcap("/home/andym/packet/mld/mldv1report_done_dump.pcap")
v1report = mldv1[2]
del v1report[Padding]
esrc_p = '00:60:94:00:25:'
ipsrc_p = 'fe80:0000:0000:0000:0000:0000:0000:'
mgaddr_p = 'ff5e::'
for last in range(0,250,1):
   print  hex(last)[2:]
   print last
   esrc = esrc_p + hex(last)[2:]
   ipsrc = ipsrc_p + hex(last)[2:]
   mgaddr = mgaddr_p + hex(last)[2:]
   del v1report.cksum
   v1report.src = esrc
   v1report[IPv6].src = ipsrc
   v1report.mladdr = mgaddr
   v1report = v1report.__class__(str(v1report))
   sendp(v1report)
