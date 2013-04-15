#!/usr/bin/env python

import netsnmp
from base import *


myvcl = vcl(ip='172.16.6.233')
res = myvcl.vclMacBasedVlan_add(mac='00:00:00:00:00:ac',vid=4094,member='\x80')

res = myvcl.vclMacBasedVlan_add(mac='00:00:00:00:00:aa',vid=4092,member='\x87')
print res

res = myvcl.vclMacBasedVlan_del(mac='00:00:00:00:00:ac')
print res
