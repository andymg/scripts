#!/usr/bin/tclsh
###!/usr/local/ixos/bin/ixwish
#IxTclHal version 5.20.0.165
#Tcl version 8.4
#file: test ixia base function
package req IxTclHal

set ::ixiaIpAddr 192.168.1.21
set ::ixiaPort1 3,2
set ::ixiaPort2 3,3

set username andyixia
set hostname 192.168.1.21
set retCode [ixConnectToTclServer $hostname]
puts "Connect to server result is $retCode"

set retCode [ixLogin $username]
puts "login resutlt is $retCode"

set retCode [ixConnectToChassis $hostname]
puts "connect chassis result $retCode"

set chasID [ixGetChassisID $hostname]
set card 3
set port 2

set portList [list [list $chasID $card $port]]
set retCode [ixTakeOwnership $portList force]
puts "ixTakeOwnership result $retCode"

foreach portl $portList {
	scan $portl "%d %d %d" chasNum cardNum portNum
	port setFactoryDefaults $chasNum $cardNum $portNum
	port write $chasNum $cardNum $portNum
}

	version get
	set osVer [version cget -installVersion]
	puts "osVer is $osVer"
	set halVer [version cget -ixTclHALVersion]
	puts "halVer is $halVer"
	set pdtVer [version cget -productVersion]
	puts "pdtVer is $pdtVer"

proc connect_ixia {args} {
	global tcLogId 
	set aftertime 5000
	puts "start"
	#1. get command and handle/parameters
	foreach {handle para} $args {
		if {[regexp {^-(.*)$} $handle all handleval]} {
			lappend handlelist $handleval
			lappend paralist $para
		}
	}
	puts "handle list $handlelist"
	puts "paralist list $paralist"
	puts "parse paramters"
}

connect_ixia -ipaddr $::ixiaIpAddr -portlist $::ixiaPort1,ixiap1,$::ixiaPort2,ixiap2 -alias allport -loginname tianlong