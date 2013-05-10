# Summary: this is a Rate Limit test suit for ION platform
# Topology: ixiap1 <-> sut1p1(copper) -- sut1p2(copper) <-> ixiap2
# DUT: x322x, x323x, x222x
# Owner: King Lan
# Date: 2011-9-7
# version: 1.0.1

# Login system
proc ratelimit_copper_0 {} {
	login -ipaddr $::sutIp -sutname sut1
	
	# connect ixia and config properties and frame
	connect_ixia -ipaddr $::ixiaIP -portlist $::ixiaP1,ixiap1,$::ixiaP2,ixiap2,$::ixiaP3,ixiap3,$::ixiaP4,ixiap4 -alias allport -loginname ratelimit
	config_portprop -alias ixiap1 -autonego enable -duplex 10h,10f,100h,100f,1000f -phymode copper
	config_portprop -alias ixiap2 -autonego enable -duplex 10h,10f,100h,100f,1000f -phymode copper
	config_portprop -alias ixiap3 -phymode fiber
	config_portprop -alias ixiap4 -phymode fiber
	config_frame -alias ixiap1 -srcmac "00 00 00 00 00 01" -dstmac "00 00 00 00 00 02" -framesize 64
	config_frame -alias ixiap2 -srcmac "00 00 00 00 00 02" -dstmac "00 00 00 00 00 01" -framesize 64 
	
}
# Rate Limit Copper-01-000 Unidirectional - Ingress setting at Copper Port 1000M
proc ratelimit_copper_1 {} {
	set baseRate 1000
	
	# config each port and check parameter value
	go s=$::sutSlot1 l1p=$::slot1P1
	sets ether adv-cap 10THD+10TFD+100THD+100TFD+1000THD+1000TFD
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
	go s=$::sutSlot1 l1p=$::slot1P2
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
	go s=$::sutSlot2 l1p=$::slot2P1
	sets ether adv-cap 10THD+10TFD+100THD+100TFD+1000THD+1000TFD
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
	go s=$::sutSlot2 l1p=$::slot2P2
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
	
	# send traffic from ixia port and check send and receive rate
	send_traffic -alias ixiap1 -actiontype start
	sleep 10
	get_ratestat -alias ixiap1 -txframe ixiaP1TxRate
	get_ratestat -alias ixiap2 -rxframe ixiaP2RxRate
	
	set expRate 1000
	set actTx [expr $ixiaP1TxRate / $baseRate * $expRate.000]
	set result [expr abs(($ixiaP2RxRate - $actTx) / $actTx) < $::diff]

	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP1TxRate: $ixiaP1TxRate, ixiaP2RxRate: $ixiaP2RxRate"
	
	go s=$::sutSlot1 l1p=$::slot1P1
	sets irate unLimited erate "rate900M"
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate "rate900M"
	
	get_ratestat -alias ixiap1 -txframe ixiaP1TxRate
	get_ratestat -alias ixiap2 -rxframe ixiaP2RxRate
	
	set expRate 1000
	set actTx [expr $ixiaP1TxRate / $baseRate * $expRate.000]
	set result [expr abs(($ixiaP2RxRate - $actTx) / $actTx) < $::diff]

	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP1TxRate: $ixiaP1TxRate, ixiaP2RxRate: $ixiaP2RxRate"
	
	# verify all all different rate limit result according parameters
	set length [llength $::irate]
	for {set a 0} {$a < $length} {incr a} {
	    set irate [lindex $::irate $a]
		regexp {rate(\d+)M} $irate match expRate
		sets irate $irate erate unLimited
		show bandwidth allocation -batype countAllLayer1 -irate $irate -erate unLimited
		sleep 10
		
		get_ratestat -alias ixiap1 -txframe ixiaP1TxRate
		get_ratestat -alias ixiap2 -rxframe ixiaP2RxRate
		
		set actTx [expr $ixiaP1TxRate / $baseRate * $expRate.000]
		set result [expr abs(($ixiaP2RxRate - $actTx) / $actTx) < $::diff]
		#puts "result: $result"
		if {$result} {      
			set res pass
		} else {
			set res fail
		}
		printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP1TxRate: $ixiaP1TxRate, ixiaP2RxRate: $ixiaP2RxRate"
		
	}
	
	# stop ixia
	send_traffic -alias ixiap1 -actiontype stop
	
	# set to factory default value of SUT
	go s=$::sutSlot1 l1p=$::slot1P1	
	sets irate unLimited erate unLimited
	go s=$::sutSlot2 l1p=$::slot2P1
	sets irate unLimited erate unLimited
}	
# Rate Limit Copper-02-000 Unidirectional - Egress setting at Copper Port 1000M
proc ratelimit_copper_2 {} {
	set baseRate 1000
	
	# config each port and check parameter value
	go s=$::sutSlot1 l1p=$::slot1P1
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited

	send_traffic -alias ixiap2 -actiontype start
	sleep 10
	get_ratestat -alias ixiap2 -txframe ixiaP2TxRate
	get_ratestat -alias ixiap1 -rxframe ixiaP1RxRate
	
	set expRate 1000
	set actTx [expr $ixiaP2TxRate / $baseRate * $expRate.000]
	set result [expr abs(($ixiaP1RxRate - $actTx) / $actTx) < $::diff]

	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP2TxRate: $ixiaP2TxRate, ixiaP1RxRate: $ixiaP1RxRate"
	
	go s=$::sutSlot1 l1p=$::slot1P1
	sets irate "rate900M" erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate "rate900M" -erate unLimited
	
	get_ratestat -alias ixiap2 -txframe ixiaP2TxRate
	get_ratestat -alias ixiap1 -rxframe ixiaP1RxRate
	
	set expRate 1000
	set actTx [expr $ixiaP2TxRate / $baseRate * $expRate.000]
	set result [expr abs(($ixiaP1RxRate - $actTx) / $actTx) < $::diff]
	
	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP2TxRate: $ixiaP2TxRate, ixiaP1RxRate: $ixiaP1RxRate"
	
	# verify all all different rate limit result according parameters
	set length [llength $::erate]
	for {set a 0} {$a < $length} {incr a} {
	    set erate [lindex $::erate $a]
		regexp {rate(\d+)M} $erate match expRate

		sets irate unLimited erate $erate
		show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate $erate
		sleep 10
		
		get_ratestat -alias ixiap2 -txframe ixiaP2TxRate
		get_ratestat -alias ixiap1 -rxframe ixiaP1RxRate
		
		set actTx [expr $ixiaP2TxRate * $expRate.000 / $baseRate]
		set result [expr abs(($ixiaP1RxRate - $actTx) / $actTx) < $::diff]

		if {$result} {      
			set res pass
		} else {
			set res fail
		}
		printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP2TxRate: $ixiaP2TxRate, ixiaP1RxRate: $ixiaP1RxRate"
		
	}
	
	# stop ixia
	send_traffic -alias ixiap2 -actiontype stop
	
	# set to factory default value of SUT
	go s=$::sutSlot1 l1p=$::slot1P1	
	sets irate unLimited erate unLimited
	go s=$::sutSlot2 l1p=$::slot2P1
	sets irate unLimited erate unLimited
}
# Rate Limit Copper-03-000 Unidirectional - Ingress setting at Copper Port 100M
proc ratelimit_copper_3 {} {
	set baseRate 100
	
	# config each port and check parameter value
	go s=$::sutSlot1 l1p=$::slot1P1
	sets ether adv-cap 10THD+10TFD+100THD+100TFD
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
	go s=$::sutSlot2 l1p=$::slot2P1
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
	
	# send traffic from ixia port and check send and receive rate
	send_traffic -alias ixiap1 -actiontype start
	sleep 10
	get_ratestat -alias ixiap1 -txframe ixiaP1TxRate
	get_ratestat -alias ixiap2 -rxframe ixiaP2RxRate
	
	set expRate 100
	set actTx [expr $ixiaP1TxRate / $baseRate * $expRate.000]
	set result [expr abs(($ixiaP2RxRate - $actTx) / $actTx) < $::diff]

	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP1TxRate: $ixiaP1TxRate, ixiaP2RxRate: $ixiaP2RxRate"
	
	go s=$::sutSlot1 l1p=$::slot1P1
	
	# verify all all different rate limit result according parameters
	set length [llength $::irate]
	for {set a 0} {$a < $length} {incr a} {
	    set irate [lindex $::irate $a]
		regexp {rate(\d+)M} $irate match expRate

		sets irate $irate erate unLimited
		show bandwidth allocation -batype countAllLayer1 -irate $irate -erate unLimited
		sleep 10
		
		get_ratestat -alias ixiap1 -txframe ixiaP1TxRate
		get_ratestat -alias ixiap2 -rxframe ixiaP2RxRate
		
		set actTx [expr $ixiaP1TxRate / $baseRate * $expRate.000]
		set result [expr abs(($ixiaP2RxRate - $actTx) / $actTx) < $::diff]

		if {$result} {      
			set res pass
		} else {
			set res fail
		}
		printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP1TxRate: $ixiaP1TxRate, ixiaP2RxRate: $ixiaP2RxRate"
		
	}
	
	# stop ixia
	send_traffic -alias ixiap1 -actiontype stop
	
	# set to factory default value of SUT
	go s=$::sutSlot1 l1p=$::slot1P1	
	sets irate unLimited erate unLimited
	go s=$::sutSlot2 l1p=$::slot2P1
	sets irate unLimited erate unLimited
}
# Rate Limit Copper-04-000 Unidirectional - Egress setting at Copper Port 100M
proc ratelimit_copper_4 {} {
	set baseRate 100
	
	# config each port and check parameter value
	go s=$::sutSlot2 l1p=$::slot2P1
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited

	config_portprop -alias ixiap2 -autonego enable -duplex 10h,10f,100h,100f -phymode copper
	send_traffic -alias ixiap2 -actiontype start
	sleep 10
	get_ratestat -alias ixiap2 -txframe ixiaP2TxRate
	get_ratestat -alias ixiap1 -rxframe ixiaP1RxRate
	
	set expRate 100
	set actTx [expr $ixiaP2TxRate / $baseRate * $expRate.000]
	set result [expr abs(($ixiaP1RxRate - $actTx) / $actTx) < $::diff]
	
	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP2TxRate: $ixiaP2TxRate, ixiaP1RxRate: $ixiaP1RxRate"
	
	go s=$::sutSlot1 l1p=$::slot1P1
	sets irate "rate90M" erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate "rate90M" -erate unLimited
	
	get_ratestat -alias ixiap2 -txframe ixiaP2TxRate
	get_ratestat -alias ixiap1 -rxframe ixiaP1RxRate
	
	set expRate 100
	set actTx [expr $ixiaP2TxRate / $baseRate * $expRate.000]
	set result [expr abs(($ixiaP1RxRate - $actTx) / $actTx) < $::diff]
	
	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP2TxRate: $ixiaP2TxRate, ixiaP1RxRate: $ixiaP1RxRate"
	
	# verify all all different rate limit result according parameters
	set length [llength $::erate]
	for {set a 0} {$a < $length} {incr a} {
	    set erate [lindex $::erate $a]
		regexp {rate(\d+)M} $erate match expRate

		sets irate unLimited erate $erate
		show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate $erate
		sleep 10
		
		get_ratestat -alias ixiap2 -txframe ixiaP2TxRate
		get_ratestat -alias ixiap1 -rxframe ixiaP1RxRate
		
		set actTx [expr $ixiaP2TxRate * $expRate.000 / $baseRate]
		set result [expr abs(($ixiaP1RxRate - $actTx) / $actTx) < $::diff]

		if {$result} {      
			set res pass
		} else {
			set res fail
		}
		printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP2TxRate: $ixiaP2TxRate, ixiaP1RxRate: $ixiaP1RxRate"
		
	}
	
	# stop ixia
	send_traffic -alias ixiap2 -actiontype stop
	
	# set to factory default value of SUT
	go s=$::sutSlot1 l1p=$::slot1P1	
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
	go s=$::sutSlot2 l1p=$::slot2P1	
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
}
# Rate Limit Copper-05-000 Unidirectional - Ingress setting at Copper Port 10M
proc ratelimit_copper_5 {} {
	set baseRate 10
	
	# config each port and check parameter value
	go s=$::sutSlot1 l1p=$::slot1P1
	sets ether adv-cap 10THD+10TFD
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
	go s=$::sutSlot2 l1p=$::slot2P1
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
	
	# send traffic from ixia port and check send and receive rate
	send_traffic -alias ixiap1 -actiontype start
	sleep 10
	get_ratestat -alias ixiap1 -txframe ixiaP1TxRate
	get_ratestat -alias ixiap2 -rxframe ixiaP2RxRate
	
	set expRate 10
	set actTx [expr $ixiaP1TxRate / $baseRate * $expRate.000]
	set result [expr abs(($ixiaP2RxRate - $actTx) / $actTx) < $::diff]
	
	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP1TxRate: $ixiaP1TxRate, ixiaP2RxRate: $ixiaP2RxRate"
	
	go s=$::sutSlot1 l1p=$::slot1P1
	
	# verify all all different rate limit result according parameters
	set length [llength $::irate]
	for {set a 0} {$a < $length} {incr a} {
	    set irate [lindex $::irate $a]
		regexp {rate(\d+)M} $irate match expRate

		sets irate $irate erate unLimited
		show bandwidth allocation -batype countAllLayer1 -irate $irate -erate unLimited
		sleep 10
		
		get_ratestat -alias ixiap1 -txframe ixiaP1TxRate
		get_ratestat -alias ixiap2 -rxframe ixiaP2RxRate
		
		set actTx [expr $ixiaP1TxRate / $baseRate * $expRate.000]
		set result [expr abs(($ixiaP2RxRate - $actTx) / $actTx) < $::diff]

		if {$result} {      
			set res pass
		} else {
			set res fail
		}
		printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP1TxRate: $ixiaP1TxRate, ixiaP2RxRate: $ixiaP2RxRate"
		
	}
	
	# stop ixia
	send_traffic -alias ixiap1 -actiontype stop
	
	# set to factory default value of SUT
	go s=$::sutSlot1 l1p=$::slot1P1	
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
	go s=$::sutSlot2 l1p=$::slot2P1
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
}
# Rate Limit Copper-06-000 Unidirectional - Egress setting at Copper Port 10M
proc ratelimit_copper_6 {} {
	set baseRate 10
	
	# config each port and check parameter value
	go s=$::sutSlot2 l1p=$::slot2P1
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited

	config_portprop -alias ixiap2 -autonego enable -duplex 10h,10f -phymode copper
	send_traffic -alias ixiap2 -actiontype start
	sleep 10
	get_ratestat -alias ixiap2 -txframe ixiaP2TxRate
	get_ratestat -alias ixiap1 -rxframe ixiaP1RxRate
	
	set expRate 10
	set actTx [expr $ixiaP2TxRate / $baseRate * $expRate.000]
	set result [expr abs(($ixiaP1RxRate - $actTx) / $actTx) < $::diff]
	
	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP2TxRate: $ixiaP2TxRate, ixiaP1RxRate: $ixiaP1RxRate"
	
	go s=$::sutSlot1 l1p=$::slot1P1
	sets irate "rate9M" erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate "rate9M" -erate unLimited
	
	get_ratestat -alias ixiap2 -txframe ixiaP2TxRate
	get_ratestat -alias ixiap1 -rxframe ixiaP1RxRate
	
	set expRate 10
	set actTx [expr $ixiaP2TxRate / $baseRate * $expRate.000]
	set result [expr abs(($ixiaP1RxRate - $actTx) / $actTx) < $::diff]
	
	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP2TxRate: $ixiaP2TxRate, ixiaP1RxRate: $ixiaP1RxRate"
	
	# verify all all different rate limit result according parameters
	set length [llength $::erate]
	for {set a 0} {$a < $length} {incr a} {
	    set erate [lindex $::erate $a]
		regexp {rate(\d+)M} $erate match expRate

		sets irate unLimited erate $erate
		show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate $erate
		sleep 10
		
		get_ratestat -alias ixiap2 -txframe ixiaP2TxRate
		get_ratestat -alias ixiap1 -rxframe ixiaP1RxRate
		
		set actTx [expr $ixiaP2TxRate * $expRate.000 / $baseRate]
		set result [expr abs(($ixiaP1RxRate - $actTx) / $actTx) < $::diff]

		if {$result} {      
			set res pass
		} else {
			set res fail
		}
		printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP2TxRate: $ixiaP2TxRate, ixiaP1RxRate: $ixiaP1RxRate"
		
	}
	
	# stop ixia
	send_traffic -alias ixiap2 -actiontype stop
	
	# set to factory default value of SUT
	go s=$::sutSlot1 l1p=$::slot1P1	
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
	go s=$::sutSlot2 l1p=$::slot2P1
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
}
# Rate Limit Copper-07-000 Unidirectional - Ingress & Egress setting at Copper Port 1000M
proc ratelimit_copper_7 {} {
	set baseRate 1000
	# config each port and check parameter value
	go s=$::sutSlot1 l1p=$::slot1P1
	sets ether adv-cap 10THD+10TFD+100THD+100TFD+1000THD+1000TFD
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
	go s=$::sutSlot2 l1p=$::slot2P1
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited

	config_portprop -alias ixiap1 -autonego enable -duplex 10h,10f,100h,100f,1000f -phymode copper
	config_portprop -alias ixiap2 -autonego enable -duplex 10h,10f,100h,100f,1000f -phymode copper
	
	# send traffic from ixia port and check send and receive rate
	send_traffic -alias ixiap1 -actiontype start
	sleep 10
	get_ratestat -alias ixiap1 -txframe ixiaP1TxRate
	get_ratestat -alias ixiap2 -rxframe ixiaP2RxRate
	
	set expRate 1000
	set actTx [expr $ixiaP1TxRate / $baseRate * $expRate.000]
	set result [expr abs(($ixiaP2RxRate - $actTx) / $actTx) < $::diff]

	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP1TxRate: $ixiaP1TxRate, ixiaP2RxRate: $ixiaP2RxRate"
	
	go s=$::sutSlot1 l1p=$::slot1P1
	sets irate "rate100M" erate "rate100M"
	show bandwidth allocation -batype countAllLayer1 -irate "rate100M" -erate "rate100M"
	
	get_ratestat -alias ixiap1 -txframe ixiaP1TxRate
	get_ratestat -alias ixiap2 -rxframe ixiaP2RxRate
	
	set expRate 100
	set actTx [expr $ixiaP1TxRate / $baseRate * $expRate.000]
	set result [expr abs(($ixiaP2RxRate - $actTx) / $actTx) < $::diff]

	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP1TxRate: $ixiaP1TxRate, ixiaP2RxRate: $ixiaP2RxRate"
	
	# stop ixia
	send_traffic -alias ixiap1 -actiontype stop
	# set to factory default value of SUT
	go s=$::sutSlot1 l1p=$::slot1P1	
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
	go s=$::sutSlot2 l1p=$::slot2P1
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
	
	send_traffic -alias ixiap2 -actiontype start
	sleep 10
	get_ratestat -alias ixiap2 -txframe ixiaP2TxRate
	get_ratestat -alias ixiap1 -rxframe ixiaP1RxRate
	
	set expRate 1000
	set actTx [expr $ixiaP2TxRate / $baseRate * $expRate.000]
	set result [expr abs(($ixiaP1RxRate - $actTx) / $actTx) < $::diff]
	
	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP2TxRate: $ixiaP2TxRate, ixiaP1RxRate: $ixiaP1RxRate"
	
	go s=$::sutSlot1 l1p=$::slot1P1
	sets irate "rate100M" erate "rate100M"
	show bandwidth allocation -batype countAllLayer1 -irate "rate100M" -erate "rate100M"
	
	get_ratestat -alias ixiap2 -txframe ixiaP2TxRate
	get_ratestat -alias ixiap1 -rxframe ixiaP1RxRate
	
	set expRate 100
	set actTx [expr $ixiaP2TxRate / $baseRate * $expRate.000]
	set result [expr abs(($ixiaP1RxRate - $actTx) / $actTx) < $::diff]

	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP2TxRate: $ixiaP2TxRate, ixiaP1RxRate: $ixiaP1RxRate"
	
	# stop ixia
	send_traffic -alias ixiap2 -actiontype stop
	
	# set to factory default value of SUT
	go s=$::sutSlot1 l1p=$::slot1P1	
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
	go s=$::sutSlot2 l1p=$::slot2P1
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
}
# Rate Limit Copper-08-000 Bidirectional - Ingress & Egress setting at Port 1 and Egress setting at Port 2	
proc ratelimit_copper_8 {} {
	# config each port and check parameter value
	go s=$::sutSlot1 l1p=$::slot1P1
	sets ether adv-cap 10THD+10TFD+100THD+100TFD+1000THD+1000TFD
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
	go s=$::sutSlot2 l1p=$::slot2P1
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
	
	# send traffic from ixia port and check send and receive rate
	send_traffic -alias ixiap1 -actiontype start
	sleep 10
	get_ratestat -alias ixiap1 -txframe ixiaP1TxRate
	get_ratestat -alias ixiap2 -rxframe ixiaP2RxRate
	
	set result [expr $ixiaP2RxRate > [expr $ixiaP1TxRate * [expr 1 - $::diff]] && \
				$ixiaP2RxRate < [expr $ixiaP1TxRate * [expr 1 + $::diff]]]
	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP1TxRate: $ixiaP1TxRate, ixiaP2RxRate: $ixiaP2RxRate"
	
	send_traffic -alias ixiap2 -actiontype start
	sleep 10
	get_ratestat -alias ixiap2 -txframe ixiaP2TxRate
	get_ratestat -alias ixiap1 -rxframe ixiaP1RxRate
	
	set result [expr $ixiaP1RxRate > [expr $ixiaP2TxRate * [expr 1 - $::diff]] && \
				$ixiaP1RxRate < [expr $ixiaP2TxRate * [expr 1 + $::diff]]]
	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP2TxRate: $ixiaP2TxRate, ixiaP1RxRate: $ixiaP1RxRate"
	
	go s=$::sutSlot1 l1p=$::slot1P1
	sets irate "rate100M" erate "rate100M"
	show bandwidth allocation -batype countAllLayer1 -irate "rate100M" -erate "rate100M"
	
	set result [expr $ixiaP2RxRate > [expr $ixiaP1TxRate * [expr 1 - $::diff]] && \
				$ixiaP2RxRate < [expr $ixiaP1TxRate * [expr 1 + $::diff]]]
	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP1TxRate: $ixiaP1TxRate, ixiaP2RxRate: $ixiaP2RxRate"
	
	go s=$::sutSlot2 l1p=$::slot2P1
	sets irate unLimited erate "rate100M"
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate "rate100M"
	
	set result [expr $ixiaP2RxRate > [expr $ixiaP1TxRate * [expr 1 - $::diff]] && \
				$ixiaP2RxRate < [expr $ixiaP1TxRate * [expr 1 + $::diff]]]
	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP1TxRate: $ixiaP1TxRate, ixiaP2RxRate: $ixiaP2RxRate"
	
	# stop ixia
	send_traffic -alias ixiap2 -actiontype stop
	
	go s=$::sutSlot1 l1p=$::slot1P1
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
	
	# stop ixia
	send_traffic -alias ixiap1 -actiontype stop
	go s=$::sutSlot2 l1p=$::slot2P1
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
}
# Rate Limit Copper-09-000 Bidirectional - Ingress & Egress setting at Port 1 and Ingress & Egress setting at Port 2	
proc ratelimit_copper_9 {} {
	# config each port and check parameter value
	go s=$::sutSlot1 l1p=$::slot1P1
	sets ether adv-cap 10THD+10TFD+100THD+100TFD+1000THD+1000TFD
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
	go s=$::sutSlot2 l1p=$::slot2P1
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
	
	# send traffic from ixia port and check send and receive rate
	send_traffic -alias ixiap1 -actiontype start
	sleep 10
	get_ratestat -alias ixiap1 -txframe ixiaP1TxRate
	get_ratestat -alias ixiap2 -rxframe ixiaP2RxRate
	
	set result [expr $ixiaP2RxRate > [expr $ixiaP1TxRate * [expr 1 - $::diff]] && \
				$ixiaP2RxRate < [expr $ixiaP1TxRate * [expr 1 + $::diff]]]
	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP1TxRate: $ixiaP1TxRate, ixiaP2RxRate: $ixiaP2RxRate"
	
	send_traffic -alias ixiap2 -actiontype start
	sleep 10
	get_ratestat -alias ixiap2 -txframe ixiaP2TxRate
	get_ratestat -alias ixiap1 -rxframe ixiaP1RxRate
	
	set result [expr $ixiaP1RxRate > [expr $ixiaP2TxRate * [expr 1 - $::diff]] && \
				$ixiaP1RxRate < [expr $ixiaP2TxRate * [expr 1 + $::diff]]]
	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP2TxRate: $ixiaP2TxRate, ixiaP1RxRate: $ixiaP1RxRate"
	
	go s=$::sutSlot1 l1p=$::slot1P1
	sets irate "rate100M" erate "rate100M"
	show bandwidth allocation -batype countAllLayer1 -irate "rate100M" -erate "rate100M"
	
	set result [expr $ixiaP2RxRate > [expr $ixiaP1TxRate * [expr 1 - $::diff]] && \
				$ixiaP2RxRate < [expr $ixiaP1TxRate * [expr 1 + $::diff]]]
	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP1TxRate: $ixiaP1TxRate, ixiaP2RxRate: $ixiaP2RxRate"
	
	go s=$::sutSlot2 l1p=$::slot2P1
	sets irate "rate100M" erate "rate100M"
	show bandwidth allocation -batype countAllLayer1 -irate "rate100M" -erate "rate100M"
	
	set result [expr $ixiaP2RxRate > [expr $ixiaP1TxRate * [expr 1 - $::diff]] && \
				$ixiaP2RxRate < [expr $ixiaP1TxRate * [expr 1 + $::diff]]]
	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP1TxRate: $ixiaP1TxRate, ixiaP2RxRate: $ixiaP2RxRate"
	
	# stop ixia
	send_traffic -alias ixiap2 -actiontype stop
	
	go s=$::sutSlot1 l1p=$::slot1P1
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
	
	# stop ixia
	send_traffic -alias ixiap1 -actiontype stop
	go s=$::sutSlot2 l1p=$::slot2P1
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
}
# Rate Limit Copper-10-000 Ingress & Egress setting status at Copper Port when port speed changed
proc ratelimit_copper_10 {} {
	# config each port and check parameter value
	go s=$::sutSlot1 l1p=$::slot1P1
	sets ether adv-cap 10THD+10TFD+100THD+100TFD+1000THD+1000TFD
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited

	sets irate unLimited erate "rate900M"
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate "rate900M"
	
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
	
}
# Rate Limit Copper-11-000 1518 Bytes Frame and Jumbo Frame rate limit behavior
proc ratelimit_copper_11 {} {
	set baseRate 1000
	# config each port and check parameter value
	go s=$::sutSlot1 l1p=$::slot1P1
	sets ether adv-cap 10THD+10TFD+100THD+100TFD+1000THD+1000TFD
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
	
	config_frame -alias ixiap1 -framesize 1518
	# send traffic from ixia port and check send and receive rate
	send_traffic -alias ixiap1 -actiontype start
	sleep 10
	get_ratestat -alias ixiap1 -txframe ixiaP1TxRate
	get_ratestat -alias ixiap2 -rxframe ixiaP2RxRate

	set expRate 1000
	set actTx [expr $ixiaP1TxRate / $baseRate * $expRate.000]
	set result [expr abs(($ixiaP2RxRate - $actTx) / $actTx) < $::diff]
	
	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP1TxRate: $ixiaP1TxRate, ixiaP2RxRate: $ixiaP2RxRate"
	
	sets irate "rate100M" erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate "rate100M" -erate unLimited
	get_ratestat -alias ixiap1 -txframe ixiaP1TxRate
	get_ratestat -alias ixiap2 -rxframe ixiaP2RxRate
	
	set expRate 100
	set actTx [expr $ixiaP1TxRate / $baseRate * $expRate.000]
	set result [expr abs(($ixiaP2RxRate - $actTx) / $actTx) < $::diff]

	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP1TxRate: $ixiaP1TxRate, ixiaP2RxRate: $ixiaP2RxRate"
	
	# stop ixia
	send_traffic -alias ixiap1 -actiontype stop
	
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
	
	config_frame -alias ixiap1 -framesize 10240
	# send traffic from ixia port and check send and receive rate
	send_traffic -alias ixiap1 -actiontype start
	sleep 10
	get_ratestat -alias ixiap1 -txframe ixiaP1TxRate
	get_ratestat -alias ixiap2 -rxoversize ixiaP2RxRate
	
	set expRate 1000
	set actTx [expr $ixiaP1TxRate / $baseRate * $expRate.000]
	set result [expr abs(($ixiaP2RxRate - $actTx) / $actTx) < $::diff]
	
	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP1TxRate: $ixiaP1TxRate, ixiaP2RxRate: $ixiaP2RxRate"
	
	sets irate "rate100M" erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate "rate100M" -erate unLimited
	get_ratestat -alias ixiap1 -txframe ixiaP1TxRate
	get_ratestat -alias ixiap2 -rxoversize ixiaP2RxRate
	
	set expRate 100
	set actTx [expr $ixiaP1TxRate / $baseRate * $expRate.000]
	set result [expr abs(($ixiaP2RxRate - $actTx) / $actTx) < $::diff]
	
	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP1TxRate: $ixiaP1TxRate, ixiaP2RxRate: $ixiaP2RxRate"
	
	# stop ixia
	send_traffic -alias ixiap1 -actiontype stop
	
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
	
	config_frame -alias ixiap2 -framesize 1518
	# send traffic from ixia port and check send and receive rate
	send_traffic -alias ixiap2 -actiontype start
	sleep 10
	get_ratestat -alias ixiap2 -txframe ixiaP2TxRate
	get_ratestat -alias ixiap1 -rxframe ixiaP1RxRate
	
	set expRate 1000
	set actTx [expr $ixiaP2TxRate / $baseRate * $expRate.000]
	set result [expr abs(($ixiaP1RxRate - $actTx) / $actTx) < $::diff]
	
	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP2TxRate: $ixiaP2TxRate, ixiaP1RxRate: $ixiaP1RxRate"
	
	sets irate unLimited erate "rate100M"
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate "rate100M"
	get_ratestat -alias ixiap2 -txframe ixiaP2TxRate
	get_ratestat -alias ixiap1 -rxframe ixiaP1RxRate
	
	set expRate 100
	set actTx [expr $ixiaP2TxRate / $baseRate * $expRate.000]
	set result [expr abs(($ixiaP1RxRate - $actTx) / $actTx) < $::diff]
	
	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP2TxRate: $ixiaP2TxRate, ixiaP1RxRate: $ixiaP1RxRate"
	
	# stop ixia
	send_traffic -alias ixiap2 -actiontype stop
	
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
	
	config_frame -alias ixiap2 -framesize 10240
	send_traffic -alias ixiap2 -actiontype start
	sleep 10
	get_ratestat -alias ixiap2 -txframe ixiaP2TxRate
	get_ratestat -alias ixiap1 -rxoversize ixiaP1RxRate
	
	set expRate 1000
	set actTx [expr $ixiaP2TxRate / $baseRate * $expRate.000]
	set result [expr abs(($ixiaP1RxRate - $actTx) / $actTx) < $::diff]

	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP2TxRate: $ixiaP2TxRate, ixiaP1RxRate: $ixiaP1RxRate"
	
	sets irate unLimited erate "rate100M"
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate "rate100M"
	get_ratestat -alias ixiap2 -txframe ixiaP2TxRate
	get_ratestat -alias ixiap1 -rxoversize ixiaP1RxRate

	set expRate 100
	set actTx [expr $ixiaP2TxRate / $baseRate * $expRate.000]
	set result [expr abs(($ixiaP1RxRate - $actTx) / $actTx) < $::diff]

	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP2TxRate: $ixiaP2TxRate, ixiaP1RxRate: $ixiaP1RxRate"
	
	#stop ixia
	send_traffic -alias ixiap2 -actiontype stop
	
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
}

