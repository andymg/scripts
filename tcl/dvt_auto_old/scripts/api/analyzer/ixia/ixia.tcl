#source $::g_ixwishdir
package req IxTclHal
set ::errorInfo ""


# -ipaddr		x.x.x.x
# -portlist		slot,port,alias
# -alias		string (optional)
# -loginname	dvtAuto
# -dbgprt		[1|0]
# connect_ixia -ipaddr 192.168.0.21 -portlist 3,2,ixiap1,3,3,ixiap2 -alias allport -loginname auto -dbgprt 1
proc connect_ixia {args} {
	global tcLogId 
	set aftertime 5000
	#1. get command and handle/parameters
	foreach {handle para} $args {
		if {[regexp {^-(.*)$} $handle all handleval]} {
			lappend handlelist $handleval
			lappend paralist $para
		}
	}
	
	#2. set all parameter(default) value according user defination
	if {[info exist handlelist] && [info exist paralist]} {
		if {[set idx [lsearch $handlelist dbgprt]] != -1} {
			set dbgprtVal [lindex $paralist $idx]
		} else {
			set dbgprtVal 0
		}
		
		if {[set idx [lsearch $handlelist loginname]] != -1} {
			set userName [lindex $paralist $idx]
		} else {
			set userName dvtAuto
		}
		if {$dbgprtVal == 1} {puts "@@ loginname: $userName"}
		
		if {[set idx [lsearch $handlelist ipaddr]] != -1} {
			set ixiaIp [lindex $paralist $idx]
			if {$dbgprtVal == 1} {puts "@@ ipaddr: $ixiaIp"}
		} else {
			uWriteExp -errorinfo "proc: connect_ixia, ipaddress is a mandatory parameter but missing"
		}
		
		
		# login and connected to chassis
		ixConnectToTclServer $ixiaIp
		ixLogin $userName
		ixConnectToChassis $ixiaIp
		set chasId [ixGetChassisID $ixiaIp]
		if {$dbgprtVal == 1} {puts "@@ chasId: $chasId"}
		
		if {[set idx [lsearch $handlelist alias]] != -1} {
			set aliasval [lindex $paralist $idx]
			if {$dbgprtVal == 1} {puts "@@ alias: $aliasval"}
		}
		
		if {[set idx [lsearch $handlelist portlist]] != -1} {
			set portval [lindex $paralist $idx]
			set portlistval [split $portval ,]
			if {$dbgprtVal == 1} {puts "@@ portlistval: $portlistval"}
			foreach {slotid portid portalias} $portlistval {
				set $portalias [list [list $chasId $slotid $portid]]
				if {$dbgprtVal == 1} {puts "@@ $portalias: [list [list $chasId $slotid $portid]]"}
				eval [subst {uplevel #0 {set $portalias "[list [list $chasId $slotid $portid]]"}}]
				lappend allList [list $chasId $slotid $portid]
			}
			if {[info exist aliasval]} {
				set $aliasval $allList
				if {$dbgprtVal == 1} {puts "@@ $aliasval: $allList"}
				eval [subst {uplevel #0 {set $aliasval "$allList"}}]
			}
		} else {
			uWriteExp -errorinfo "proc: connect_ixia, portlist is a mandatory parameter but missing"
			
		}
	
	} else {
		uWriteExp -errorinfo "proc: connect_ixia, args: $args, input parameter error!"
	}
	
	#3. take ownership and set factory default
	ixTakeOwnership $allList force
	puts "ixTakeOwnership ok"
	foreach port $allList {
		scan $port "%d %d %d" chasNum cardNum portNum
		port setFactoryDefaults $chasNum $cardNum $portNum
		port write $chasNum $cardNum $portNum
	}
	after $aftertime
	
	#4. put ixia versions
	version get
	set osVer [version cget -installVersion]
	puts "osVer is $osVer"
	set halVer [version cget -ixTclHALVersion]
	puts "halVer is $halVer"
	set pdtVer [version cget -productVersion]
	puts "pdtVer $pdtVer"
	
	set logInfo "connect_ixia,take ownership and set factory default of port(s)"
	#printlog -fileid $tcLogId -res conf -cmd $logInfo -comment $allList
	set verStr "ixia version, product: $pdtVer, OS: $osVer, HAL: $halVer"
	#printlog -fileid $tcLogId -res chck -cmd $verStr
	
}

# -alias 
# -autonego
# -duplex
# -phymode
# -dbgprt [0|1]
# config_portprop -alias allport -autonego enable -phymode copper -duplex 10h,10f,100h,100f -dbgprt 1
proc config_portprop {args} {
	global tcLogId
	set aftertime 1000
	#port properties, check link status, clear stat, 
	#1. get command and handle/parameters
	foreach {handle para} $args {
		if {[regexp {^-(.*)$} $handle all handleval]} {
			lappend handlelist $handleval
			lappend paralist $para
		}
	}
	
	#2. set all parameter(default) value according user defination
	if {[info exist handlelist] && [info exist paralist]} {
		if {[set idx [lsearch $handlelist dbgprt]] != -1} {
			set dbgprtVal [lindex $paralist $idx]
		} else {
			set dbgprtVal 0
		}
		
		if {[set idx [lsearch $handlelist autonego]] != -1} {
			set autonegoVal [lindex $paralist $idx]
			switch $autonegoVal {
				enable 	{set autoNegoMode true}
				disable {set autoNegoMode false}
				default {uWriteExp -errorinfo "wrong autonego parameter"}
			}
			if {$dbgprtVal == 1} {puts "@@ autonego: $autonegoVal"}
		}
		
		if {[set idx [lsearch $handlelist phymode]] != -1} {
			set phymodeVal [lindex $paralist $idx]
			switch $phymodeVal {
				copper {set phymode portPhyModeCopper}
				fiber {set phymode portPhyModeFiber}
				default {uWriteExp -errorinfo "wrong phymode parameter"}
			}
			if {$dbgprtVal == 1} {puts "@@ phymode: $phymodeVal"}
		}
		
		if {[set idx [lsearch $handlelist alias]] != -1} {
			set aliasval [lindex $paralist $idx]
			if {$dbgprtVal == 1} {puts "@@ alias: $aliasval"}
		}
		
		if {[set idx [lsearch $handlelist duplex]] != -1} {
			set duplexVal [lindex $paralist $idx]
			if {$dbgprtVal == 1} {puts "@@ duplex: $duplexVal"}
		}
	
	} else {
		uWriteExp -errorinfo "proc: connect_ixia, args: $args, input parameter error!"
	}
	
	global [subst $aliasval]
	if {$dbgprtVal == 1} {puts "@@ portList: [subst $$aliasval]"}	
	foreach port [subst $$aliasval] {
		scan $port "%d %d %d" chasNum cardNum portNum
		if {[info exist phymodeVal]} {
			port setPhyMode $phymode $chasNum $cardNum $portNum
		}
		if {[info exist autonegoVal]} {
			port config -autonegotiate $autoNegoMode
		}
		
		if {[info exist duplexVal]} {
			set duplexList [split $duplexVal ,]
			if {$dbgprtVal == 1} {puts "@@ duplexList: $duplexList"}
			set falseDuplex [list 10h 10f 100h 100f 1000f]
			foreach duplexItem $duplexList {
				set idx [string first $duplexItem $falseDuplex]
				if {$idx != -1 } {
					set falseDuplex [string replace $falseDuplex $idx [string length $duplexItem]]
				}
				switch $duplexItem {
					10h 	{port config -advertise10HalfDuplex true}
					10f 	{port config -advertise10FullDuplex true}
					100h 	{port config -advertise100HalfDuplex true}
					100f 	{port config -advertise100FullDuplex true}
					1000f 	{port config -advertise1000FullDuplex true}
					default {uWriteExp -errorinfo "input duplex value error of duplexList"}
				}
				puts "set duplexItem "
			}
			
			if {$dbgprtVal == 1} {puts "@@ falseDuplex: $falseDuplex"}
			
			foreach forceDuplexItem $falseDuplex {
				switch $forceDuplexItem {
					10h 	{port config -advertise10HalfDuplex false}
					10f 	{port config -advertise10FullDuplex false}
					100h 	{port config -advertise100HalfDuplex false}
					100f 	{port config -advertise100FullDuplex false}
					1000f 	{port config -advertise1000FullDuplex false}
					default {uWriteExp -errorinfo "input duplex value error of falseDuplex"}
				}
			}
		}
	
		port set $chasNum $cardNum $portNum
		port write $chasNum $cardNum $portNum
	}
	
	for {set i 1} {$i<=10} {incr i} {
		after $aftertime
		if {[ixCheckLinkState $aliasval] == 0} {
			set linkst [ixCheckLinkState $aliasval]
			puts "ixCheckLinkState $linkst"
			break
		}
		if {$i == 10 && [ixCheckLinkState $aliasval] !=0} {
			#printlog -fileid $tcLogId -res chck -cmd "check all connected link status" -comment "One or more links status are down!"
		}
	}
	set logStr "config_portprop $args"
	puts $logStr
	#printlog -fileid $tcLogId -res conf -cmd $logStr
}



# -frametype
# -vlanmode
# -vlanid
# -priority
# -tpid
# -innervlanid
# -innerpriority
# -innertpid
# -qosmode
# -dscpmode
# -dscpvalue
# -srcip
# -dstip
# -srcmac
# -srcmacmode
# -srcrepeatcount
# -srcstep
# -dstmac
# -dstmacmode
# -dstrepeatcount
# -dststep
# -framesize
# config_frame -alias allport -frametype none -vlanmode singlevlan -vlanid 10 -priority 3 -dbgprt 1
proc config_frame {args} {
	global tcLogId
	#1. get command and handle/parameters
	set dbgprt_value 0
	
	foreach {handle para} $args {
		if {[regexp {^-(.*)$} $handle all handleval]} {
			lappend handlelist $handleval
			lappend paralist $para
		}
	}
	
	foreach item1 $handlelist item2 $paralist {
		set $item1\_value $item2
	}
	
	#2. set all of the parameters value
	if {[info exist alias_value]} {
		global [subst $alias_value]
		if {$dbgprt_value == 1} {puts "@@ alias: [subst $$alias_value]"}
	} else {
		uWriteExp -errorinfo "config_frame: alias is a mandatory parameter but missing"
	}
	
	foreach port [subst $$alias_value] {
		scan $port "%d %d %d" chasNum cardNum portNum
		stream get $chasNum $cardNum $portNum 1
		ip get $chasNum $cardNum $portNum
		#vlan get $chasNum $cardNum $portNum
		#stackedVlan get $chasNum $cardNum $portNum
	
		if {[info exist frametype_value]} {
			if {$dbgprt_value == 1} {puts "@@ frametype: $frametype_value"}
			switch [string tolower $frametype_value] {
				ethernetii {protocol config -ethernetType ethernetII; protocol config -name ipV4}
				none {protocol config -ethernetType noType}
				default {uWriteExp -errorinfo "input frametype error"}
			}
		}
		if {[info exist vlanmode_value]} {
			if {$dbgprt_value == 1} {puts "@@ vlanmode: $vlanmode_value"}
			switch $vlanmode_value {
				singlevlan {protocol config -enable802dot1qTag vlanSingle; vlan get $chasNum $cardNum $portNum}
				qinq {protocol config -enable802dot1qTag vlanStacked; stackedVlan get $chasNum $cardNum $portNum}
				none {protocol config -enable802dot1qTag vlanNone}
				default {uWriteExp -errorinfo "input frame vlanmode error"}
			}
		}
		# ethernetname_value ??????????
		if {[info exist ethernetname_value]} {
			if {$dbgprt_value == 1} {puts "@@ ethernetname: $ethernetname_value"}
			switch $ethernetname_value {
				ip {protocol config -name ip}
				ipv4 {protocol config -name ipV4}
				default {uWriteExp -errorinfo "input frame ethernetname error"}
			}
		}		
		if {[info exist vlanid_value]} {
			if {$dbgprt_value == 1} {puts "@@ vlanid: $vlanid_value"}
			vlan config -vlanID	$vlanid_value
			set getvlanmode [protocol cget -enable802dot1qTag]
			if {$getvlanmode == "2"} {
				stackedVlan setVlan 1
			}
		}
		if {[info exist priority_value]} {
			if {$dbgprt_value == 1} {puts "@@ priority: $priority_value"}
			vlan config -userPriority $priority_value
			set getvlanmode [protocol cget -enable802dot1qTag]
			if {$getvlanmode == "2"} {
				stackedVlan setVlan 1
			}
		}				
		if {[info exist tpid_value]} {
			vlan config -protocolTagId	0x$tpid_value
			set getvlanmode [protocol cget -enable802dot1qTag]
			if {$getvlanmode == "2"} {
				stackedVlan setVlan 1
			}
		}
		if {[info exist innervlanid_value]} {
			vlan config -vlanID	$innervlanid_value
			set getvlanmode [protocol cget -enable802dot1qTag]
			if {$getvlanmode == "2"} {
				stackedVlan setVlan 2
			}
		}
		if {[info exist innerpriority_value]} {
			vlan config -userPriority	$innerpriority_value
			set getvlanmode [protocol cget -enable802dot1qTag]
			if {$getvlanmode == "2"} {
				stackedVlan setVlan 2
			}
		}					
		if {[info exist innertpid_value]} {
			vlan config -protocolTagId	0x$innertpid_value
			set getvlanmode [protocol cget -enable802dot1qTag]
			if {$getvlanmode == "2"} {
				stackedVlan setVlan 2
			}		
		}
		if {[info exist qosmode_value]} {
			switch $qosmode_value {
				dscp {ip config -qosMode ipV4ConfigDscp}
				tos {ip config -qosMode ipV4ConfigTos}
				default {uWriteExp -errorinfo "input frame qosmode error"}
			}
		}
		if {[info exist dscpmode_value]} {
			switch $dscpmode_value {
				custom {ip config -dscpMode ipV4DscpCustom}
				default {ip config -dscpMode ipV4DscpDefault}
			}
		}
		if {[info exist dscpvalue_value]} {
			ip config -dscpValue [dectohex $dscpvalue_value]
		}		
		if {[info exist srcip_value]} {
			ip config -sourceIpAddr $srcip_value
		}
		if {[info exist dstip_value]} {
			ip config -destIpAddr $dstip_value 
		}
		
		if {[info exist srcmac_value]} {
			set macsaformat [join $srcmac_value]
			stream config -sa $macsaformat
		}
		if {[info exist srcmacmode_value]} {
			switch $srcmacmode_value {
				fixed {stream config -saRepeatCounter idle}
				increment {stream config -saRepeatCounter increment}
				default {uWriteExp -errorinfo "input frame srcmacmode error"}
			} 
		}
		if {[info exist srcstep_value]} {
			stream config -saStep $srcstep_value
		}
		if {[info exist srcrepeatcount_value]} {
			stream config -numSA $srcrepeatcount_value
		}	
		if {[info exist dstmac_value]} {
			set macdaformat [join $dstmac_value]
			stream config -da $macdaformat
		}
		if {[info exist dstmacmode_value]} {
			switch $dstmacmode_value {
				fixed {stream config -daRepeatCounter idle} 
				increment {stream config -daRepeatCounter increment} 
				default {uWriteExp -errorinfo "input frame dstmacmode error"}
			} 
		}
		if {[info exist dststep_value]} {
			stream config -daStep $dststep_value
		}
		if {[info exist dstrepeatcount_value]} {
			stream config -numDA $dstrepeatcount_value
		}
		if {[info exist framesize_value]} {
			stream config -framesize $framesize_value
		}
		
		
		set getvlanmode [protocol cget -enable802dot1qTag]
		if {$getvlanmode == "2"} {
			stackedVlan set $chasNum $cardNum $portNum
		} elseif {$getvlanmode == "1"} {
			vlan set $chasNum $cardNum $portNum
		}
		
		if {[info exist vlanmode_value]} {
			switch $vlanmode_value {
				singlevlan {vlan set $chasNum $cardNum $portNum}
				qinq {stackedVlan set $chasNum $cardNum $portNum}
			}
		}
		
		ip set $chasNum $cardNum $portNum
		stream set $chasNum $cardNum $portNum 1
		stream write $chasNum $cardNum $portNum 1
		
	}
	ixWriteConfigToHardware $alias_value
	set logStr "config_frame $args"
	#printlog -fileid $tcLogId -res conf -cmd $logStr
}

# -alias
# -sendmode
# -rate
# -pktperbst
# -bstperstrm
# config_stream -alias allport -sendmode contpkt 
proc config_stream {args} {
	global tcLogId
	#1. get command and handle/parameters
	set dbgprt_value 0
	
	foreach {handle para} $args {
		if {[regexp {^-(.*)$} $handle all handleval]} {
			lappend handlelist $handleval
			lappend paralist $para
		}
	}
	
	foreach item1 $handlelist item2 $paralist {
		set $item1\_value $item2
	}
	
	#2. set all of the parameters value
	if {[info exist alias_value]} {
		global [subst $alias_value]
		if {$dbgprt_value == 1} {puts "@@ alias: [subst $$alias_value]"}
	} else {
		uWriteExp -errorinfo "config_stream: alias is a mandatory parameter but missing"
	}
	
	foreach port [subst $$alias_value] {
		scan $port "%d %d %d" chasNum cardNum portNum
		stream get $chasNum $cardNum $portNum 1
	
		if {[info exist sendmode_value]} {
			switch $sendmode_value {
				contpkt {stream config -dma contPacket}
				contbst {stream config -dma contBurst}
				stopstrm {stream config -dma stopStream}
				default {return fail}
			}			
		}
		if {[info exist rate_value]} {
			stream config -percentPacketRate $rate_value
		}
		if {[info exist pktperbst_value]} {
			stream config -numFrames $pktperbst_value
		}
		if {[info exist bstperstrm_value]} {
			stream config -numBursts $bstperstrm_value
		}
		
		stream set $chasNum $cardNum $portNum 1
		stream write $chasNum $cardNum $portNum 1
	}
	set logStr "config_stream $args"
	#printlog -fileid $tcLogId -res conf -cmd $logStr
}


# -alias
# -uds1
# -uds1da
# -uds1sa
# -uds2
# -uds2da
# -uds2sa
# -uds3
# -uds3da
# -uds3sa
# -uds4
# -uds4da
# -uds4sa
# -da1addr
# -da1mask
# -da2addr
# -da2mask
# -sa1addr
# -sa1mask
# -sa2addr
# -sa2mask
# -statmode
# -qospkgtype
# config_filter -alias ixiap1 -uds3 enable -uds3sa sa1 -uds3da da1 -sa1addr "00 00 00 00 00 01" -da1addr "00 00 00 00 00 02"
proc config_filter {args} {
	global tcLogId
	#1.1. get command and handle/parameters
	set dbgprt_value 0
	
	foreach {handle para} $args {
		if {[regexp {^-(.*)$} $handle all handleval]} {
			lappend handlelist $handleval
			lappend paralist $para
		}
	}
	
	foreach item1 $handlelist item2 $paralist {
		set $item1\_value $item2
	}
	
	#1.2. set all of the parameters value
	if {[info exist alias_value]} {
		global [subst $alias_value]
		if {$dbgprt_value == 1} {puts "@@ alias: [subst $$alias_value]"}
	} else {
		uWriteExp -errorinfo "config_filter: alias is a mandatory parameter but missing"
	}
	
	global [subst $alias_value]
	foreach port [subst $$alias_value] {
		scan $port "%d %d %d" chasNum cardNum portNum
		filter get $chasNum $cardNum $portNum
		filterPallette get $chasNum $cardNum $portNum
		stat get allStats $chasNum $cardNum $portNum
		qos get $chasNum $cardNum $portNum
	
		#2. get and set uds1 value
		if {[info exist uds1_value]} {
			switch $uds1_value {
				enable {filter config -userDefinedStat1Enable true}
				disbale {filter config -userDefinedStat1Enable false}
				default {uWriteExp -errorinfo "proc: config_filter, args: $args, uds1 input error!"}
			}
		}
		#3. get and set uds1da value
		if {[info exist uds1da_value]} {
			switch $uds1da_value {
				any {filter config -userDefinedStat1DA anyAddr}
				da1 {filter config -userDefinedStat1DA addr1}
				notda1 {filter config -userDefinedStat1DA notAddr1}
				da2 {filter config -userDefinedStat1DA addr2}
				notda2 {filter config -userDefinedStat1DA notAddr2}
				default {uWriteExp -errorinfo "proc: config_filter, args: $args, uds1da input error!"}
			}
		}
		#4. get and set uds1sa value
		if {[info exist uds1sa_value]} {
			switch $uds1sa_value {
				any {filter config -userDefinedStat1SA anyAddr}
				sa1 {filter config -userDefinedStat1SA addr1}
				notsa1 {filter config -userDefinedStat1SA notAddr1}
				sa2 {filter config -userDefinedStat1SA addr2}
				notsa2 {filter config -userDefinedStat1SA notAddr2}
				default {uWriteExp -errorinfo "proc: config_filter, args: $args, uds1sa input error!"}
			}
		}
		#5. get and set uds2 value
		if {[info exist uds2_value]} {
			switch $uds2_value {
				enable {filter config -userDefinedStat2Enable true}
				disbale {filter config -userDefinedStat2Enable false}
				default {uWriteExp -errorinfo "proc: config_filter, args: $args, uds2 input error!"}
			}
		}
		#6. get and set uds2da value
		if {[info exist uds2da_value]} {
			switch $uds2da_value {
				any {filter config -userDefinedStat2DA anyAddr}
				da1 {filter config -userDefinedStat2DA addr1}
				notda1 {filter config -userDefinedStat2DA notAddr1}
				da2 {filter config -userDefinedStat2DA addr2}
				notda2 {filter config -userDefinedStat2DA notAddr2}
				default {uWriteExp -errorinfo "proc: config_filter, args: $args, uds2da input error!"}
			}
		}
		#7. get and set uds2sa value
		if {[info exist uds2sa_value]} {
			switch $uds2sa_value {
				any {filter config -userDefinedStat2SA anyAddr}
				sa1 {filter config -userDefinedStat2SA addr1}
				notsa1 {filter config -userDefinedStat2SA notAddr1}
				sa2 {filter config -userDefinedStat2SA addr2}
				notsa2 {filter config -userDefinedStat2SA notAddr2}
				default {uWriteExp -errorinfo "proc: config_filter, args: $args, uds2sa input error!"}
			}
		}
		#8. get and set uds3 value
		if {[info exist uds3_value]} {
			switch $uds3_value {
				enable {filter config -captureTriggerEnable true}
				disbale {filter config -captureTriggerEnable false}
				default {uWriteExp -errorinfo "proc: config_filter, args: $args, uds3 input error!"}
			}
		}
		#9. get and set uds3da value
		if {[info exist uds3da_value]} {
			switch $uds3da_value {
				any 	{filter config -captureTriggerDA anyAddr}
				da1		{filter config -captureTriggerDA addr1}
				notda1	{filter config -captureTriggerDA notAddr1}
				da2		{filter config -captureTriggerDA addr2}
				notda2	{filter config -captureTriggerDA notAddr2}
				default {uWriteExp -errorinfo "proc: config_filter, args: $args, uds3da input error!"}
			}
		}
		#10. get and set uds3sa value
		if {[info exist uds3sa_value]} {
			switch $uds3sa_value {
				any 	{filter config -captureTriggerSA anyAddr}
				sa1     {filter config -captureTriggerSA addr1}
				notsa1  {filter config -captureTriggerSA notAddr1}
				sa2     {filter config -captureTriggerSA addr2}
				notsa2  {filter config -captureTriggerSA notAddr2}
				default {uWriteExp -errorinfo "proc: config_filter, args: $args, uds3sa input error!"}
			}
		}
		#11. get and set uds4 value
		if {[info exist uds4_value]} {
			switch $uds4_value {
				enable {filter config -captureTriggerEnable true}
				disbale {filter config -captureTriggerEnable false}
				default {uWriteExp -errorinfo "proc: config_filter, args: $args, uds4 input error!"}
			}
		}
		#12. get and set uds4da value
		if {[info exist uds4da_value]} {
			switch $uds4da_value {
				any 	{filter config -captureFilterDA anyAddr}
				da1     {filter config -captureFilterDA addr1}
				notda1	{filter config -captureFilterDA notAddr1}
				da2		{filter config -captureFilterDA addr2}
				notda2	{filter config -captureFilterDA notAddr2}
				default {uWriteExp -errorinfo "proc: config_filter, args: $args, uds4da input error!"}
			}
		}
		#13. get and set uds4sa value
		if {[info exist uds4sa_value]} {
			switch $uds4sa_value {
				any 	{filter config -captureFilterSA anyAddr}
				sa1		{filter config -captureFilterSA addr1}
				notsa1	{filter config -captureFilterSA notAddr1}
				sa2		{filter config -captureFilterSA addr2}
				notsa2	{filter config -captureFilterSA notAddr2}
				default {uWriteExp -errorinfo "proc: config_filter, args: $args, uds4sa input error!"}
			}
		}
		#14. get and set da1addr value
		if {[info exist da1addr_value]} {
			filterPallette config -DA1 $da1addr_value
		}
		#15. get and set da1mask value
		if {[info exist da1mask_value]} {
			filterPallette config -DAMask1 $da1mask_value
		}
		#16. get and set da2addr value
		if {[info exist da2addr_value]} {
			filterPallette config -DA2 $da2addr_value
		}
		#17. get and set da2mask value
		if {[info exist da2mask_value]} {
			filterPallette config -DAMask2 $da2mask_value
		}
		#18. get and set sa1addr value
		if {[info exist sa1addr_value]} {
			filterPallette config -SA1 $sa1addr_value
		}
		#19. get and set sa1mask value
		if {[info exist sa1mask_value]} {
			filterPallette config -SAMask1 $sa1mask_value
		}
		#20. get and set sa2addr value
		if {[info exist sa2addr_value]} {
			filterPallette config -SA2 $sa2addr_value
		}
		#21. get and set sa2mask value
		if {[info exist sa2mask_value]} {
			filterPallette config -SAMask2 $sa2mask_value
		}
		#22. get and set statmode value
		if {[info exist statmode_value]} {
			switch $statmode_value {
				normal	{stat config -mode statNormal}
				qos		{stat config -mode statQos}
				default {uWriteExp -errorinfo "proc: config_filter, args: $args, statmode input error!"}
			}
		}
		#23. get and set qospkgtype value
		if {[info exist qospkgtype_value]} {
			switch $qospkgtype_value {
				ethernetii  {qos config -packetType ipEthernetII}
				802.3		{qos config -packetType ip8023Snap}
				vlan		{qos config -packetType vlan}
				default 	{uWriteExp -errorinfo "proc: config_filter, args: $args, qospkgtype input error!"}
			}
		}
		
		filter set $chasNum $cardNum $portNum
		filterPallette set $chasNum $cardNum $portNum
		stat set $chasNum $cardNum $portNum
		qos set $chasNum $cardNum $portNum
	}
	ixWriteConfigToHardware $alias_value
	
	set logStr "config_filter $args"
	#printlog -fileid $tcLogId -res conf -cmd $logStr
}


# -alias
# clear_stat -alias allport
# clear_stat -alias ixiap1
proc clear_stat {args} {
	global tcLogId
	set aftertime 1000
	#1. get command and handle/parameters
	set dbgprt_value 0
	
	foreach {handle para} $args {
		if {[regexp {^-(.*)$} $handle all handleval]} {
			lappend handlelist $handleval
			lappend paralist $para
		}
	}
	
	foreach item1 $handlelist item2 $paralist {
		set $item1\_value $item2
	}
	
	#2. set all of the parameters value
	if {[info exist alias_value]} {
		global [subst $alias_value]
		if {$dbgprt_value == 1} {puts "@@ alias: [subst $$alias_value]"}
	} else {
		uWriteExp -errorinfo "clear_stat: alias is a mandatory parameter but missing"
	}

	ixClearStats $alias_value
	after $aftertime
	set logStr "clear_stat $args"
	printlog -fileid $tcLogId -res conf -cmd $logStr
}

# -actiontype
# -time
# send_traffic -alias allport -actiontype start -time 5
proc send_traffic {args} {
	global tcLogId
	set aftertime 200
	#1. get command and handle/parameters
	set dbgprt_value 0
	
	foreach {handle para} $args {
		if {[regexp {^-(.*)$} $handle all handleval]} {
			lappend handlelist $handleval
			lappend paralist $para
		}
	}
	
	foreach item1 $handlelist item2 $paralist {
		set $item1\_value $item2
	}
	
	#2. set all of the parameters value
	if {[info exist alias_value]} {
		global [subst $alias_value]
		if {$dbgprt_value == 1} {puts "@@ alias: [subst $$alias_value]"}
	} else {
		uWriteExp -errorinfo "send_traffic: alias is a mandatory parameter but missing"
	}
	
	if {[info exist actiontype_value]} {
		#ixConnectToChassis $glipaddress
		switch $actiontype_value {
			start {ixStartTransmit $alias_value; after $aftertime}
			stop {ixStopTransmit $alias_value; after $aftertime}
			default {uWriteExp -errorinfo "input actiontype error"}
		}
	}	
	if {[info exist time_value]} {
		after [expr $time_value *1000]
		ixStopTransmit $alias_value
		after $aftertime
	}
	set logStr "send_traffic $args"
	printlog -fileid $tcLogId -res conf -cmd $logStr
}

# -alias
# -txframe
# -txbyte
# -rxframe
# -rxbyte
# -rxundersize
# -rxoversize
# -rxvlantagged
# -rxcrcerror
# -rxqos0
# -rxqos1
# -rxqos2
# -rxqos3
# -rxqos4
# -rxqos5
# -rxqos6
# -rxqos7
# -rxuds1
# -rxuds2
# -rxuds3
# -rxuds4
# get_stat -alias ixiap1 -txframe ixiap1tx -rxframe ixiap1rx
proc get_stat {args} {
	global tcLogId
	#1. get command and handle/parameters
	set dbgprt_value 0
	
	foreach {handle para} $args {
		if {[regexp {^-(.*)$} $handle all handleval]} {
			lappend handlelist $handleval
			lappend paralist $para
		}
	}
	
	foreach item1 $handlelist item2 $paralist {
		set $item1\_value $item2
	}
	
	#2. get all of the parameters value
	if {[info exist alias_value]} {
		global [subst $alias_value]
		if {$dbgprt_value == 1} {puts "@@ alias: [subst $$alias_value]"}
	} else {
		uWriteExp -errorinfo "get_framestat: alias is a mandatory parameter but missing"
	}
	
	foreach port [subst $$alias_value] {
		scan $port "%d %d %d" chasNum cardNum portNum
		stat get statAllStats $chasNum $cardNum $portNum
	}
	
	if {[info exist txframe_value]} {
		set framesend [stat cget -framesSent]
		eval [subst {uplevel 1 {set $txframe_value $framesend}}]
	}
	if {[info exist txbyte_value]} {
		set bytessend [stat cget -bytesSent]
		eval [subst {uplevel 1 {set $txbyte_value $bytessend}}]
	}
	if {[info exist rxframe_value]} {
		set framesreceived [stat cget -framesReceived]
		eval [subst {uplevel 1 {set $rxframe_value $framesreceived}}]
	}
	if {[info exist rxbyte_value]} {
		set bytesreceived [stat cget -bytesReceived]
		eval [subst {uplevel 1 {set $rxbyte_value $bytesreceived}}]
	}
	if {[info exist rxundersize_value]} {
		set undersize [stat cget -undersize]
		eval [subst {uplevel 1 {set $rxundersize_value $undersize}}]
	}
	if {[info exist rxoversize_value]} {
		set oversize [stat cget -oversize]
		eval [subst {uplevel 1 {set $rxoversize_value $oversize}}]		
	}	
	if {[info exist rxvlantagged_value]} {
		set vlantagged [stat cget -vlanTaggedFramesRx]
		eval [subst {uplevel 1 {set $rxvlantagged_value $vlantagged}}]				
	}
	if {[info exist rxcrcerror_value]} {
		set crcerrors [stat cget -codingErrorFramesReceived] 
		eval [subst {uplevel 1 {set $rxcrcerror_value $crcerrors}}]		
	}
	if {[info exist rxqos0_value]} {
		set qualityofservice0 [stat cget -qualityOfService0]
		eval [subst {uplevel 1 {set $rxqos0_value $qualityofservice0}}]				
	}
	if {[info exist rxqos1_value]} {
		set qualityofservice1 [stat cget -qualityOfService1]
		eval [subst {uplevel 1 {set $rxqos1_value $qualityofservice1}}]						
	}
	if {[info exist rxqos2_value]} {
		set qualityofservice2 [stat cget -qualityOfService2]
		eval [subst {uplevel 1 {set $rxqos2_value $qualityofservice2}}]								
	}
	if {[info exist rxqos3_value]} {
		set qualityofservice3 [stat cget -qualityOfService3]
		eval [subst {uplevel 1 {set $rxqos3_value $qualityofservice3}}]							
	}	
	if {[info exist rxqos4_value]} {
		set qualityofservice4 [stat cget -qualityOfService4]
		eval [subst {uplevel 1 {set $rxqos4_value $qualityofservice4}}]							
	}		
	if {[info exist rxqos5_value]} {
		set qualityofservice5 [stat cget -qualityOfService5]
		eval [subst {uplevel 1 {set $rxqos5_value $qualityofservice5}}]								
	}			
	if {[info exist rxqos6_value]} {
		set qualityofservice6 [stat cget -qualityOfService6]
		eval [subst {uplevel 1 {set $rxqos6_value $qualityofservice6}}]							
	}			
	if {[info exist rxqos7_value]} {
		set qualityofservice7 [stat cget -qualityOfService7]
		eval [subst {uplevel 1 {set $rxqos7_value $qualityofservice7}}]							
	}			
	if {[info exist rxqos8_value]} {
		set qualityofservice8 [stat cget -qualityOfService8]
		eval [subst {uplevel 1 {set $rxqos8_value $qualityofservice8}}]							
	}				
	if {[info exist rxuds1_value]} {
		set userdefinedstat1 [stat cget -userDefinedStat1]
		eval [subst {uplevel 1 {set $rxuds1_value $userdefinedstat1}}]
	}
	if {[info exist rxuds2_value]} {
		set userdefinedstat2 [stat cget -userDefinedStat2]
		eval [subst {uplevel 1 {set $rxuds2_value $userdefinedstat2}}]		
	}
	if {[info exist rxuds3_value]} {
		set trigger [stat cget -captureTrigger]
		eval [subst {uplevel 1 {set $rxuds3_value $trigger}}]		
	}
	if {[info exist rxuds4_value]} {
		set filter [stat cget -captureFilter]
		eval [subst {uplevel 1 {set $rxuds4_value $filter}}]		
	}
	set logStr "get_stat $args"
	printlog -fileid $tcLogId -res conf -cmd $logStr
}

# -alias
# -txframe
# -txbyte
# -rxframe
# -rxbyte
# -rxundersize
# -rxoversize
# -rxvlantagged
# -rxcrcerror
# -rxqos0
# -rxqos1
# -rxqos2
# -rxqos3
# -rxqos4
# -rxqos5
# -rxqos6
# -rxqos7
# -rxuds1
# -rxuds2
# -rxuds3
# -rxuds4
# -times
# get_ratestat -alias ixiap1 -txframe ixiap1tx -rxframe ixiap1rx -times 10
proc get_ratestat {args} {
	global tcLogId
	set aftertime 1000
	#1. get command and handle/parameters
	set dbgprt_value 0
	
	foreach {handle para} $args {
		if {[regexp {^-(.*)$} $handle all handleval]} {
			lappend handlelist $handleval
			lappend paralist $para
		}
	}
	
	foreach item1 $handlelist item2 $paralist {
		set $item1\_value $item2
	}
	
	#2. get all of the parameters value
	if {[info exist alias_value]} {
		global [subst $alias_value]
		if {$dbgprt_value == 1} {puts "@@ alias: [subst $$alias_value]"}
	} else {
		uWriteExp -errorinfo "get_framestat: alias is a mandatory parameter but missing"
	}
	
	after $aftertime
	foreach port [subst $$alias_value] {
		scan $port "%d %d %d" chasNum cardNum portNum
		stat getRate statAllStats $chasNum $cardNum $portNum
	}
	
	if {[info exist txframe_value]} {
		set framesend [stat cget -framesSent]
		eval [subst {uplevel 1 {set $txframe_value $framesend}}]
	}
	if {[info exist txbyte_value]} {
		set bytessend [stat cget -bytesSent]
		eval [subst {uplevel 1 {set $txbyte_value $bytessend}}]
	}
	if {[info exist rxframe_value]} {
		set framesreceived [stat cget -framesReceived]
		eval [subst {uplevel 1 {set $rxframe_value $framesreceived}}]
	}
	if {[info exist rxbyte_value]} {
		set bytesreceived [stat cget -bytesReceived]
		eval [subst {uplevel 1 {set $rxbyte_value $bytesreceived}}]
	}
	if {[info exist rxundersize_value]} {
		set undersize [stat cget -undersize]
		eval [subst {uplevel 1 {set $rxundersize_value $undersize}}]
	}
	if {[info exist rxoversize_value]} {
		set oversize [stat cget -oversize]
		eval [subst {uplevel 1 {set $rxoversize_value $oversize}}]		
	}	
	if {[info exist rxvlantagged_value]} {
		set vlantagged [stat cget -vlanTaggedFramesRx]
		eval [subst {uplevel 1 {set $rxvlantagged_value $vlantagged}}]				
	}
	if {[info exist rxcrcerror_value]} {
		set crcerrors [stat cget -codingErrorFramesReceived] 
		eval [subst {uplevel 1 {set $rxcrcerror_value $crcerrors}}]		
	}
	if {[info exist rxqos0_value]} {
		set qualityofservice0 [stat cget -qualityOfService0]
		eval [subst {uplevel 1 {set $rxqos0_value $qualityofservice0}}]				
	}
	if {[info exist rxqos1_value]} {
		set qualityofservice1 [stat cget -qualityOfService1]
		eval [subst {uplevel 1 {set $rxqos1_value $qualityofservice1}}]						
	}
	if {[info exist rxqos2_value]} {
		set qualityofservice2 [stat cget -qualityOfService2]
		eval [subst {uplevel 1 {set $rxqos2_value $qualityofservice2}}]								
	}
	if {[info exist rxqos3_value]} {
		set qualityofservice3 [stat cget -qualityOfService3]
		eval [subst {uplevel 1 {set $rxqos3_value $qualityofservice3}}]							
	}	
	if {[info exist rxqos4_value]} {
		set qualityofservice4 [stat cget -qualityOfService4]
		eval [subst {uplevel 1 {set $rxqos4_value $qualityofservice4}}]							
	}		
	if {[info exist rxqos5_value]} {
		set qualityofservice5 [stat cget -qualityOfService5]
		eval [subst {uplevel 1 {set $rxqos5_value $qualityofservice5}}]								
	}			
	if {[info exist rxqos6_value]} {
		set qualityofservice6 [stat cget -qualityOfService6]
		eval [subst {uplevel 1 {set $rxqos6_value $qualityofservice6}}]							
	}			
	if {[info exist rxqos7_value]} {
		set qualityofservice7 [stat cget -qualityOfService7]
		eval [subst {uplevel 1 {set $rxqos7_value $qualityofservice7}}]							
	}			
	if {[info exist rxqos8_value]} {
		set qualityofservice8 [stat cget -qualityOfService8]
		eval [subst {uplevel 1 {set $rxqos8_value $qualityofservice8}}]							
	}				
	if {[info exist rxuds1_value]} {
		set userdefinedstat1 [stat cget -userDefinedStat1]
		eval [subst {uplevel 1 {set $rxuds1_value $userdefinedstat1}}]
	}
	if {[info exist rxuds2_value]} {
		set userdefinedstat2 [stat cget -userDefinedStat2]
		eval [subst {uplevel 1 {set $rxuds2_value $userdefinedstat2}}]		
	}
	if {[info exist rxuds3_value]} {
		set trigger [stat cget -captureTrigger]
		eval [subst {uplevel 1 {set $rxuds3_value $trigger}}]		
	}
	if {[info exist rxuds4_value]} {
		set filter [stat cget -captureFilter]
		eval [subst {uplevel 1 {set $rxuds4_value $filter}}]		
	}
	set logStr "get_ratestat $args"
	printlog -fileid $tcLogId -res conf -cmd $logStr
}


# -para1 		number
# -para2 		number
# -condition 	[=|!=|>|<|>=|<=]	default =
#			 	[equal|notequal|more|less|moreequal|lessequal]
# -percentage 	20
# -number		100
# -log 			string
# check_result -para1 $ixiap1tx -para2 $ixiap2rx -condition = -log "ixiap1tx: $ixiap1tx equal ixiap2rx $ixiap2rx"
proc check_result {args} {
	global tcLogId
	#1. get command and handle/parameters
	set dbgprt_value 0
	
	foreach {handle para} $args {
		if {[regexp {^-(.*)$} $handle all handleval]} {
			lappend handlelist $handleval
			lappend paralist $para
		}
	}
	
	foreach item1 $handlelist item2 $paralist {
		set $item1\_value $item2
	}
	
	#2. get all of the parameters value
	if {[info exist para1_value]} {
		if {$dbgprt_value == 1} {puts "@@ para1: $para1_value"}
	} else {
		uWriteExp -errorinfo "check_result: para1 is a mandatory parameter but missing"
	}
	
	if {[info exist para2_value]} {
		if {$dbgprt_value == 1} {puts "@@ para2: $para2_value"}
	} else {
		uWriteExp -errorinfo "check_result: para2 is a mandatory parameter but missing"
	}
	
	if {![info exist condition_value]} {
		set condition_value =
	}
	if {$dbgprt_value == 1} {puts "@@ condition: $condition_value"}
	
	if {[info exist percentage_value]} {
		if {$dbgprt_value == 1} {puts "@@ percentage: $percentage_value"}
	}

	if {[info exist number_value]} {
		if {$dbgprt_value == 1} {puts "@@ number: $number_value"}
	}
	
	if {![info exist log_value]} {
		set log_value ""
	}
	
	# condition: =
	if {[regexp {^=$|^equal$} $condition_value]} {
		if {[expr $para1_value - $para2_value] == 0} {
			set res 1
		} else {
			set res 0
		}
	}
	# condition: !=	,abs(1-2)/2<=percentage and abs(1-2)<=number
	if {[regexp {^!=$|^notequal$} $condition_value]} {
		if {[expr $para1_value - $para2_value] == 0} {
			set res 0
		} elseif {[expr $para1_value - $para2_value] != 0} {
			if {[info exist percentage_value] | [info exist number_value]} {
				set res21 [expr abs([expr $para1_value - $para2_value]) * 1.00 / $para2_value]
				set res22 [expr abs([expr $para1_value - $para2_value]) * 1.00]
				if {[info exist percentage_value]} {
					if {$res21 <= [expr $percentage_value / 100.00]} {
						set res1 1
					} else {
						set res1 0
					}
				} else {
					set res1 1
				}
				if {[info exist number_value]} {
					if {$res22 <= $number_value} {
						set res2 1
					} else {
						set res2 0
					}
				} else {
					set res2 1
				}
				set res [expr $res1 && $res2]
			} else {
				set res 1
			}
		}
	}
	
	# condition: >	, 1-2<number and (1-2)/2<percentage
	if {[regexp {^>$|^more$} $condition_value]} {
		if {[expr $para1_value - $para2_value] <= 0} {
			set res 0
		} elseif {[expr $para1_value - $para2_value] > 0} {
			if {[info exist percentage_value] | [info exist number_value]} {
				set res31 [expr ($para1_value - $para2_value) * 1.00 / $para2_value]
				set res32 [expr $para1_value - $para2_value]
				if {[info exist percentage_value]} {
					if {$res31 < [expr $percentage_value / 100.00]} {
						set res1 1
					} else {
						set res1 0
					}
				} else {
					set res1 1
				}
				if {[info exist number_value]} {
					if {$res32 < $number_value} {
						set res2 1
					} else {
						set res2 0
					}
				} else {
					set res2 1
				}
				set res [expr $res1 && $res2]
			} else {
				set res 1
			}
		}
	}
	
	# condition: <	, 2-1<number and (2-1)/2<percentage
	if {[regexp {^<$|^less$} $condition_value]} {
		if {[expr $para2_value - $para1_value] <= 0} {
			set res 0
		} elseif {[expr $para2_value - $para1_value] > 0} {
			set res 1
			if {[info exist percentage_value] | [info exist number_value]} {
				set res41 [expr ($para2_value - $para1_value) * 1.00 / $para2_value]
				set res42 [expr $para2_value - $para1_value]
				if {[info exist percentage_value]} {
					if {$res41 < [expr $percentage_value / 100.00]} {
						set res1 1
					} else {
						set res1 0
					}
				} else {
					set res1 1
				}
				if {[info exist number_value]} {
					if {$res42 < $number_value} {
						set res2 1
					} else {
						set res2 0
					}
				} else {
					set res2 1
				}
				set res [expr $res1 && $res2]
			}
		}
	}
	
	
	# condition: >=	, 1-2<=number and (1-2)/2<=percentage
	if {[regexp {^>=$|^moreequal$} $condition_value]} {
		if {[expr $para1_value - $para2_value] < 0} {
			set res 0
		} elseif {[expr $para1_value - $para2_value] >= 0} {
			if {[info exist percentage_value] | [info exist number_value]} {
				set res51 [expr ($para1_value - $para2_value) * 1.00 / $para2_value]
				set res52 [expr $para1_value - $para2_value]
				if {[info exist percentage_value]} {
					if {$res51 <= [expr $percentage_value / 100.00]} {
						set res1 1
					} else {
						set res1 0
					}
				} else {
					set res1 1
				}
				if {[info exist number_value]} {
					if {$res52 <= $number_value} {
						set res2 1
					} else {
						set res2 0
					}
				} else {
					set res2 1
				}
				set res [expr $res1 && $res2]
			} else {
				set res 1
			}
		}
	}
	
	# condition: <=	, 2-1<=number and (2-1)/1<=percentage
	if {[regexp {^<=$|^lessequal$} $condition_value]} {
		if {[expr $para2_value - $para1_value] < 0} {
			set res 0
		} elseif {[expr $para2_value - $para1_value] >= 0} {
			set res 1
			if {[info exist percentage_value] | [info exist number_value]} {
				set res61 [expr ($para2_value - $para1_value) * 1.00 / $para2_value]
				set res62 [expr $para2_value - $para1_value]
				if {[info exist percentage_value]} {
					if {$res61 <= [expr $percentage_value / 100.00]} {
						set res1 1
					} else {
						set res1 0
					}
				} else {
					set res1 1
				}
				if {[info exist number_value]} {
					if {$res62 <= $number_value} {
						set res2 1
					} else {
						set res2 0
					}
				} else {
					set res2 1
				}
				set res [expr $res1 && $res2]
			}
		}
	}
	
	if {$res} {
		set result pass
	} else {
		set result fail
	}
	set logStr "check_result, $log_value"
	set commStr "$args"
	printlog -fileid $tcLogId -res $result -cmd $logStr -comment $commStr

}

# -alias
# start_capture -alias ixiap1
proc start_capture {args} {
	global tcLogId
	#1.1. get command and handle/parameters
	set dbgprt_value 0
	
	foreach {handle para} $args {
		if {[regexp {^-(.*)$} $handle all handleval]} {
			lappend handlelist $handleval
			lappend paralist $para
		}
	}
	
	foreach item1 $handlelist item2 $paralist {
		set $item1\_value $item2
	}
	
	#1.2. set all of the parameters value
	if {[info exist alias_value]} {
		global [subst $alias_value]
		if {$dbgprt_value == 1} {puts "@@ alias: [subst $$alias_value]"}
	} else {
		uWriteExp -errorinfo "config_filter: alias is a mandatory parameter but missing"
	}
	global [subst $alias_value]
	ixStartCapture $alias_value
	set logStr "start_capture $args"
	printlog -fileid $tcLogId -res conf -cmd $logStr
}

# -alias
# -length
# -srcmac
# -dstmac
# -tpid
# -framedata
# stop_capture -alias ixiap1 -length 64 -srcmac "00 00 00 00 00 02" -dstmac "00 00 00 00 00 01" -framedata frameData
proc stop_capture {args} {
	global tcLogId
	set aftertime 1000
	#1.1. get command and handle/parameters
	set dbgprt_value 0
	
	foreach {handle para} $args {
		if {[regexp {^-(.*)$} $handle all handleval]} {
			lappend handlelist $handleval
			lappend paralist $para
		}
	}
	set paraNum 0
	foreach item1 $handlelist item2 $paralist {
		set $item1\_value $item2
		if {[string first length $item1] >=0} {incr paraNum}
		if {[string first srcmac $item1] >=0} {incr paraNum}
		if {[string first dstmac $item1] >=0} {incr paraNum}
		if {[string first protocol $item1] >=0} {incr paraNum}
	}
	if {$dbgprt_value == 1} {puts "@@ paraNum: $paraNum"}
	#1.2. set all of the parameters value
	if {[info exist alias_value]} {
		global [subst $alias_value]
		if {$dbgprt_value == 1} {puts "@@ alias: [subst $$alias_value]"}
	} else {
		uWriteExp -errorinfo "stop_capture: alias is a mandatory parameter but missing"
	}
	
	global [subst $alias_value]
	ixStopCapture $alias_value
	after $aftertime
	
	foreach port [subst $$alias_value] {
		scan $port "%d %d %d" chasNum cardNum portNum
		capture get $chasNum $cardNum $portNum
		set numCaptured [capture cget -nPackets]
		if {$dbgprt_value == 1} {puts "@@ numCaptured: $numCaptured"}
		#captureBuffer get $chasNum $cardNum $portNum 1 $numCaptured
		captureBuffer get $chasNum $cardNum $portNum 1 100
	}
	
	set gotFrameData ""
	
	for {set i 1} {$i < $numCaptured} {incr i} {
		set j 0
		captureBuffer getframe $i
		set bufferdata [captureBuffer cget -frame]
		if {$dbgprt_value == 1 && $i <= 10} {puts "@@ bufferdata: $bufferdata"}
		if {[info exist length_value]} {
			captureBuffer getframe $i
			set sortframesize [captureBuffer cget -length]
			if {$dbgprt_value == 1 && $i <= 10} {puts "@@ framesize: $sortframesize"}
			if {"$sortframesize" == "$length_value"} {
				incr j
			}
		}
		if {[info exist dstmac_value]} {
			captureBuffer getframe $i
			set sortdamac [lrange $bufferdata 0 5]
			if {$dbgprt_value == 1 && $i <= 10} {puts "@@ damac: $sortdamac"}
			if {[string first "$sortdamac" "$dstmac_value"] >= 0} {
				incr j
			}
		}
		if {[info exist srcmac_value]} {
			captureBuffer getframe $i
			set sortsamac [lrange $bufferdata 6 11]
			if {$dbgprt_value == 1 && $i <= 10} {puts "@@ samac: $sortsamac"}
			if {[string first "$sortsamac" "$srcmac_value"] >= 0} {
				incr j
			}
		}
		
		if {[info exist tpid_value]} {
			captureBuffer getframe $i
			set sortethernettype [lrange $bufferdata 12 13]
			set numEthernetType [string replace $sortethernettype 2 2]
			if {$dbgprt_value == 1 && $i <= 10} {puts "@@ ethernettype: $sortethernettype"}
			if {"$numEthernetType" == "$tpid_value"} {
				incr j
			}
		}
		
		if {$j == $paraNum} {
			set gotFrameData $bufferdata
			break
		}
		if {$i == 100} {
			set gotFrameData $bufferdata
			set failStr 1
			printlog -fileid $tcLogId -res fail -cmd "stop_capture, can't get right captured frame within first 100 farmes"
			break
		}
	}
	
	if {[info exist framedata_value]} {
		eval [subst {uplevel 1 {set $framedata_value "$gotFrameData"}}]
	}
	
	set logStr "stop_capture $args"
	if {[string length $gotFrameData] < 1} {
		printlog -fileid $tcLogId -res fail -cmd $logStr -comment $gotFrameData
	} else {
		if {[info exist failStr]} {
			printlog -fileid $tcLogId -res fail -cmd $logStr -comment $gotFrameData
		} else {
			printlog -fileid $tcLogId -res pass -cmd $logStr -comment $gotFrameData
		}
	}
}

# -framedata
# -tpid
# -vlanid
# -priority
# -innertpid
# -innervlanid
# -innerpriority
# check_frame -framedata $frameData -tpid 8100 -vlanid 100 -priority 2
proc check_frame {args} {
	global tcLogId
	#1. get command and handle/parameters
	set dbgprt_value 0
	
	foreach {handle para} $args {
		if {[regexp {^-(.*)$} $handle all handleval]} {
			lappend handlelist $handleval
			lappend paralist $para
		}
	}
	
	set paraNum 0
	foreach item1 $handlelist item2 $paralist {
		set $item1\_value $item2
		if {[string first tpid $item1] >=0} {incr paraNum}
		if {[string first vlanid $item1] >=0} {incr paraNum}
		if {[string first priority $item1] >=0} {incr paraNum}
		if {[string first innertpid $item1] >=0} {incr paraNum}
		if {[string first innervlanid $item1] >=0} {incr paraNum}
		if {[string first innerpriority $item1] >=0} {incr paraNum}
	}
	
	set resNum 0
	
	#2. get the parameters value of frame data
	if {[info exist framedata_value]} {
		if {$dbgprt_value == 1} {puts "@@ framedata: $framedata_value"}
		if {[string length $framedata_value] < 1} {
			uWriteExp -errorinfo "check_frame: invalid framedata, framedata: $framedata_value"
		}
	} else {
		uWriteExp -errorinfo "check_frame: framedata is a mandatory parameter but missing"
	}
	
	set failedLogStr ""
	
	#3. check frame via tpid
	if {[info exist tpid_value]} {
		set gotTpid [lrange $framedata_value 12 13]
		set numGotTpid [string replace $gotTpid 2 2]
		
		if {$dbgprt_value == 1} {puts "@@ tpid: $numGotTpid"}
		if {[string equal -nocase $numGotTpid $tpid_value] == 1} {
			incr resNum
		} else {
			lappend failedLogStr "tpid: $numGotTpid,"
		}
	}
	
	#4. check frame via vlanid
	if {[info exist vlanid_value]} {
		set gotVlanid [lrange $framedata_value 14 15]
		set numGotVlanid [string range [string replace $gotVlanid 2 2] 1 3]
		set actualVlanid [format "%#u" 0x$numGotVlanid]
		if {$dbgprt_value == 1} {puts "@@ vlanid: $numGotVlanid"}
		if {$vlanid_value == $actualVlanid} {
			incr resNum
		} else {
			lappend failedLogStr "vlanid: $actualVlanid,"
		}
	}
	
	#5. check frame via priority
	if {[info exist priority_value]} {
		set gotPri [lrange $framedata_value 14 15]
		set numGotPri [string range [string replace $gotVlanid 2 2] 0 0]
		set actualPri [expr 0x$numGotPri / 2]
		if {$dbgprt_value == 1} {puts "@@ priority: $actualPri"}
		if {$priority_value == $actualPri} {
			incr resNum
		} else {
			lappend failedLogStr "priority: $actualPri"
		}
	}
	
	#6. check frame via innertpid
	if {[info exist innertpid_value]} {
		set gotTpid [lrange $framedata_value 16 17]
		set numGotTpid [string replace $gotTpid 2 2]
		if {$dbgprt_value == 1} {puts "@@ innertpid: $numGotTpid"}
		if {$numGotTpid == $innertpid_value} {
			incr resNum
		} else {
			lappend failedLogStr "innertpid: $numGotTpid,"
		}
	}
	
	#7. check frame via innervlanid
	if {[info exist innervlanid_value]} {
		set gotVlanid [lrange $framedata_value 18 19]
		set numGotVlanid [string range [string replace $gotVlanid 2 2] 1 3]
		set actualVlanid [format "%#u" 0x$numGotVlanid]
		if {$dbgprt_value == 1} {puts "@@ innervlanid: $actualVlanid"}
		if {$innervlanid_value == $actualVlanid} {
			incr resNum
		} else {
			lappend failedLogStr "innervlanid: $actualVlanid,"
		}
	}
	
	#8. check frame via innerpriority
	if {[info exist innerpriority_value]} {
		set gotPri [lrange $framedata_value 18 19]
		set numGotPri [string range [string replace $gotVlanid 2 2] 0 0]
		set actualPri [expr 0x$numGotPri / 2]
		if {$dbgprt_value == 1} {puts "@@ innerpriority: $actualPri"}
		if {$innerpriority_value == $actualPri} {
			incr resNum
		} else {
			lappend failedLogStr "innerpriority: $actualPri"
		}
	}
	
	if {$resNum == $paraNum} {
		set res pass
	} else {
		set res fail
	}

	set logStr "check_frame $args"
	printlog -fileid $tcLogId -res $res -cmd $logStr -comment $failedLogStr
	
	
}

# -alias
# clear_ownership -alias allport
proc clear_ownership {args} {
	global tcLogId
	set aftertime 2000
	#1.1. get command and handle/parameters
	set dbgprt_value 0
	
	foreach {handle para} $args {
		if {[regexp {^-(.*)$} $handle all handleval]} {
			lappend handlelist $handleval
			lappend paralist $para
		}
	}
	
	foreach item1 $handlelist item2 $paralist {
		set $item1\_value $item2
	}
	
	#1.2. set all of the parameters value
	if {[info exist alias_value]} {
		global [subst $alias_value]
		if {$dbgprt_value == 1} {puts "@@ alias: [subst $$alias_value]"}
	} else {
		uWriteExp -errorinfo "clear_ownership: alias is a mandatory parameter but missing"
	}
	
	global [subst $alias_value]
	ixClearOwnership [subst $$alias_value]
	set logStr "clear_ownership $args"
	printlog -fileid $tcLogId -res conf -cmd $logStr
	
}


