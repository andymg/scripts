#!/bin/tcl
# this is the user interface to start running one or more test suits

# -tester		str				mandatory		default: null
# -prjname		str				mandatory		default: null
# -tsname		str				mandatory		default: null
# -tclist		list			optional		default: all
# runTestSuit -tester markw -prjname ion2011august -tsname testsuit_vlan -tclist 1,2,4-8

source ./api/loader/loader.tcl

#runTestSuit -tester markw -prjname ion2011august -tsname testsuit_example -tclist 1-4

#source ./testsuits/ion2011august/testsuit_mac/testsuit_mac_para.tcl
	set ::sutIpAddr 192.168.0.61
	set ::sutSlot 16
	set ::sutP1 1
	set ::sutP2 2
	set ::sutP3 3
	set ::vlanid 10
	set ::ixiaIpAddr 192.168.1.21
	set ::ixiaPort1 3,2
	set ::ixiaPort2 3,1
	set ::ixiaPort3 3,3
	
	set ::ixiaMac1 "00 00 00 00 00 01"
	set ::ixiaMac2 "00 00 00 00 00 02"
	set ::ixiaMac3 "00 00 00 00 00 03"
	set ::ixiaFrameSize 100
	set ::ixiaSendRate 100
	set ::ixiaRunTime 1
	set ::testerName fieldt
	
	set ::ratePercentage 30
	set ::rateCount 10
   # login -ipaddr  $::sutIpAddr -sutname $::sutSlot
	connect_ixia -ipaddr $::ixiaIpAddr -portlist $::ixiaPort1,ixiap1 -alias allport -loginname tianlong
	config_portprop -alias ixiap1 -autonego enable -phymode copper 
	#config_portprop -alias ixiap2 -autonego enable -phymode copper
	#config_portprop -alias ixiap3 -autonego enable -phymode copper
	config_frame -alias ixiap1 -srcmac $::ixiaMac1 -dstmac $::ixiaMac3 -framesize $::ixiaFrameSize
	#config_frame -alias ixiap2 -srcmac $::ixiaMac2 -dstmac $::ixiaMac3 -framesize $::ixiaFrameSize
	config_stream -alias allport -rate $::ixiaSendRate

    config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode none -srcmac "00 00 00 00 01 01" -dstmac $::ixiaMac3 -framesize $::ixiaFrameSize