#***********************************************************************************************************************************************************************
#Rate Limit Fiber-01-000 Unidirectional - Ingress setting at Fiber Port 1000M
proc ratelimit_fiber_21 {} {
	set baseRate 1000
	
	# config each port and check parameter value
	go s=$::sutSlot1 l1p=$::slot1P2
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
	go s=$::sutSlot2 l1p=$::slot2P2
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
	
	config_frame -alias allport -framesize 64
	
	# send traffic from ixia port and check send and receive rate
	send_traffic -alias ixiap2 -actiontype start
	sleep 10
	get_ratestat -alias ixiap2 -txframe ixiaP2TxRate
	get_ratestat -alias ixiap1 -rxframe ixiaP1RxRate
	
	set expRate 1000
	set actTx [expr $ixiaP2TxRate / $baseRate * $expRate.000]
	set result [expr abs(($ixiaP1RxRate - $actTx) / $actTx) < $::diff]

	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP2TxRate: $ixiaP2TxRate, ixiaP1RxRate: $ixiaP1RxRate"
	
	go s=$::sutSlot1 l1p=$::slot1P2
	sets irate unLimited erate "rate900M"
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate "rate900M"
	
	get_ratestat -alias ixiap2 -txframe ixiaP2TxRate
	get_ratestat -alias ixiap1 -rxframe ixiaP1RxRate
	
	set expRate 1000
	set actTx [expr $ixiaP2TxRate / $baseRate * $expRate.000]
	set result [expr abs(($ixiaP1RxRate - $actTx) / $actTx) < $::diff]

	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP2TxRate: $ixiaP2TxRate, ixiaP1RxRate: $ixiaP1RxRate"
	
	# verify all all different rate limit result according parameters
	set length [llength $::irate]
	for {set a 0} {$a < $length} {incr a} {
	    set irate [lindex $::irate $a]
		regexp {rate(\d+)M} $irate match expRate
		sets irate $irate erate unLimited
		show bandwidth allocation -batype countAllLayer1 -irate $irate -erate unLimited
		sleep 10
		
		get_ratestat -alias ixiap2 -txframe ixiaP2TxRate
		get_ratestat -alias ixiap1 -rxframe ixiaP1RxRate
		
		set actTx [expr $ixiaP2TxRate / $baseRate * $expRate.000]
		set result [expr abs(($ixiaP1RxRate - $actTx) / $actTx) < $::diff]
		#puts "result: $result"
		if {$result} {      
			set res pass
		} else {
			set res fail
		}
		printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP2TxRate: $ixiaP2TxRate, ixiaP1RxRate: $ixiaP1RxRate"
		
	}
	
	# stop ixia
	send_traffic -alias ixiap2 -actiontype stop
	
	# set to factory default value of SUT
	go s=$::sutSlot1 l1p=$::slot1P2
	sets irate unLimited erate unLimited
	go s=$::sutSlot2 l1p=$::slot2P2
	sets irate unLimited erate unLimited
}
# Rate Limit Fiber-02-000 Unidirectional - Egress setting at Fiber Port 1000M
proc ratelimit_fiber_22 {} {
	set baseRate 1000
	
	# config each port and check parameter value
	go s=$::sutSlot2 l1p=$::slot2P2
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited

	send_traffic -alias ixiap2 -actiontype start
	sleep 10
	get_ratestat -alias ixiap2 -txframe ixiaP2TxRate
	get_ratestat -alias ixiap1 -rxframe ixiaP1RxRate
	
	set expRate 1000
	set actTx [expr $ixiaP2TxRate / $baseRate * $expRate.000]
	set result [expr abs(($ixiaP1RxRate - $actTx) / $actTx) < $::diff]

	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP2TxRate: $ixiaP2TxRate, ixiaP1RxRate: $ixiaP1RxRate"
	
	go s=$::sutSlot2 l1p=$::slot2P2
	sets irate "rate900M" erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate "rate900M" -erate unLimited
	
	get_ratestat -alias ixiap2 -txframe ixiaP2TxRate
	get_ratestat -alias ixiap1 -rxframe ixiaP1RxRate
	
	set expRate 1000
	set actTx [expr $ixiaP2TxRate / $baseRate * $expRate.000]
	set result [expr abs(($ixiaP1RxRate - $actTx) / $actTx) < $::diff]
	
	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP2TxRate: $ixiaP2TxRate, ixiaP1RxRate: $ixiaP1RxRate"
	
	# verify all all different rate limit result according parameters
	set length [llength $::erate]
	for {set a 0} {$a < $length} {incr a} {
	    set erate [lindex $::erate $a]
		regexp {rate(\d+)M} $erate match expRate

		sets irate unLimited erate $erate
		show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate $erate
		sleep 10
		
		get_ratestat -alias ixiap2 -txframe ixiaP2TxRate
		get_ratestat -alias ixiap1 -rxframe ixiaP1RxRate
		
		set actTx [expr $ixiaP2TxRate * $expRate.000 / $baseRate]
		set result [expr abs(($ixiaP1RxRate - $actTx) / $actTx) < $::diff]

		if {$result} {      
			set res pass
		} else {
			set res fail
		}
		printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP2TxRate: $ixiaP2TxRate, ixiaP1RxRate: $ixiaP1RxRate"
		
	}
	
	# stop ixia
	send_traffic -alias ixiap2 -actiontype stop
	
	# set to factory default value of SUT
	go s=$::sutSlot1 l1p=$::slot1P2	
	sets irate unLimited erate unLimited
	go s=$::sutSlot2 l1p=$::slot2P2	
	sets irate unLimited erate unLimited
}
# Rate Limit Fiber-03-000 Unidirectional - Ingress setting at Fiber Port 100M
proc ratelimit_fiber_23 {} {
	set baseRate 100
	
	# config each port and check parameter value
	go s=$::sutSlot3 l1p=$::slot3P2
	sets ether phymode phy100BaseFX
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
	go s=$::sutSlot3 l1p=$::slot3P3
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
	
	config_frame -alias allport -framesize 64
	# send traffic from ixia port and check send and receive rate
	send_traffic -alias ixiap3 -actiontype start
	sleep 10
	get_ratestat -alias ixiap3 -txframe ixiaP1TxRate
	get_ratestat -alias ixiap4 -rxframe ixiaP2RxRate
	
	set expRate 100
	set actTx [expr $ixiaP1TxRate / $baseRate * $expRate.000]
	set result [expr abs(($ixiaP2RxRate - $actTx) / $actTx) < $::diff]

	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP1TxRate: $ixiaP1TxRate, ixiaP2RxRate: $ixiaP2RxRate"
	
	go s=$::sutSlot3 l1p=$::slot3P2
	
	# verify all all different rate limit result according parameters
	set length [llength $::irate]
	for {set a 0} {$a < $length} {incr a} {
	    set irate [lindex $::irate $a]
		regexp {rate(\d+)M} $irate match expRate

		sets irate $irate erate unLimited
		show bandwidth allocation -batype countAllLayer1 -irate $irate -erate unLimited
		sleep 10
		
		get_ratestat -alias ixiap3 -txframe ixiaP1TxRate
		get_ratestat -alias ixiap4 -rxframe ixiaP2RxRate
		
		set actTx [expr $ixiaP1TxRate / $baseRate * $expRate.000]
		set result [expr abs(($ixiaP2RxRate - $actTx) / $actTx) < $::diff]

		if {$result} {      
			set res pass
		} else {
			set res fail
		}
		printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP1TxRate: $ixiaP1TxRate, ixiaP2RxRate: $ixiaP2RxRate"
		
	}
	
	# stop ixia
	send_traffic -alias ixiap3 -actiontype stop
	
	# set to factory default value of SUT
	go s=$::sutSlot3 l1p=$::slot3P2	
	sets irate unLimited erate unLimited
	go s=$::sutSlot3 l1p=$::slot3P3
	sets irate unLimited erate unLimited
}
# Rate Limit Fiber-04-000 Unidirectional - Egress setting at Fiber Port 100M
proc ratelimit_fiber_24 {} {
	set baseRate 100
	
	# config each port and check parameter value
	go s=$::sutSlot3 l1p=$::slot3P3
	sets irate unLimited erate unLimited
	sets ether phymode phy100BaseFX
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited

	send_traffic -alias ixiap4 -actiontype start
	sleep 10
	get_ratestat -alias ixiap4 -txframe ixiaP2TxRate
	get_ratestat -alias ixiap3 -rxframe ixiaP1RxRate
	
	set expRate 100
	set actTx [expr $ixiaP2TxRate / $baseRate * $expRate.000]
	set result [expr abs(($ixiaP1RxRate - $actTx) / $actTx) < $::diff]
	
	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP2TxRate: $ixiaP2TxRate, ixiaP1RxRate: $ixiaP1RxRate"
	
	go s=$::sutSlot3 l1p=$::slot3P2
	sets irate "rate90M" erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate "rate90M" -erate unLimited
	
	get_ratestat -alias ixiap4 -txframe ixiaP2TxRate
	get_ratestat -alias ixiap3 -rxframe ixiaP1RxRate
	
	set expRate 100
	set actTx [expr $ixiaP2TxRate / $baseRate * $expRate.000]
	set result [expr abs(($ixiaP1RxRate - $actTx) / $actTx) < $::diff]
	
	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP2TxRate: $ixiaP2TxRate, ixiaP1RxRate: $ixiaP1RxRate"
	
	# verify all all different rate limit result according parameters
	set length [llength $::erate]
	for {set a 0} {$a < $length} {incr a} {
	    set erate [lindex $::erate $a]
		regexp {rate(\d+)M} $erate match expRate

		sets irate unLimited erate $erate
		show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate $erate
		sleep 10
		
		get_ratestat -alias ixiap4 -txframe ixiaP2TxRate
		get_ratestat -alias ixiap3 -rxframe ixiaP1RxRate
		
		set actTx [expr $ixiaP2TxRate * $expRate.000 / $baseRate]
		set result [expr abs(($ixiaP1RxRate - $actTx) / $actTx) < $::diff]

		if {$result} {      
			set res pass
		} else {
			set res fail
		}
		printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP2TxRate: $ixiaP2TxRate, ixiaP1RxRate: $ixiaP1RxRate"
		
	}
	
	# stop ixia
	send_traffic -alias ixiap4 -actiontype stop
	
	# set to factory default value of SUT
	go s=$::sutSlot3 l1p=$::slot3P2	
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
}
# Rate Limit Fiber-05-000 Unidirectional - Ingress & Egress setting at Fiber Port 1000M
proc ratelimit_fiber_25 {} {
	set baseRate 1000
	# config each port and check parameter value
	go s=$::sutSlot1 l1p=$::slot1P2
	sets ether phymode phy1000BaseX
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
	go s=$::sutSlot2 l1p=$::slot2P2
	sets irate unLimited erate unLimited
	sets ether phymode phy1000BaseX
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
	
	# send traffic from ixia port and check send and receive rate
	send_traffic -alias ixiap1 -actiontype start
	sleep 10
	get_ratestat -alias ixiap1 -txframe ixiaP1TxRate
	get_ratestat -alias ixiap2 -rxframe ixiaP2RxRate
	
	set expRate 1000
	set actTx [expr $ixiaP1TxRate / $baseRate * $expRate.000]
	set result [expr abs(($ixiaP2RxRate - $actTx) / $actTx) < $::diff]

	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP1TxRate: $ixiaP1TxRate, ixiaP2RxRate: $ixiaP2RxRate"
	
	go s=$::sutSlot1 l1p=$::slot1P2
	sets irate unLimited erate "rate100M"
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate "rate100M"
	
	go s=$::sutSlot2 l1p=$::slot2P2
	sets irate "rate100M" erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate "rate100M" -erate unLimited
	
	get_ratestat -alias ixiap1 -txframe ixiaP1TxRate
	get_ratestat -alias ixiap2 -rxframe ixiaP2RxRate
	
	set expRate 100
	set actTx [expr $ixiaP1TxRate / $baseRate * $expRate.000]
	set result [expr abs(($ixiaP2RxRate - $actTx) / $actTx) < $::diff]

	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP1TxRate: $ixiaP1TxRate, ixiaP2RxRate: $ixiaP2RxRate"
	
	# stop ixia
	send_traffic -alias ixiap1 -actiontype stop
	# set to factory default value of SUT
	go s=$::sutSlot1 l1p=$::slot1P2	
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
	go s=$::sutSlot2 l1p=$::slot2P2
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
	
	send_traffic -alias ixiap2 -actiontype start
	sleep 10
	get_ratestat -alias ixiap2 -txframe ixiaP2TxRate
	get_ratestat -alias ixiap1 -rxframe ixiaP1RxRate
	
	set expRate 1000
	set actTx [expr $ixiaP2TxRate / $baseRate * $expRate.000]
	set result [expr abs(($ixiaP1RxRate - $actTx) / $actTx) < $::diff]
	
	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP2TxRate: $ixiaP2TxRate, ixiaP1RxRate: $ixiaP1RxRate"
	
	go s=$::sutSlot1 l1p=$::slot1P2
	sets irate "rate100M" erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate "rate100M" -erate unLimited
	
	go s=$::sutSlot2 l1p=$::slot2P2
	sets irate unLimited erate "rate100M"
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate "rate100M"
	
	get_ratestat -alias ixiap2 -txframe ixiaP2TxRate
	get_ratestat -alias ixiap1 -rxframe ixiaP1RxRate
	
	set expRate 100
	set actTx [expr $ixiaP2TxRate / $baseRate * $expRate.000]
	set result [expr abs(($ixiaP1RxRate - $actTx) / $actTx) < $::diff]

	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP2TxRate: $ixiaP2TxRate, ixiaP1RxRate: $ixiaP1RxRate"
	
	# stop ixia
	send_traffic -alias ixiap2 -actiontype stop
	
	# set to factory default value of SUT
	go s=$::sutSlot1 l1p=$::slot1P2	
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
	go s=$::sutSlot2 l1p=$::slot2P2
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
}
# Rate Limit Fiber-06-000 Bidirectional - Ingress & Egress setting at Port 1 and Egress setting at Port 2	
proc ratelimit_fiber_26 {} {
	# config each port and check parameter value
	go s=$::sutSlot1 l1p=$::slot1P2
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
	go s=$::sutSlot2 l1p=$::slot2P2
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
	
	# send traffic from ixia port and check send and receive rate
	send_traffic -alias ixiap1 -actiontype start
	sleep 10
	get_ratestat -alias ixiap1 -txframe ixiaP1TxRate
	get_ratestat -alias ixiap2 -rxframe ixiaP2RxRate
	
	set result [expr $ixiaP2RxRate > [expr $ixiaP1TxRate * [expr 1 - $::diff]] && \
				$ixiaP2RxRate < [expr $ixiaP1TxRate * [expr 1 + $::diff]]]
	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP1TxRate: $ixiaP1TxRate, ixiaP2RxRate: $ixiaP2RxRate"
	
	send_traffic -alias ixiap2 -actiontype start
	sleep 10
	get_ratestat -alias ixiap2 -txframe ixiaP2TxRate
	get_ratestat -alias ixiap1 -rxframe ixiaP1RxRate
	
	set result [expr $ixiaP1RxRate > [expr $ixiaP2TxRate * [expr 1 - $::diff]] && \
				$ixiaP1RxRate < [expr $ixiaP2TxRate * [expr 1 + $::diff]]]
	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP2TxRate: $ixiaP2TxRate, ixiaP1RxRate: $ixiaP1RxRate"
	
	go s=$::sutSlot1 l1p=$::slot1P2
	sets irate "rate100M" erate "rate100M"
	show bandwidth allocation -batype countAllLayer1 -irate "rate100M" -erate "rate100M"
	
	set result [expr $ixiaP2RxRate > [expr $ixiaP1TxRate * [expr 1 - $::diff]] && \
				$ixiaP2RxRate < [expr $ixiaP1TxRate * [expr 1 + $::diff]]]
	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP1TxRate: $ixiaP1TxRate, ixiaP2RxRate: $ixiaP2RxRate"
	
	go s=$::sutSlot2 l1p=$::slot2P2
	sets irate unLimited erate "rate100M"
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate "rate100M"
	
	set result [expr $ixiaP2RxRate > [expr $ixiaP1TxRate * [expr 1 - $::diff]] && \
				$ixiaP2RxRate < [expr $ixiaP1TxRate * [expr 1 + $::diff]]]
	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP1TxRate: $ixiaP1TxRate, ixiaP2RxRate: $ixiaP2RxRate"
	
	# stop ixia
	send_traffic -alias ixiap2 -actiontype stop
	
	go s=$::sutSlot1 l1p=$::slot1P2
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
	
	# stop ixia
	send_traffic -alias ixiap1 -actiontype stop
	go s=$::sutSlot2 l1p=$::slot2P2
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
}
# Rate Limit Fiber-07-000 Bidirectional - Ingress & Egress setting at Port 1 and Ingress & Egress setting at Port 2	
proc ratelimit_fiber_27 {} {
	# config each port and check parameter value
	go s=$::sutSlot1 l1p=$::slot1P2
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
	go s=$::sutSlot2 l1p=$::slot2P2
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
	
	# send traffic from ixia port and check send and receive rate
	send_traffic -alias ixiap1 -actiontype start
	sleep 10
	get_ratestat -alias ixiap1 -txframe ixiaP1TxRate
	get_ratestat -alias ixiap2 -rxframe ixiaP2RxRate
	
	set result [expr $ixiaP2RxRate > [expr $ixiaP1TxRate * [expr 1 - $::diff]] && \
				$ixiaP2RxRate < [expr $ixiaP1TxRate * [expr 1 + $::diff]]]
	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP1TxRate: $ixiaP1TxRate, ixiaP2RxRate: $ixiaP2RxRate"
	
	send_traffic -alias ixiap2 -actiontype start
	sleep 10
	get_ratestat -alias ixiap2 -txframe ixiaP2TxRate
	get_ratestat -alias ixiap1 -rxframe ixiaP1RxRate
	
	set result [expr $ixiaP1RxRate > [expr $ixiaP2TxRate * [expr 1 - $::diff]] && \
				$ixiaP1RxRate < [expr $ixiaP2TxRate * [expr 1 + $::diff]]]
	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP2TxRate: $ixiaP2TxRate, ixiaP1RxRate: $ixiaP1RxRate"
	
	go s=$::sutSlot1 l1p=$::slot1P2
	sets irate "rate100M" erate "rate100M"
	show bandwidth allocation -batype countAllLayer1 -irate "rate100M" -erate "rate100M"
	
	set result [expr $ixiaP2RxRate > [expr $ixiaP1TxRate * [expr 1 - $::diff]] && \
				$ixiaP2RxRate < [expr $ixiaP1TxRate * [expr 1 + $::diff]]]
	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP1TxRate: $ixiaP1TxRate, ixiaP2RxRate: $ixiaP2RxRate"
	
	go s=$::sutSlot2 l1p=$::slot2P2
	sets irate "rate100M" erate "rate100M"
	show bandwidth allocation -batype countAllLayer1 -irate "rate100M" -erate "rate100M"
	
	set result [expr $ixiaP2RxRate > [expr $ixiaP1TxRate * [expr 1 - $::diff]] && \
				$ixiaP2RxRate < [expr $ixiaP1TxRate * [expr 1 + $::diff]]]
	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP1TxRate: $ixiaP1TxRate, ixiaP2RxRate: $ixiaP2RxRate"
	
	# stop ixia
	send_traffic -alias ixiap2 -actiontype stop
	
	go s=$::sutSlot1 l1p=$::slot1P2
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
	
	# stop ixia
	send_traffic -alias ixiap1 -actiontype stop
	go s=$::sutSlot2 l1p=$::slot2P2
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
}
# Rate Limit Fiber-08-000 Ingress & Egress setting status at Copper Port when port speed changed
proc ratelimit_fiber_28 {} {
	# config each port and check parameter value
	go s=$::sutSlot1 l1p=$::slot1P2
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited

	sets irate unLimited erate "rate900M"
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate "rate900M"
	
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
	
}
# Rate Limit Fiber-09-000 1518 Bytes Frame and Jumbo Frame rate limit behavior
proc ratelimit_fiber_29 {} {
	set baseRate 1000
	# config each port and check parameter value
	go s=$::sutSlot2 l1p=$::slot2P2
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
	
	config_frame -alias ixiap1 -framesize 1518
	# send traffic from ixia port and check send and receive rate
	send_traffic -alias ixiap1 -actiontype start
	sleep 10
	get_ratestat -alias ixiap1 -txframe ixiaP1TxRate
	get_ratestat -alias ixiap2 -rxframe ixiaP2RxRate

	set expRate 1000
	set actTx [expr $ixiaP1TxRate / $baseRate * $expRate.000]
	set result [expr abs(($ixiaP2RxRate - $actTx) / $actTx) < $::diff]
	
	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP1TxRate: $ixiaP1TxRate, ixiaP2RxRate: $ixiaP2RxRate"
	
	sets irate "rate100M" erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate "rate100M" -erate unLimited
	get_ratestat -alias ixiap1 -txframe ixiaP1TxRate
	get_ratestat -alias ixiap2 -rxframe ixiaP2RxRate
	
	set expRate 100
	set actTx [expr $ixiaP1TxRate / $baseRate * $expRate.000]
	set result [expr abs(($ixiaP2RxRate - $actTx) / $actTx) < $::diff]

	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP1TxRate: $ixiaP1TxRate, ixiaP2RxRate: $ixiaP2RxRate"
	
	# stop ixia
	send_traffic -alias ixiap1 -actiontype stop
	
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
	
	config_frame -alias ixiap1 -framesize 10240
	# send traffic from ixia port and check send and receive rate
	send_traffic -alias ixiap1 -actiontype start
	sleep 10
	get_ratestat -alias ixiap1 -txframe ixiaP1TxRate
	get_ratestat -alias ixiap2 -rxoversize ixiaP2RxRate
	
	set expRate 1000
	set actTx [expr $ixiaP1TxRate / $baseRate * $expRate.000]
	set result [expr abs(($ixiaP2RxRate - $actTx) / $actTx) < $::diff]
	
	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP1TxRate: $ixiaP1TxRate, ixiaP2RxRate: $ixiaP2RxRate"
	
	sets irate "rate100M" erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate "rate100M" -erate unLimited
	get_ratestat -alias ixiap1 -txframe ixiaP1TxRate
	get_ratestat -alias ixiap2 -rxoversize ixiaP2RxRate
	
	set expRate 100
	set actTx [expr $ixiaP1TxRate / $baseRate * $expRate.000]
	set result [expr abs(($ixiaP2RxRate - $actTx) / $actTx) < $::diff]
	
	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP1TxRate: $ixiaP1TxRate, ixiaP2RxRate: $ixiaP2RxRate"
	
	# stop ixia
	send_traffic -alias ixiap1 -actiontype stop
	
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
	
	config_frame -alias ixiap2 -framesize 1518
	# send traffic from ixia port and check send and receive rate
	send_traffic -alias ixiap2 -actiontype start
	sleep 10
	get_ratestat -alias ixiap2 -txframe ixiaP2TxRate
	get_ratestat -alias ixiap1 -rxframe ixiaP1RxRate
	
	set expRate 1000
	set actTx [expr $ixiaP2TxRate / $baseRate * $expRate.000]
	set result [expr abs(($ixiaP1RxRate - $actTx) / $actTx) < $::diff]
	
	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP2TxRate: $ixiaP2TxRate, ixiaP1RxRate: $ixiaP1RxRate"
	
	sets irate unLimited erate "rate100M"
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate "rate100M"
	get_ratestat -alias ixiap2 -txframe ixiaP2TxRate
	get_ratestat -alias ixiap1 -rxframe ixiaP1RxRate
	
	set expRate 100
	set actTx [expr $ixiaP2TxRate / $baseRate * $expRate.000]
	set result [expr abs(($ixiaP1RxRate - $actTx) / $actTx) < $::diff]
	
	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP2TxRate: $ixiaP2TxRate, ixiaP1RxRate: $ixiaP1RxRate"
	
	# stop ixia
	send_traffic -alias ixiap2 -actiontype stop
	
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
	
	config_frame -alias ixiap2 -framesize 10240
	send_traffic -alias ixiap2 -actiontype start
	sleep 10
	get_ratestat -alias ixiap2 -txframe ixiaP2TxRate
	get_ratestat -alias ixiap1 -rxoversize ixiaP1RxRate
	
	set expRate 1000
	set actTx [expr $ixiaP2TxRate / $baseRate * $expRate.000]
	set result [expr abs(($ixiaP1RxRate - $actTx) / $actTx) < $::diff]

	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP2TxRate: $ixiaP2TxRate, ixiaP1RxRate: $ixiaP1RxRate"
	
	sets irate unLimited erate "rate100M"
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate "rate100M"
	get_ratestat -alias ixiap2 -txframe ixiaP2TxRate
	get_ratestat -alias ixiap1 -rxoversize ixiaP1RxRate

	set expRate 100
	set actTx [expr $ixiaP2TxRate / $baseRate * $expRate.000]
	set result [expr abs(($ixiaP1RxRate - $actTx) / $actTx) < $::diff]

	if {$result} {      
		set res pass
	} else {
		set res fail
	}
	printlog -fileid $::tcLogId -res $res -cmd "compare send and receive rate" -comment "ixiaP2TxRate: $ixiaP2TxRate, ixiaP1RxRate: $ixiaP1RxRate"
	
	#stop ixia
	send_traffic -alias ixiap2 -actiontype stop
	
	sets irate unLimited erate unLimited
	show bandwidth allocation -batype countAllLayer1 -irate unLimited -erate unLimited
}