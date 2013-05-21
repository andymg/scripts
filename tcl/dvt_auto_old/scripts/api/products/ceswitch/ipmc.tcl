#!/bin/tcl
# file: ipmc.tcl
# This file is a basic module file for ipmc testting
# Data: 2013-05-16
# Author: andym

catch [source ./util.tcl]

namespace eval ipmcoid {
set tnIpmcSnoopingEnabled(oid) 1.3.6.1.4.1.868.2.5.115.2.1.1.1.1.2
set tnIpmcSnoopingEnabled(type) TruthValue 
set tnIpmcSnoopingEnabled(access) read-write
set tnIpmcSnoopingFloodingEnabled(oid) 1.3.6.1.4.1.868.2.5.115.2.1.1.1.1.3
set tnIpmcSnoopingFloodingEnabled(type) TruthValue 
set tnIpmcSnoopingFloodingEnabled(access) read-write
set tnIpmcSnoopingLeaveProxyEnabled(oid) 1.3.6.1.4.1.868.2.5.115.2.1.1.1.1.4
set tnIpmcSnoopingLeaveProxyEnabled(type) TruthValue 
set tnIpmcSnoopingLeaveProxyEnabled(access) read-write
set tnIpmcSnoopingProxyEnabled(oid) 1.3.6.1.4.1.868.2.5.115.2.1.1.1.1.5
set tnIpmcSnoopingProxyEnabled(type) TruthValue 
set tnIpmcSnoopingProxyEnabled(access) read-write
set tnIpmcSnoopingSsmRange(oid) 1.3.6.1.4.1.868.2.5.115.2.1.1.1.1.6
set tnIpmcSnoopingSsmRange(type) InetAddress 
set tnIpmcSnoopingSsmRange(access) read-write
set tnIpmcSnoopingSsmRangePrefix(oid) 1.3.6.1.4.1.868.2.5.115.2.1.1.1.1.7
set tnIpmcSnoopingSsmRangePrefix(type) InetAddressPrefixLength 
set tnIpmcSnoopingSsmRangePrefix(access) read-write
set tnIpmcSnoopingStatisticClear(oid) 1.3.6.1.4.1.868.2.5.115.2.1.1.1.1.8
set tnIpmcSnoopingStatisticClear(type) TruthValue 
set tnIpmcSnoopingStatisticClear(access) read-write
set tnPortRoutePortEnabled(oid) 1.3.6.1.4.1.868.2.5.115.2.1.2.1.1.1
set tnPortRoutePortEnabled(type) TruthValue 
set tnPortRoutePortEnabled(access) read-write
set tnPortFastLeaveEnabled(oid) 1.3.6.1.4.1.868.2.5.115.2.1.2.1.1.2
set tnPortFastLeaveEnabled(type) TruthValue 
set tnPortFastLeaveEnabled(access) read-write
set tnPortThrottling(oid) 1.3.6.1.4.1.868.2.5.115.2.1.2.1.1.3
set tnPortThrottling(type) Unsigned32 
set tnPortThrottling(access) read-write
set tnVlanIpmcSnoopingEnabled(oid) 1.3.6.1.4.1.868.2.5.115.2.1.3.1.1.2
set tnVlanIpmcSnoopingEnabled(type) TruthValue 
set tnVlanIpmcSnoopingEnabled(access) read-create
set tnVlanIpmcQuerierEnabled(oid) 1.3.6.1.4.1.868.2.5.115.2.1.3.1.1.3
set tnVlanIpmcQuerierEnabled(type) TruthValue 
set tnVlanIpmcQuerierEnabled(access) read-create
set tnVlanIpmcCompatibility(oid) 1.3.6.1.4.1.868.2.5.115.2.1.3.1.1.4
set tnVlanIpmcCompatibility(type) INTEGER 
set tnVlanIpmcCompatibility(access) read-create
set tnVlanIpmcSnoopingRV(oid) 1.3.6.1.4.1.868.2.5.115.2.1.3.1.1.5
set tnVlanIpmcSnoopingRV(type) Unsigned32 
set tnVlanIpmcSnoopingRV(access) read-create
set tnVlanIpmcSnoopingQI(oid) 1.3.6.1.4.1.868.2.5.115.2.1.3.1.1.6
set tnVlanIpmcSnoopingQI(type) Unsigned32 
set tnVlanIpmcSnoopingQI(access) read-create
set tnVlanIpmcSnoopingQRI(oid) 1.3.6.1.4.1.868.2.5.115.2.1.3.1.1.7
set tnVlanIpmcSnoopingQRI(type) Unsigned32 
set tnVlanIpmcSnoopingQRI(access) read-create
set tnVlanIpmcSnoopingLLQI(oid) 1.3.6.1.4.1.868.2.5.115.2.1.3.1.1.8
set tnVlanIpmcSnoopingLLQI(type) Unsigned32 
set tnVlanIpmcSnoopingLLQI(access) read-create
set tnVlanIpmcSnoopingURI(oid) 1.3.6.1.4.1.868.2.5.115.2.1.3.1.1.9
set tnVlanIpmcSnoopingURI(type) Unsigned32 
set tnVlanIpmcSnoopingURI(access) read-create
set tnVlanIpmcRowStatus(oid) 1.3.6.1.4.1.868.2.5.115.2.1.3.1.1.10
set tnVlanIpmcRowStatus(type) RowStatus 
set tnVlanIpmcRowStatus(access) read-create
set tnPortFilterRowStatus(oid) 1.3.6.1.4.1.868.2.5.115.2.1.4.1.1.3
set tnPortFilterRowStatus(type) Integer32 
set tnPortFilterRowStatus(access) read-create
set tnPortStatusRouteEnabled(oid) 1.3.6.1.4.1.868.2.5.115.2.1.5.1.1.1
set tnPortStatusRouteEnabled(type) TruthValue 
set tnPortStatusRouteEnabled(access) read-only
set tnVlanStatisticQuerierVersion(oid) 1.3.6.1.4.1.868.2.5.115.2.1.6.1.1.2
set tnVlanStatisticQuerierVersion(type) TnIpmcVersion 
set tnVlanStatisticQuerierVersion(access) read-only
set tnVlanStatisticHostVersion(oid) 1.3.6.1.4.1.868.2.5.115.2.1.6.1.1.3
set tnVlanStatisticHostVersion(type) TnIpmcVersion 
set tnVlanStatisticHostVersion(access) read-only
set tnVlanStatisticQuerierState(oid) 1.3.6.1.4.1.868.2.5.115.2.1.6.1.1.4
set tnVlanStatisticQuerierState(type) INTEGER 
set tnVlanStatisticQuerierState(access) read-only
set tnVlanStatisticQuerierTx(oid) 1.3.6.1.4.1.868.2.5.115.2.1.6.1.1.5
set tnVlanStatisticQuerierTx(type) Counter32 
set tnVlanStatisticQuerierTx(access) read-only
set tnVlanStatisticQuerierRx(oid) 1.3.6.1.4.1.868.2.5.115.2.1.6.1.1.6
set tnVlanStatisticQuerierRx(type) Counter32 
set tnVlanStatisticQuerierRx(access) read-only
set tnVlanStatisticV1ReportsRx(oid) 1.3.6.1.4.1.868.2.5.115.2.1.6.1.1.7
set tnVlanStatisticV1ReportsRx(type) Counter32 
set tnVlanStatisticV1ReportsRx(access) read-only
set tnVlanStatisticV2ReportsRx(oid) 1.3.6.1.4.1.868.2.5.115.2.1.6.1.1.8
set tnVlanStatisticV2ReportsRx(type) Counter32 
set tnVlanStatisticV2ReportsRx(access) read-only
set tnVlanStatisticV3ReportsRx(oid) 1.3.6.1.4.1.868.2.5.115.2.1.6.1.1.9
set tnVlanStatisticV3ReportsRx(type) Counter32 
set tnVlanStatisticV3ReportsRx(access) read-only
set tnVlanStatisticLeavesRx(oid) 1.3.6.1.4.1.868.2.5.115.2.1.6.1.1.10
set tnVlanStatisticLeavesRx(type) Counter32 
set tnVlanStatisticLeavesRx(access) read-only
set tnIpmcGroupPortList(oid) 1.3.6.1.4.1.868.2.5.115.2.1.7.1.1.3
set tnIpmcGroupPortList(type) PortList 
set tnIpmcGroupPortList(access) read-only
set tnIpmcSfmMode(oid) 1.3.6.1.4.1.868.2.5.115.2.1.8.1.1.5
set tnIpmcSfmMode(type) INTEGER 
set tnIpmcSfmMode(access) read-only
set tnIpmcSfmSrcType(oid) 1.3.6.1.4.1.868.2.5.115.2.1.8.1.1.6
set tnIpmcSfmSrcType(type) INTEGER 
set tnIpmcSfmSrcType(access) read-only
set tnIpmcSfmHardFilter(oid) 1.3.6.1.4.1.868.2.5.115.2.1.8.1.1.7
set tnIpmcSfmHardFilter(type) TruthValue 
set tnIpmcSfmHardFilter(access) read-only
}

