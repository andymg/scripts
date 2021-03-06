#!/bin/tclsh

namespace eval util {
namespace export *
proc mac2index {mac} {
	if {[string first : $mac]} {
		set mac_str [split $mac ':']	
	} 
	if {[string first - $mac] != -1 } {
		set mac_str [split $mac -]
	}
    set index ''
    foreach i $mac_str {
    	set hex 0x$i
    	scan $hex %x decv
    	set index "$index.$decv"
    }
    return [string range $index [expr [string first . $index] + 1] end]
}

proc getType {mibtype} {
	set type(VlanIndex) u
	set type(PortList) x
	set type(INTEGER) i
	set type(RowStatus) i
	set type(TruthValue) i
	set type(InetAddress) s
	set type(Unsigned32) u
	set type(EightOTwoOui) s
    #if ([catch [info exist $type($mibtype)]]) {
    #	puts "$mibtype is not mapped in getType()"
    #}
    return $type($mibtype)
}

proc ispingable { ip } {
	catch {
		set ret [exec ping -c 2 -w 3 $ip]
	}
	if {[info exist ret] == 0} {

		puts "$ip is not pingable"
		return -1
	}
	puts "$ip is pingable"
	return 1
}
proc getParam {params type} {
   foreach {handle para} $params {
      if {[regexp {^-(.*)} $handle all handleval]} {
          lappend handlelist $handleval
          lappend paralist $para
      }
   }
   if {[set idx [lsearch $handlelist $type]] != -1} {
    return  [lindex $paralist $idx]
   } else {
     puts "unknow type $type"
     return -1
   }
}
}
