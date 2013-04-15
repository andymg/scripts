#!/usr/bin/env python
import netsnmp
import string
import os
import sys
from utils import *

class vcl(object):
    
    def __init__(self,ip=''):
        """
        init function, initial with DUT ip
        """
        self.tnVclMacBasedVlanId=('.1.3.6.1.4.1.868.2.5.4.1.8.1.1.1.2','VlanIndex','read-create')
        self.tnVclMacBasedPortMember=('.1.3.6.1.4.1.868.2.5.4.1.8.1.1.1.3','PortList','read-create')
        self.tnVclMacBasedUser=('.1.3.6.1.4.1.868.2.5.4.1.8.1.1.1.4','INTEGER','read-only')
        self.tnVclMacBasedRowStatus=('.1.3.6.1.4.1.868.2.5.4.1.8.1.1.1.5','RowStatus','read-create')
        self.tnVclProtoBasedGroupMapProtocol=('.1.3.6.1.4.1.868.2.5.4.1.8.2.1.1.2','INTEGER','read-create')
        self.tnVclProtoBasedGroupMapEtherTypeVal=('.1.3.6.1.4.1.868.2.5.4.1.8.2.1.1.3','INTEGER','read-create')
        self.tnVclProtoBasedGroupMapSnapOui=('.1.3.6.1.4.1.868.2.5.4.1.8.2.1.1.4','EightOTwoOui','read-create')
        self.tnVclProtoBasedGroupMapSnapPid=('.1.3.6.1.4.1.868.2.5.4.1.8.2.1.1.5','INTEGER','read-create')
        self.tnVclProtoBasedGroupMapLlcDsap=('.1.3.6.1.4.1.868.2.5.4.1.8.2.1.1.6','INTEGER','read-create')
        self.tnVclProtoBasedGroupMapLlcSsap=('.1.3.6.1.4.1.868.2.5.4.1.8.2.1.1.7','INTEGER','read-create')
        self.tnVclProtoBasedGroupMapRowStatus=('.1.3.6.1.4.1.868.2.5.4.1.8.2.1.1.8','RowStatus','read-create')
        self.tnVclProtoBasedVlanMapPortMember=('.1.3.6.1.4.1.868.2.5.4.1.8.2.2.1.2','PortList','read-create')
        self.tnVclProtoBasedVlanMapRowStatus=('.1.3.6.1.4.1.868.2.5.4.1.8.2.2.1.3','RowStatus','read-create')
        self.tnVclIpSubnetBasedIpAddr=('.1.3.6.1.4.1.868.2.5.4.1.8.3.1.1.2','IpAddress','read-create')
        self.tnVclIpSubnetBasedMaskLen=('.1.3.6.1.4.1.868.2.5.4.1.8.3.1.1.3','INTEGER','read-create')
        self.tnVclIpSubnetBasedVlanId=('.1.3.6.1.4.1.868.2.5.4.1.8.3.1.1.4','VlanIndex','read-create')
        self.tnVclIpSubnetBasedPortMember=('.1.3.6.1.4.1.868.2.5.4.1.8.3.1.1.5','PortList','read-create')
        self.tnVclIpSubnetBasedRowStatus=('.1.3.6.1.4.1.868.2.5.4.1.8.3.1.1.6','RowStatus','')
        self.ip=ip
        ret = ispingable(ip)
        if ( ret == True ):
            self.sess=netsnmp.Session(Version=2,DestHost=self.ip,Community='private')
            print "vcl is inited in :" + ip
        else:
            print ip + "is not pingable!"
    def vclMacBasedVlan_add(self,mac='00:00:00:00:00:01',vid=1,member='\x80'):
        """
        This function add Mac based vlan,
        mac is the mac address format as 00:00:00:00:00:01
        vid is the Vlan ID value
        member is the BITS of ports
        """
        self.vid = vid
        index = '6.' + mac2index(mac)
        pVid = netsnmp.Varbind(self.tnVclMacBasedVlanId[0],index,vid,getType(type=self.tnVclMacBasedVlanId[1]))
        pMember = netsnmp.Varbind(self.tnVclMacBasedPortMember[0],index,member,getType(type=self.tnVclMacBasedPortMember[1]))
        pRs = netsnmp.Varbind(self.tnVclMacBasedRowStatus[0],index,4,getType(type=self.tnVclMacBasedRowStatus[1]))
        vars = netsnmp.VarList(pVid,pMember,pRs)
        ret = self.sess.set(vars)
        vid_str = str(self.vid)
        if (ret == 1):
            print "New Mac-Vlan item :" + mac + " --> " + vid_str + " succeed! "
        else:
            print "New Mac-Vlan item :" + mac + " --> " + vid_str + " Failed!"
        return ret
    def vclMacBasedVlan_del(self,mac='00:00:00:00:00:01'):
        """
        Remove item in MacBased Vlan list
        """
        index = '6.' + mac2index(mac)
        pRs = netsnmp.Varbind(self.tnVclMacBasedRowStatus[0],index,6,getType(type=self.tnVclMacBasedRowStatus[1]))
        vars = netsnmp.VarList(pRs)
        res = self.sess.set(vars)
        if (res == 1):
            print "Delete Mac-Vlan item :" + mac  + " succeed!"
        else:
            print "Delete Mac-Vlan item :" + mac  + " Failed!"
        return res
    def vclMacBasedVlan_setPort(self,mac='00:00:00:00:00:01',member='\x80'):
        """
        This function is used for modify the port member fot each mac-vlan item
        """
        index = '6.' + mac2index(mac)
        pMember = netsnmp.Varbind(self.tnVclMacBasedPortMember[0],index,member,getType(type=self.tnVclMacBasedPortMember[1]))
        vars = netsnmp.VarList(pMember)
        res = self.sess.set(vars)
        return res
