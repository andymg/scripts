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

proc portListToPort { hex } {
	set hexv 0x$hex
	scan $hexv %x value
	set port ""
	set rel 2
	while { $rel > 1 } {
		set rel [expr $value/2]
		set y [expr $value%2]
		set value $rel
		append port $y
	}
	append port 1
	set len [string length $port]
	set ports [expr $::portNo-$len+1]
	for { set i [expr 8-$len+2]} {$i < 9 } {incr i} {
		if {[string index $port [expr 8-$i]] == 1} {
			set j [expr 8-$i]
			puts $::portNo
			lappend ports [expr $::portNo-$j]
		}
	}
	return $ports
}
proc getPortNo { dut } {
	set cmd "exec snmpwalk -v2c -c private $dut ifName"
	set ret [eval $cmd]
	set count [llength [split $ret '\n']]
	return [expr (($count-1)/4)*4]
}
}