namespace import util::*
namespace eval ipmc {
    namespace export *
}

# ipmc::enableIpmcSnooping IGMP True
# ipmc::enableIpmcSnooping MLD False
proc ipmc::ipmcSnoopingEnable {type enable} {
	set ipmctype [string toupper $type]
	if { $ipmctype == "IGMP"} {
		set index "1"
	} elseif  { $ipmctype == "MLD"} {
		set index "2"
	} else {
		puts "unknow IPMC type"
	}
	set cmd "exec snmpset $::session"
	if { $enable } {
		set ipmcenable "$ipmcoid::tnIpmcSnoopingEnabled(oid).$index [getType $ipmcoid::tnIpmcSnoopingEnabled(type)] 1"
	}
	if { $enable == False } {
		set ipmcenable "$ipmcoid::tnIpmcSnoopingEnabled(oid).$index [getType $ipmcoid::tnIpmcSnoopingEnabled(type)] 2"
	}
	append cmd " $ipmcenable"
	set ret [catch {eval $cmd} error]
	if {$ret} {puts $error}

}
# ipmc::vlanSnoopingAdd add new vlan item
proc ipmc::vlanSnoopingAdd {{type IGMP} {vid 1} {enable True}} {
	set ipmctype [string toupper $type]
	if { $ipmctype == "IGMP"} {
		set index "1.$vid"
	} elseif  { $ipmctype == "MLD"} {
		set index "2.$vid"
	} else {
		puts "unknow IPMC type"
	}
	if { $enable } {
	set en 1 
	}
	if { $enable == False } {
	set en 2
	}
	set pEnable "$ipmcoid::tnVlanIpmcSnoopingEnabled(oid).$index [getType $ipmcoid::tnVlanIpmcSnoopingEnabled(type)] $en"
	set pRs "$ipmcoid::tnVlanIpmcRowStatus(oid).$index [getType $ipmcoid::tnVlanIpmcRowStatus(type)] 4"
	set pQuery "$ipmcoid::tnVlanIpmcQuerierEnabled(oid).$index [getType $ipmcoid::tnVlanIpmcQuerierEnabled(type)] $en"
	set cmd "exec snmpset $::session"
	append cmd " $pEnable $pQuery $pRs"
	set ret [catch {eval $cmd} error]
	if { $ret } { puts $error ;puts "vlanSnoopingAdd commit $type $vid $enable Failed";return 0}
	puts "vlanSnoopingAdd vid: $vid,type: $type, enable: $enable succeed"

}
# ipmc::vlanSnoopingDel delete seleted vlan ipmc item
# ipmc::vlanSnoopingDel IGMP 2
proc ipmc::vlanSnoopingDel {{type "IGMP"} {vid 1} } {
	set ipmctype [string toupper $type]
	if { $ipmctype == "IGMP"} {
		set index "1.$vid"
	} elseif  { $ipmctype == "MLD"} {
		set index "2.$vid"
	} else {
		puts "unknow IPMC type"
	}
	set set pRs "$ipmcoid::tnVlanIpmcRowStatus(oid).$index [getType $ipmcoid::tnVlanIpmcRowStatus(type)] 4"
	set cmd "exec snmpset $::session"
	append cmd " $pRs"
	set ret [catch {eval $cmd} error]
	if { $ret } {puts $error;puts "vlanSnoopingDel commit $type $vid $enable Failed"}
}

