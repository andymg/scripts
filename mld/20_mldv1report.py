#! /usr/bin/env python
import os
import sys
from scapy.all import *

conf.iface = 'eth2'
conf.iface6 = 'eth2'
#mldv1 = rdpcap("/home/andym/packet/mld/mldv1report_done_dump.pcap")
#v1report = mldv1[0]
#del v1report[Padding]

#<Ether  dst=33:33:00:00:00:03 src=00:60:94:00:00:01 type=0x86dd |<IPv6  version=6L tc=0L fl=0L plen=32 nh=Hop-by-Hop Option Header hlim=1 src=fe80::2 dst=ff1e::3 |<IPv6ExtHdrHopByHop  nh=ICMPv6 len=0 autopad=On options=[<RouterAlert  otype=Router Alert [00: skip, 0: Don't change en-route] optlen=2 value=Datagram contains a MLD message |>, <PadN  otype=PadN [00: skip, 0: Don't change en-route] optlen=0 |>] |<ICMPv6MLReport  type=MLD Report code=0 cksum=0x7fe6 mrd=0 reserved=0 mladdr=ff1e::3 |>>>>

str_r0='33\x00\x00\x00\x03\x00`\x94\x00\x00\x01\x86\xdd`\x00\x00\x00\x00 \x00\x01\xfe\x80\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\xff\x1e\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x03:\x00\x05\x02\x00\x00\x01\x00\x83\x00\x7f\xe6\x00\x00\x00\x00\xff\x1e\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x03'
v1report=Ether(str_r0)
esrc_p = '00:60:94:00:25:'
ipsrc_p = 'fe80:0000:0000:0000:0000:0000:0000:'
mgaddr_p = 'ff8e::'
for last in range(0,5,1):
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
