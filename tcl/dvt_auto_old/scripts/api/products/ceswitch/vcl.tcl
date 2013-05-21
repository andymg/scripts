#!/bin/tcl
#file: vcl base module
global ::session ""

namespace eval vcloid {
set tnVclMacBasedVlanId(oid) 1.3.6.1.4.1.868.2.5.4.1.8.1.1.1.2
set tnVclMacBasedVlanId(type) VlanIndex 
set tnVclMacBasedVlanId(access) read-create
set tnVclMacBasedPortMember(oid) 1.3.6.1.4.1.868.2.5.4.1.8.1.1.1.3
set tnVclMacBasedPortMember(type) PortList 
set tnVclMacBasedPortMember(access) read-create
set tnVclMacBasedUser(oid) 1.3.6.1.4.1.868.2.5.4.1.8.1.1.1.4
set tnVclMacBasedUser(type) INTEGER 
set tnVclMacBasedUser(access) read-only
set tnVclMacBasedRowStatus(oid) 1.3.6.1.4.1.868.2.5.4.1.8.1.1.1.5
set tnVclMacBasedRowStatus(type) RowStatus 
set tnVclMacBasedRowStatus(access) read-create
set tnVclProtoBasedGroupMapProtocol(oid) 1.3.6.1.4.1.868.2.5.4.1.8.2.1.1.2
set tnVclProtoBasedGroupMapProtocol(type) INTEGER 
set tnVclProtoBasedGroupMapProtocol(access) read-create
set tnVclProtoBasedGroupMapEtherTypeVal(oid) 1.3.6.1.4.1.868.2.5.4.1.8.2.1.1.3
set tnVclProtoBasedGroupMapEtherTypeVal(type) INTEGER 
set tnVclProtoBasedGroupMapEtherTypeVal(access) read-create
set tnVclProtoBasedGroupMapSnapOui(oid) 1.3.6.1.4.1.868.2.5.4.1.8.2.1.1.4
set tnVclProtoBasedGroupMapSnapOui(type) EightOTwoOui 
set tnVclProtoBasedGroupMapSnapOui(access) read-create
set tnVclProtoBasedGroupMapSnapPid(oid) 1.3.6.1.4.1.868.2.5.4.1.8.2.1.1.5
set tnVclProtoBasedGroupMapSnapPid(type) INTEGER 
set tnVclProtoBasedGroupMapSnapPid(access) read-create
set tnVclProtoBasedGroupMapLlcDsap(oid) 1.3.6.1.4.1.868.2.5.4.1.8.2.1.1.6
set tnVclProtoBasedGroupMapLlcDsap(type) INTEGER 
set tnVclProtoBasedGroupMapLlcDsap(access) read-create
set tnVclProtoBasedGroupMapLlcSsap(oid) 1.3.6.1.4.1.868.2.5.4.1.8.2.1.1.7
set tnVclProtoBasedGroupMapLlcSsap(type) INTEGER 
set tnVclProtoBasedGroupMapLlcSsap(access) read-create
set tnVclProtoBasedGroupMapRowStatus(oid) 1.3.6.1.4.1.868.2.5.4.1.8.2.1.1.8
set tnVclProtoBasedGroupMapRowStatus(type) RowStatus 
set tnVclProtoBasedGroupMapRowStatus(access) read-create
set tnVclProtoBasedVlanMapPortMember(oid) 1.3.6.1.4.1.868.2.5.4.1.8.2.2.1.2
set tnVclProtoBasedVlanMapPortMember(type) PortList 
set tnVclProtoBasedVlanMapPortMember(access) read-create
set tnVclProtoBasedVlanMapRowStatus(oid) 1.3.6.1.4.1.868.2.5.4.1.8.2.2.1.3
set tnVclProtoBasedVlanMapRowStatus(type) RowStatus 
set tnVclProtoBasedVlanMapRowStatus(access) read-create
set tnVclIpSubnetBasedIpAddr(oid) 1.3.6.1.4.1.868.2.5.4.1.8.3.1.1.2
set tnVclIpSubnetBasedIpAddr(type) IpAddress 
set tnVclIpSubnetBasedIpAddr(access) read-create
set tnVclIpSubnetBasedMaskLen(oid) 1.3.6.1.4.1.868.2.5.4.1.8.3.1.1.3
set tnVclIpSubnetBasedMaskLen(type) INTEGER 
set tnVclIpSubnetBasedMaskLen(access) read-create
set tnVclIpSubnetBasedVlanId(oid) 1.3.6.1.4.1.868.2.5.4.1.8.3.1.1.4
set tnVclIpSubnetBasedVlanId(type) VlanIndex 
set tnVclIpSubnetBasedVlanId(access) read-create
set tnVclIpSubnetBasedPortMember(oid) 1.3.6.1.4.1.868.2.5.4.1.8.3.1.1.5
set tnVclIpSubnetBasedPortMember(type) PortList 
set tnVclIpSubnetBasedPortMember(access) read-create
set tnVclIpSubnetBasedRowStatus(oid) 1.3.6.1.4.1.868.2.5.4.1.8.3.1.1.6
set tnVclIpSubnetBasedRowStatus(type) RowStatus 
set tnVclIpSubnetBasedRowStatus(access) read-create
}


namespace import util::*
namespace eval vcl {
    namespace export *
}
#Function vcl::vclMacBasedVlan_add
#params:
#mac: mac address
#vid: vid value
#member: the port list for ports which are seleted

proc vcl::vclMacBasedVlan_add {mac {vid 1} {member 0x80}} {
	set cs private
	set dut 192.168.3.53
	set commu private
    set ::session "-v2c -c private $dut"
	
    set maci [mac2index $mac]
	set index "6.$maci"
    
    set cmd "exec snmpset $::session"
    
    set Vlanid "$vcloid::tnVclMacBasedVlanId(oid).$index [getType $vcloid::tnVclMacBasedVlanId(type)] $vid"
    set pMember "$vcloid::tnVclMacBasedPortMember(oid).$index [getType $vcloid::tnVclMacBasedPortMember(type)] $member"
    set pRs "$vcloid::tnVclMacBasedRowStatus(oid).$index [getType $vcloid::tnVclMacBasedRowStatus(type)] 4"
    append cmd " $Vlanid $pMember $pRs"
   # puts $cmd
    set ret [eval $cmd]

}
