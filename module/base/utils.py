#!/usr/bin/env python
import subprocess

def getType(type=''):
    typedic = {
       'VlanIndex':'GAU',
        'PortList':'BITS',
         'INTEGER':'INT',
       'RowStatus':'INT',
       'TruthValue':'INT',
      'InetAddress':'OCT',
      'Unsigned32':'GAU',
    'EightOTwoOui':'OCT'}
    return typedic[type]
def mac2index(mac='00:00:00:00:00:00'):
    mac_str = mac.split(':')
    index = ''
    for i in mac_str:
        index = index + str(int(i.upper(),16))
        index = index + '.'
    index = index [:-1]
    return index
def ispingable(ip='127.0.0.1'):
    ret = subprocess.call("ping -c 2 %s" % ip,shell=True,stdout=open('/dev/null','w'),stderr=subprocess.STDOUT)
    if ( ret == 0 ):
        return True
    else:
        return False
