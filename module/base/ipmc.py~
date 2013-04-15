#!/usr/bin/env python

import netsnmp
import os
from utils import *

class ipmc(object):
    lindex=[]

    def __init__(self,ip='127.0.0.1'):
        self.tnIpmcSnoopingEnabled=('.1.3.6.1.4.1.868.2.5.115.2.1.1.1.1.2','TruthValue','read-write')
        self.tnIpmcSnoopingFloodingEnabled=('.1.3.6.1.4.1.868.2.5.115.2.1.1.1.1.3','TruthValue','read-write')
        self.tnIpmcSnoopingLeaveProxyEnabled=('.1.3.6.1.4.1.868.2.5.115.2.1.1.1.1.4','TruthValue','read-write')
        self.tnIpmcSnoopingProxyEnabled=('.1.3.6.1.4.1.868.2.5.115.2.1.1.1.1.5','TruthValue','read-write')
        self.tnIpmcSnoopingSsmRange=('.1.3.6.1.4.1.868.2.5.115.2.1.1.1.1.6','InetAddress','read-write')
        self.tnIpmcSnoopingSsmRangePrefix=('.1.3.6.1.4.1.868.2.5.115.2.1.1.1.1.7','InetAddressPrefixLength','read-write')
        self.tnIpmcSnoopingStatisticClear=('.1.3.6.1.4.1.868.2.5.115.2.1.1.1.1.8','TruthValue','read-write')
        self.tnPortRoutePortEnabled=('.1.3.6.1.4.1.868.2.5.115.2.1.2.1.1.1','TruthValue','read-write')
        self.tnPortFastLeaveEnabled=('.1.3.6.1.4.1.868.2.5.115.2.1.2.1.1.2','TruthValue','read-write')
        self.tnPortThrottling=('.1.3.6.1.4.1.868.2.5.115.2.1.2.1.1.3','Unsigned32','read-write')
        self.tnVlanIpmcSnoopingEnabled=('.1.3.6.1.4.1.868.2.5.115.2.1.3.1.1.2','TruthValue','read-create')
        self.tnVlanIpmcQuerierEnabled=('.1.3.6.1.4.1.868.2.5.115.2.1.3.1.1.3','TruthValue','read-create')
        self.tnVlanIpmcCompatibility=('.1.3.6.1.4.1.868.2.5.115.2.1.3.1.1.4','INTEGER','read-create')
        self.tnVlanIpmcSnoopingRV=('.1.3.6.1.4.1.868.2.5.115.2.1.3.1.1.5','Unsigned32','read-create')
        self.tnVlanIpmcSnoopingQI=('.1.3.6.1.4.1.868.2.5.115.2.1.3.1.1.6','Unsigned32','read-create')
        self.tnVlanIpmcSnoopingQRI=('.1.3.6.1.4.1.868.2.5.115.2.1.3.1.1.7','Unsigned32','read-create')
        self.tnVlanIpmcSnoopingLLQI=('.1.3.6.1.4.1.868.2.5.115.2.1.3.1.1.8','Unsigned32','read-create')
        self.tnVlanIpmcSnoopingURI=('.1.3.6.1.4.1.868.2.5.115.2.1.3.1.1.9','Unsigned32','read-create')
        self.tnVlanIpmcRowStatus=('.1.3.6.1.4.1.868.2.5.115.2.1.3.1.1.10','RowStatus','read-create')
        self.tnPortFilterRowStatus=('.1.3.6.1.4.1.868.2.5.115.2.1.4.1.1.3','Integer32','read-create')
        self.tnPortStatusRouteEnabled=('.1.3.6.1.4.1.868.2.5.115.2.1.5.1.1.1','TruthValue','read-only')
        self.tnVlanStatisticQuerierVersion=('.1.3.6.1.4.1.868.2.5.115.2.1.6.1.1.2','TnIpmcVersion','read-only')
        self.tnVlanStatisticHostVersion=('.1.3.6.1.4.1.868.2.5.115.2.1.6.1.1.3','TnIpmcVersion','read-only')
        self.tnVlanStatisticQuerierState=('.1.3.6.1.4.1.868.2.5.115.2.1.6.1.1.4','INTEGER','read-only')
        self.tnVlanStatisticQuerierTx=('.1.3.6.1.4.1.868.2.5.115.2.1.6.1.1.5','Counter32','read-only')
        self.tnVlanStatisticQuerierRx=('.1.3.6.1.4.1.868.2.5.115.2.1.6.1.1.6','Counter32','read-only')
        self.tnVlanStatisticV1ReportsRx=('.1.3.6.1.4.1.868.2.5.115.2.1.6.1.1.7','Counter32','read-only')
        self.tnVlanStatisticV2ReportsRx=('.1.3.6.1.4.1.868.2.5.115.2.1.6.1.1.8','Counter32','read-only')
        self.tnVlanStatisticV3ReportsRx=('.1.3.6.1.4.1.868.2.5.115.2.1.6.1.1.9','Counter32','read-only')
        self.tnVlanStatisticLeavesRx=('.1.3.6.1.4.1.868.2.5.115.2.1.6.1.1.10','Counter32','read-only')
        self.tnIpmcGroupPortList=('.1.3.6.1.4.1.868.2.5.115.2.1.7.1.1.3','PortList','read-only')
        self.tnIpmcSfmMode=('.1.3.6.1.4.1.868.2.5.115.2.1.8.1.1.5','INTEGER','read-only')
        self.tnIpmcSfmSrcType=('.1.3.6.1.4.1.868.2.5.115.2.1.8.1.1.6','INTEGER','read-only')
        self.tnIpmcSfmHardFilter=('.1.3.6.1.4.1.868.2.5.115.2.1.8.1.1.7','TruthValue','read-only')
        self.ip = ip
        ret = ispingable(self.ip)
        if (ret == True):
            self.sess=netsnmp.Session(Version=2,DestHost=self.ip,Community='private')
            print "ipmc init on :" + ip
        else:
            print ip + " is not pingable!"
    def __getvlanSnoopingIndex(self,type='IGMP',vid=1):
        if (type == 'IGMP' ):
            index = '1.'
        elif (type == 'MLD'):
            index = '2.'
        else:
            print "the type value is wrong,only 'IGMP' and 'MLD' is supported!"
            return 0
        self.vid = vid
        index = index + str(self.vid)
        return index
    def vlanSnooping_add(self,type='IGMP',vid=1,enable=True):
        """
        add new Vlan IPMC Snooping item
        vid is the vlan id
        enable define whether to enable this item
        """
        index = self.__getvlanSnoopingIndex(type,vid)
        if (enable == True):
            en = 1
        elif (enable == False):
            en =2
        pEnable = netsnmp.Varbind(self.tnVlanIpmcSnoopingEnabled[0],index,en,getType(self.tnVlanIpmcSnoopingEnabled[1]))
        pRs = netsnmp.Varbind(self.tnVlanIpmcRowStatus[0],index,4,getType(self.tnVlanIpmcRowStatus[1]))
        pQuery = netsnmp.Varbind(self.tnVlanIpmcQuerierEnabled[0],index,en,getType(self.tnVlanIpmcQuerierEnabled[1]))
        vars = netsnmp.VarList(pEnable,pQuery,pRs)
        ret = self.sess.set(vars)
        if (ret == 1):
            if (self.lindex.count(index) == 0):
                self.lindex.append(index)
            print "New "+ type + " Vlan Snooping item "+str(self.vid)+" added!"
        else:
            print "New "+ type + " Vlan Snooping item "+str(self.vid)+" creation failed!"
        return ret
    def vlanSnooping_del(self,type='IGMP',vid=1):
        """
        Delete the Vlan IPMC snooping item with index type.vid
        """
        index =  self.__getvlanSnoopingIndex(type,vid)
        pRs = netsnmp.Varbind(self.tnVlanIpmcRowStatus[0],index,6,getType(self.tnVlanIpmcRowStatus[1]))
        tRs = netsnmp.Varbind(self.tnVlanIpmcRowStatus[0],index)
        tvars = netsnmp.VarList(tRs)
        rets = self.sess.get(tvars)
        if (self.lindex.count(index) == 0):
            print "No item found with index "+ index
        try:
            failed = 0
            print "Get operation retuslt is " + rets[0]
        except: 
            failed = 1
            print "The item "+str(self.vid)+" is not exist !"
            return 0
        vars=netsnmp.VarList(pRs)
        ret =self.sess.set(vars)
        if (ret == 1):
            if (self.lindex.count(index) == 1):
                self.lindex.remove(index)
            print "Vlan "+ str(self.vid)+type+" item removed!"
        else:
            print "Vlan "+ str(self.vid)+type + "Failed to remove!"
        return ret
    def vlanSnooping_set_Enable(self,type='IGMP',vid=1,enable=True):
        if (enable == True):
            en = 1
        elif (enable ==False):
            en = 2
        index =  self.__getvlanSnoopingIndex(type,vid)
        pEn = netsnmp.Varbind(self.tnVlanIpmcSnoopingEnabled[0],index,en,getType(tnVlanIpmcSnoopingEnabled[1]))
        vars = netsnmp.VarList(pEn)
        ret = self.sess.set(vars)
        if (ret == 1):
            print "Seting "+str(enable)+str(type)+index+"succeed!"
            return 1
        else:
            print "Seting "+str(enable)+str(type)+index+"Failed!"
            return 0
    def vlanSnooping_get_Enable(self,type='IGMP',vid=1):
        index =  self.__getvlanSnoopingIndex(type,vid)
        pEn = netsnmp.Varbind(self.tnVlanIpmcSnoopingEnabled[0],index)
        vars = netsnmp.VarList(pEn)
        res = self.sess.get(vars)
       # if (res == 1):
        for var in vars:
            return var
        #else:
        #    print 'Get operation is failed on '+str(self.vid)+" Vlan"
        #    return 0