proc ipmc::vlanSnoopingGetEnable {{type IGMP} {vid 1}} {
	set ipmctype [string toupper $type]
	if { $ipmctype == "IGMP"} {
		set index "1.$vid"
	} elseif  { $ipmctype == "MLD"} {
		set index "2.$vid"
	} else {
		puts "unknow IPMC type"
	}
	set pEn "$ipmcoid::tnVlanIpmcSnoopingEnabled(oid).$index"
	set cmd "exec snmpget $::session"
	append cmd " $pEn"
	set ret [eval $cmd]
	puts $ret
}
proc ipmc::vlanSnoopingGetEnable {{type IGMP} {vid 1}} {
	set ipmctype [string toupper $type]
	if { $ipmctype == "IGMP"} {
		set index "1.$vid"
	} elseif  { $ipmctype == "MLD"} {
		set index "2.$vid"
	} else {
		puts "unknow IPMC type"
	}
	set pEn "$ipmcoid::tnVlanIpmcSnoopingEnabled(oid).$index"
	set cmd "exec snmpget $::session"
	append cmd " $pEn"
	set ret [eval $cmd]
	puts $ret
}

proc ipmc::ipmcGroupGet { } {
	set pGroup "$ipmcoid::tnIpmcGroupPortList(oid)"
	set cmd "exec snmpwalk $::session"
	append cmd " $pGroup"
	puts $cmd
	set ret [eval $cmd]
	puts $ret
	# The endline character in net-snmp is \n
	set result [split $ret "\n"]
	set count [expr [llength $result]/4]
	list r ""
	foreach res $result {
		foreach {oid equal rtype value} $res {
		set vid [string index $oid 50]
		set type [string index $oid 48]
		set len [string index $oid 52]
		if {$len == 4} {
			set group [string range $oid 54 end]
		}
		if { $type == 1} { set type "IGMP" }
		if { $type == 2} { set type "MLD" }
		set ports [portListToPort $value]
		if { $type == "IGMP" || $type == "MLD"} {
			lappend r "$type $vid $group $ports"
		}
	}
	}
	if {[info exist r]} {
		return $r	
	}
}