#!/bin/tcl
#fine ipmc_test1
#purpose :check basic function of ipmc

global ::session ""
set dut 192.168.4.16
set community private
set ::session "-v2c -c $community $dut"
set ::portNo 4

ipmc::vlanSnoopingAdd IGMP 25 True
	
set ::sutIpAddr 192.168.0.61
set ::portNo 4
set ::vlanid 10
set ::ixiaIpAddr 192.168.1.22
set ::ixiaPort1 2,1
set ::ixiaPort2 2,2

set ::ixiaMac1 "01 00 5e 00 00 05"
set ::ixiaMac2 "00 00 00 00 00 02"
set ::ixiaMac3 "00 00 00 00 5e 05"
set ::ixiaFrameSize 100
set ::ixiaSendRate 100
set ::ixiaRunTime 1
set ::testerName fieldt

set ::ratePercentage 30
set ::rateCount 10
connect_ixia -ipaddr $::ixiaIpAddr -portlist $::ixiaPort2,ixiap2 -alias allport -loginname andyIxia
config_portprop -alias ixiap2 -autonego enable -phymode fiber

config_frame -alias ixiap2 -frametype ethernetii -vlanmode none -srcmac $::ixiaMac3 -dstmac $::ixiaMac1 -srcip 192.168.3.66 -dstip 225.0.0.5 -igmptype v2report -groupip 228.0.0.9
#config_portprop -alias ixiap3 -autonego enable -phymode copper
	
#config_frame -alias ixiap2 -srcmac $::ixiaMac2 -dstmac $::ixiaMac3 -framesize $::ixiaFrameSize
config_stream -alias ixiap2 -sendmode stopstrm  -pktperbst 1 -ratemode fps -fpsrate 1
#config_frame -alias ixiap1 -vlanmode none -srcmac "33 00 00 00 05 08" -dstmac $::ixiaMac1 -framesize $::ixiaFrameSize
send_traffic -alias ixiap2 -actiontype start
