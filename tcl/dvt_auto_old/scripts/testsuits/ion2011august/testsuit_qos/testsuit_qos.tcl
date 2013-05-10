# Summary: this is a QoS test suit for ION platform
# Topology: ixiap1 <-> sutP1 ------ sutP3(SGMII) <-> ixiap3
#           ixiap2 <-> sutP2(SGMII) /
# DUT: x322x, x323x, x222x
# Owner: Field Tian
# Date: 2011-8-2
# version: 1.0.0
# Scope: 


# Init Qos default value
# pass
proc qos_1 {} {	
	login -ipaddr  $::sutIpAddr -sutname $::sutSlot
	connect_ixia -ipaddr $::ixiaIpAddr -portlist $::ixiaPort1,ixiap1,$::ixiaPort2,ixiap2,$::ixiaPort3,ixiap3 -alias allport -loginname tianlong
	config_portprop -alias ixiap1 -autonego enable -phymode copper 
	config_portprop -alias ixiap2 -autonego enable -phymode copper
	config_portprop -alias ixiap3 -autonego enable -phymode copper
	config_frame -alias ixiap1 -srcmac $::ixiaMac1 -dstmac $::ixiaMac3 -framesize $::ixiaFrameSize
	config_frame -alias ixiap2 -srcmac $::ixiaMac2 -dstmac $::ixiaMac3 -framesize $::ixiaFrameSize
	config_frame -alias ixiap3 -srcmac $::ixiaMac3
	config_stream -alias allport -rate $::ixiaSendRate
	
	go s = $::sutSlot l1d
	add vlan-db vid $::vlanid priority 4 pri-override disable
	sets vlan-db vid $::vlanid port $::sutP1 memetag noMod
	sets vlan-db vid $::vlanid port $::sutP2 memetag noMod
	sets vlan-db vid $::vlanid port $::sutP3 memetag noMod
	# add fwddb mac "00-00-00-00-00-01" conn-port 1 priority 5 type staticPA
	# sleep 3
	# add fwddb mac "00-00-00-00-00-02" conn-port 2 priority 5 type staticPA
	# sleep 3
	# add fwddb mac "00-00-00-00-00-03" conn-port 3 priority 6 type staticPA
	# sleep 3
	sets mac_learning enable portlist none
	
	go s=$::sutSlot l1p=$::sutP1
    sets port default-vid $::vlanid
	sets qos default-priority 2
	sets loam admin state disable
	sets tndp tx state disable

	go s=$::sutSlot l1p=$::sutP2
    sets port default-vid $::vlanid
	sets qos default-priority 3
	sets ether phymode=phySGMII
	sets loam admin state disable
	sets tndp tx state disable
	
	
	go s=$::sutSlot l1p=$::sutP3
	sets ether phymode=phySGMII
	sets loam admin state disable
	sets tndp tx state disable
	

}

#
#
proc qos_2 {} {

   puts "1111111111111111111111111111111******************"
    # 11.config device
    go s = $::sutSlot l1d
    sets vlan-db vid $::vlanid port $::sutP3 memetag tag
	
	go s=$::sutSlot l1p=$::sutP3
	sets port vlan tag mode network
	
	go s=$::sutSlot l1p=$::sutP1
	sets port vlan tag mode network
	sets qos default-priority 2
	
	
	# 12.config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode none
	clear_stat -alias allport
  
    # 13.send frames from port A to port C 
    start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length [expr $::ixiaFrameSize + 4] -srcmac $::ixiaMac1 -dstmac $::ixiaMac3 -framedata frameData
	check_frame -framedata $frameData -vlanid 10 -priority 2
	
	
	
	puts "2222222222222222222222222******************"
	# 21.config device
	go s = $::sutSlot l1d
	sets vlan-db vid 10 fid 0 pri-override enable
	
	
	go s=$::sutSlot l1p=$::sutP1
	sets qos priority by-vlan-id enable
	sets qos default-priority 2
	
	# 22.config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode none
	clear_stat -alias allport
	
	# 23.send frames from port A to port C 
	start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length [expr $::ixiaFrameSize + 4] -srcmac $::ixiaMac1 -dstmac $::ixiaMac3 -framedata frameData
	check_frame -framedata $frameData -vlanid 10 -priority 4
	sets qos priority by-vlan-id disable
	
  
  	 puts "333333333333333333333333******************"
    # 31.config device
	go s=$::sutSlot l1p=$::sutP1
	sets qos priority by-src-mac enable
	sets qos default-priority 2

	
	# 32.config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode none
	clear_stat -alias allport
	
	# 33.send frames from port A to port C 
	start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length [expr $::ixiaFrameSize + 4] -srcmac $::ixiaMac1 -dstmac $::ixiaMac3 -framedata frameData
    check_frame -framedata $frameData -vlanid 10 -priority 5  
	sets qos priority by-src-mac disable
  
   
  
  
   	 puts "4444444444444444444444444444******************"
    # 41.config device
	go s=$::sutSlot l1p=$::sutP1
	sets qos priority by-dst-mac enable
	sets qos default-priority 2
	
	# 42.config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode none
	clear_stat -alias allport
	
	# 43.send frames from port A to port C 
	start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length [expr $::ixiaFrameSize + 4] -srcmac $::ixiaMac1 -dstmac $::ixiaMac3 -framedata frameData
	check_frame -framedata $frameData -vlanid 10 -priority 6
	
	sets qos priority by-dst-mac disable	
    

	
	
  puts "5555555555555555555555555555******************"
	
	# 51.config device
	go s = $::sutSlot l1d
    sets vlan-db vid $::vlanid port $::sutP3 memetag tag
	
	go s=$::sutSlot l1p=$::sutP3
	sets port vlan tag mode provider
  
    go s=$::sutSlot l1p=$::sutP1
	sets port vlan tag mode provider
	sets qos default-priority 2
	
	# 52.config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode none
	clear_stat -alias allport
  
    # 53.send frames from port A to port C 
    start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length [expr $::ixiaFrameSize + 4] -srcmac $::ixiaMac1 -dstmac $::ixiaMac3 -framedata frameData
	check_frame -framedata $frameData -vlanid 10 -priority 2
  
  
  
	 puts "666666666666666666666666666******************"
    # 61.config device
	go s = $::sutSlot l1d
	sets vlan-db vid 10 fid 0 pri-override enable
	
	go s=$::sutSlot l1p=$::sutP1
	sets qos priority by-vlan-id enable
	sets qos default-priority 2
	
	go s = $::sutSlot l1d
	sets vlan-db vid 10 fid 0 pri-override enable
	
	
	# 62.config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode none
	clear_stat -alias allport
	
	# 63.send frames from port A to port C 
	start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length [expr $::ixiaFrameSize + 4] -srcmac $::ixiaMac1 -dstmac $::ixiaMac3 -framedata frameData
	check_frame -framedata $frameData -vlanid 10 -priority 4
	
	go s=$::sutSlot l1p=$::sutP1
	sets qos priority by-vlan-id disable
   
  
    puts "77777777777777777777777777777******************"
    # 71.config device
	go s=$::sutSlot l1p=$::sutP1
	sets qos priority by-src-mac enable
	sets qos default-priority 2
	
	# 72.config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode none
	clear_stat -alias allport
	
	# 73.send frames from port A to port C 
	start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length [expr $::ixiaFrameSize + 4] -srcmac $::ixiaMac1 -dstmac $::ixiaMac3 -framedata frameData
	check_frame -framedata $frameData -vlanid 10 -priority 5
	
	sets qos priority by-src-mac disable
	
	
	puts "88888888888888888888******************"
	# 81.config device
	go s=$::sutSlot l1p=$::sutP1
	sets qos default-priority 2
	sets qos priority by-dst-mac enable
	
	# 82.config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode none
	clear_stat -alias allport
	
	# 83.send frames from port A to port C 
	start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length [expr $::ixiaFrameSize + 4] -srcmac $::ixiaMac1 -dstmac $::ixiaMac3 -framedata frameData
	check_frame -framedata $frameData -vlanid 10 -priority 6
    
	sets qos priority by-dst-mac disable	
	
	
	
	go s = $::sutSlot l1d
	sets vlan-db vid 10 fid 0 pri-override disable
	
	
	
	
	
  	 puts "999999999999999999999999******************"
    # 91.config device
	go s = $::sutSlot l1d
	sets vlan-db vid $::vlanid port $::sutP3 memetag tag
	
	go s=$::sutSlot l1p=$::sutP3
	sets port vlan tag mode provider
  
    go s=$::sutSlot l1p=$::sutP1
	sets port vlan tag mode customer
	sets qos default-priority 2
	
	# 92.config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode none
	clear_stat -alias allport
  
    # 93.send frames from port A to port C 
    start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length [expr $::ixiaFrameSize + 4] -srcmac $::ixiaMac1 -dstmac $::ixiaMac3 -framedata frameData
	check_frame -framedata $frameData -vlanid 10 -priority 2
  
  
  
	 puts "10101010101010101010******************"
    # 101.config device
	
	go s = $::sutSlot l1d
	sets vlan-db vid 10 fid 0 pri-override enable
	
	go s=$::sutSlot l1p=$::sutP1
	sets qos default-priority 2
	sets qos priority by-vlan-id enable
	
	
	
	# 102.config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode none
	clear_stat -alias allport
	
	# 103.send frames from port A to port C 
	start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length [expr $::ixiaFrameSize + 4] -srcmac $::ixiaMac1 -dstmac $::ixiaMac3 -framedata frameData
	check_frame -framedata $frameData -vlanid 10 -priority 4
	sets qos priority by-vlan-id disable
   
  
    
  
  	 puts "11 11 11 11 11 11 11 11 11 11******************"
    # 111.config device
	go s=$::sutSlot l1p=$::sutP1
	sets qos default-priority 2
	sets qos priority by-src-mac enable
	
	# 112.config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode none
	clear_stat -alias allport
	
	# 113.send frames from port A to port C 
	start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length [expr $::ixiaFrameSize + 4] -srcmac $::ixiaMac1 -dstmac $::ixiaMac3 -framedata frameData
	check_frame -framedata $frameData -vlanid 10 -priority 5
	sets qos priority by-src-mac disable
	
	
	
	
	 puts "12 12 12 12 12 12 12 12 12 ******************"
	# 121.config device
	go s=$::sutSlot l1p=$::sutP1
	sets qos default-priority 2
	sets qos priority by-dst-mac enable
	
	# 122.config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode none
	clear_stat -alias allport
	
	# 123.send frames from port A to port C 
	start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length [expr $::ixiaFrameSize + 4] -srcmac $::ixiaMac1 -dstmac $::ixiaMac3 -framedata frameData
	check_frame -framedata $frameData -vlanid 10 -priority 6
	sets qos priority by-dst-mac disable	
	


   # reset all vlan parameters to factory default value	successful
	settodefaultconfig
	
}


# tag frame for QOS  priority override in c-c mode
# 
proc qos_3 {} {
	go s = $::sutSlot l1d
    sets vlan-db vid=10 port=3 memetag=tag
	
	
	# 1.config device
	go s=$::sutSlot l1p=$::sutP3
	sets port default-vid $::vlanid
	sets port vlan tag mode customer
	
	# go s=$::sutSlot l1p=$::sutP2
	# sets port vlan tag mode customer
	
    go s=$::sutSlot l1p=$::sutP1
	sets port vlan tag mode customer
	sets qos default-priority 2
	
	# 2.config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 0
	clear_stat -alias allport
	
	# 3.send frames from port A to port C 
	start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length $::ixiaFrameSize -srcmac $::ixiaMac1 -dstmac $::ixiaMac3 -framedata frameData
	check_frame -framedata $frameData -tpid 8100 -vlanid 10 -priority 0
	
	
	# 4.config device
	go s = $::sutSlot l1d
	sets vlan-db vid 10 fid 0 pri-override enable
	
	go s=$::sutSlot l1p=$::sutP1
	sets qos priority by-vlan-id enable
	
	# 5.config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 0
	clear_stat -alias allport
	
	#6.send frames from port A to port C 
	start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length $::ixiaFrameSize -srcmac $::ixiaMac1 -dstmac $::ixiaMac3 -framedata frameData
	get_stat -alias ixiap1 -txframe ixiap1tx
	get_stat -alias ixiap3 -rxframe ixiap3rx
	# check_frame -framedata $frameData -tpid 8100 -vlanid 10 -priority 4
	check_frame -framedata $frameData -tpid 8100 -vlanid 10 -priority 0
	sets qos priority by-vlan-id disable
	
	
	#7.config device
	sets qos priority by-src-mac enable
	
	#8.config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 0
	clear_stat -alias allport
	
	#9.send frames from port A to port C 
	start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length $::ixiaFrameSize -srcmac $::ixiaMac1 -dstmac $::ixiaMac3 -framedata frameData
	
	# check_frame -framedata $frameData -tpid 8100 -vlanid 10 -priority 5
	check_frame -framedata $frameData -tpid 8100 -vlanid 10 -priority 0
	sets qos priority by-src-mac disable
	

	# 10.config device
	sets qos priority by-dst-mac enable
		
	# 11.config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 0
	clear_stat -alias allport
	
	# 12.send frames from port A to port C 
	start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length $::ixiaFrameSize -srcmac $::ixiaMac1 -dstmac $::ixiaMac3 -framedata frameData
	
    # check_frame -framedata $frameData -tpid 8100 -vlanid 10 -priority 6
	check_frame -framedata $frameData -tpid 8100 -vlanid 10 -priority 0
	sets qos priority by-dst-mac disable	
	
	# 13. reset all vlan parameters to factory default value successful
	settodefaultconfig
	
}
#
# 
#
proc qos_4 {} {

    go s = $::sutSlot l1d
    sets vlan-db vid=10 port=3 memetag=tag
	
	
	# 1.config device
	go s=$::sutSlot l1p=$::sutP3
	sets port default-vid $::vlanid
	sets port vlan tag mode network
	
	# go s=$::sutSlot l1p=$::sutP2
	# sets port vlan tag mode network
	
    go s=$::sutSlot l1p=$::sutP1
	sets port vlan tag mode network
	sets qos default-priority 2
	
	# 2.config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 0
	clear_stat -alias allport
	
	# 3.send frames from port A to port C 
	start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length $::ixiaFrameSize -srcmac $::ixiaMac1 -dstmac $::ixiaMac3 -framedata frameData
	check_frame -framedata $frameData -tpid 8100 -vlanid 10 -priority 0
	
	
	# 4.config device
	go s = $::sutSlot l1d
	sets vlan-db vid 10 fid 0 pri-override enable
	
	go s=$::sutSlot l1p=$::sutP1
	sets qos priority by-vlan-id enable
	
	# 5.config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 0
	clear_stat -alias allport
	
	#6.send frames from port A to port C 
	start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length $::ixiaFrameSize -srcmac $::ixiaMac1 -dstmac $::ixiaMac3 -framedata frameData
	get_stat -alias ixiap1 -txframe ixiap1tx
	get_stat -alias ixiap3 -rxframe ixiap3rx
	check_frame -framedata $frameData -tpid 8100 -vlanid 10 -priority 4
	sets qos priority by-vlan-id disable
	
	
	#7.config device
	sets qos priority by-src-mac enable
	
	#8.config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 0
	clear_stat -alias allport
	
	#9.send frames from port A to port C 
	start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length $::ixiaFrameSize -srcmac $::ixiaMac1 -dstmac $::ixiaMac3 -framedata frameData
	
	check_frame -framedata $frameData -tpid 8100 -vlanid 10 -priority 5
	sets qos priority by-src-mac disable
	

	# 10.config device
	sets qos priority by-dst-mac enable
		
	# 11.config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 0
	clear_stat -alias allport
	
	# 12.send frames from port A to port C 
	start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length $::ixiaFrameSize -srcmac $::ixiaMac1 -dstmac $::ixiaMac3 -framedata frameData
	
    check_frame -framedata $frameData -tpid 8100 -vlanid 10 -priority 6
	sets qos priority by-dst-mac disable	
	
	# 13. reset all vlan parameters to factory default value	successful
	settodefaultconfig

}

#
#
#
proc qos_5 {} {
    go s = $::sutSlot l1d
    sets vlan-db vid $::vlanid port $::sutP3 memetag tag
	
	puts "11111111111111111111111111*********************"
	# 1.config device
	go s=$::sutSlot l1p=$::sutP3
	sets port vlan tag mode provider
	
	go s=$::sutSlot l1p=$::sutP2
	sets port vlan tag mode provider
	
    go s=$::sutSlot l1p=$::sutP1
	sets port vlan tag mode provider
	sets qos default-priority 2
	
	# 2.config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 0
	clear_stat -alias allport
	
	# 3.send frames from port A to port C 
	start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length [expr $::ixiaFrameSize + 4] -srcmac $::ixiaMac1 -dstmac $::ixiaMac3 -framedata frameData
	check_frame -framedata $frameData -tpid 88a8 -vlanid 10 -priority 0
	
	puts "222222222222222222222222222222*********************"
	# 4.config device
	go s = $::sutSlot l1d
	sets vlan-db vid 10 fid 0 pri-override enable
	go s=$::sutSlot l1p=$::sutP1
	sets qos priority by-vlan-id enable
	sets qos default-priority 2
	
   # 5.config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 0
	clear_stat -alias allport
	
	# 6.send frames from port A to port C 
	start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length [expr $::ixiaFrameSize + 4] -srcmac $::ixiaMac1 -dstmac $::ixiaMac3 -framedata frameData
	check_frame -framedata $frameData -tpid 88a8 -vlanid 10 -priority 4
	sets qos priority by-vlan-id disable
	
   	puts "333333333333333333333*********************"
	# 7.config device
	go s=$::sutSlot l1p=$::sutP1
	sets qos priority by-src-mac enable
	sets qos default-priority 2
	
	# 8.config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 0
	clear_stat -alias allport
	
	# 9.send frames from port A to port C 
	start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length [expr $::ixiaFrameSize + 4] -srcmac $::ixiaMac1 -dstmac $::ixiaMac3 -framedata frameData
	check_frame -framedata $frameData -tpid 88a8 -vlanid 10 -priority 5
	
	sets qos priority by-src-mac disable

    puts "444444444444444444444444444444444*********************"
	# 10.config device
	go s=$::sutSlot l1p=$::sutP1
	sets qos priority by-dst-mac enable
	sets qos default-priority 2
	
	# 11.config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 0
	clear_stat -alias allport
	
	# 12.send frames from port A to port C 
	start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length [expr $::ixiaFrameSize + 4] -srcmac $::ixiaMac1 -dstmac $::ixiaMac3 -framedata frameData
	
    check_frame -framedata $frameData -tpid 88a8 -vlanid 10 -priority 6
	sets qos priority by-dst-mac disable	
	
	# 13. reset all vlan parameters to factory default value	successful
	settodefaultconfig
}

# 
#pass
proc qos_6 {} {
    
	go s = $::sutSlot l1d
    sets vlan-db vid $::vlanid port $::sutP3 memetag tag
	
	# 1.condig device
	go s=$::sutSlot l1p=$::sutP3
	sets port vlan tag mode provider
	
	
    go s=$::sutSlot l1p=$::sutP1
	sets port vlan tag mode customer
	sets qos default-priority 2
	
	# 2.config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode none
	clear_stat -alias allport
	
	# 3.send frames from port A to port C 
	start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length [expr $::ixiaFrameSize + 4] -srcmac $::ixiaMac1 -dstmac $::ixiaMac3 -framedata frameData
	check_frame -framedata $frameData -vlanid 10 -priority 2
	
	
	#4.config device
	go s = $::sutSlot l1d
	sets vlan-db vid 10 fid 0 pri-override enable
	go s=$::sutSlot l1p=$::sutP1
	sets qos priority by-vlan-id enable
	
	#5.config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode none
	clear_stat -alias allport
	
	#6.send frames from port A to port C 
	start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length [expr $::ixiaFrameSize + 4] -srcmac $::ixiaMac1 -dstmac $::ixiaMac3 -framedata frameData
	
	check_frame -framedata $frameData -vlanid 10 -priority 4
	sets qos priority by-vlan-id disable
	
	
	
	
	#7.config device
	go s=$::sutSlot l1p=$::sutP1
	sets qos priority by-src-mac enable
	
	#8.config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode none
	clear_stat -alias allport
	
	#9.send frames from port A to port C 
	start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length [expr $::ixiaFrameSize + 4] -srcmac $::ixiaMac1 -dstmac $::ixiaMac3 -framedata frameData
	
	check_frame -framedata $frameData -vlanid 10 -priority 5
	sets qos priority by-src-mac disable
	
	
	#10.config device
	go s=$::sutSlot l1p=$::sutP1
	sets qos priority by-dst-mac enable
	
	#11.config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode none
	clear_stat -alias allport
	
	#12.send frames from port A to port C 
	start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length [expr $::ixiaFrameSize + 4] -srcmac $::ixiaMac1 -dstmac $::ixiaMac3 -framedata frameData
	
	check_frame -framedata $frameData -vlanid 10 -priority 6
	sets qos priority by-dst-mac disable	
	
	#13. reset all vlan parameters to factory default value	successful
	settodefaultconfig
}

#
#
#
proc qos_7 {} {
	go s = $::sutSlot l1d
	sets vlan-db vid $::vlanid port $::sutP1 memetag tag
	sets vlan-db vid $::vlanid port $::sutP2 memetag tag
	sets vlan-db vid $::vlanid port $::sutP3 memetag tag
	
	# 1.condig device
	go s=$::sutSlot l1p=$::sutP3
	sets port vlan tag mode network
	
	go s=$::sutSlot l1p=$::sutP2
	sets port vlan tag mode network
	
    go s=$::sutSlot l1p=$::sutP1
	sets port vlan tag mode network
	
	for {set i 7} {$i>=4} {incr i -1} {
	# puts "$i*************************************************"
	go s=$::sutSlot l1p=$::sutP1
	sets qos ingress-priority=0 remap-priority=$i
	
	# 2.config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 0
	clear_stat -alias allport
	
	# 3.send frames from port A to port C 
	start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length $::ixiaFrameSize -srcmac $::ixiaMac1 -dstmac $::ixiaMac3 -framedata frameData
	
	check_frame -framedata $frameData -tpid 8100 -vlanid 10 -priority $i
	
	}
	
	
	# config device
	go s=$::sutSlot l1p=$::sutP3
	sets port vlan tag mode provider
	sets port vlan tag provider ethtype x8100
	
	go s=$::sutSlot l1p=$::sutP2
	sets port vlan tag mode provider
	
    go s=$::sutSlot l1p=$::sutP1
	sets port vlan tag mode provider
	sets port vlan tag provider ethtype x8100
	
	
	
	for {set i 3} {$i>=0} {incr i -1} {
	
	# puts "$i*************************************************"
	go s=$::sutSlot l1p=$::sutP1
	sets qos ingress-priority=0 remap-priority=$i
	
	# 2.config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 0
	clear_stat -alias allport
	
	# 3.send frames from port A to port C 
	start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length $::ixiaFrameSize -srcmac $::ixiaMac1 -dstmac $::ixiaMac3 -framedata frameData
	
	check_frame -framedata $frameData -tpid 8100 -vlanid 10 -priority $i
	
	
	}
	#  reset all vlan parameters to factory default value	successful
	settodefaultconfig
	
   }

#
# WRR with IEEE package transmission
#
proc qos_8 {} {
    # 1.config 
	go s=$::sutSlot l1p=$::sutP3
	sets port vlan tag mode network
	
	go s=$::sutSlot l1p=$::sutP2
	sets port vlan tag mode network
	sets qos priority tag-type useIEEE
	
	
    go s=$::sutSlot l1p=$::sutP1
	sets port vlan tag mode network
	sets qos priority tag-type useIEEE
	
	go s = $::sutSlot l1d
	sets vlan-db vid $::vlanid port $::sutP3 memetag noMod
	
	
	
	puts "1111111111111111111111111***************************"
	# 11.config ixia
	config_stream -alias allport -rate 100
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 0
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 0
	clear_stat -alias allport
	
	# 12config filter
	config_filter -alias ixiap3 -uds3 enable -uds3sa sa1 -sa1addr $::ixiaMac1
	config_filter -alias ixiap3 -uds4 enable -uds4sa sa2 -sa2addr $::ixiaMac2
	
	# 13.send frames from port A,B to port C 
	send_traffic -alias allport -actiontype start
	get_ratestat -alias ixiap3 -rxuds3 rxuds3Rate -rxuds4 rxuds4Rate
	puts "rxuds3Rate: $rxuds3Rate"
	puts "rxuds4Rate: $rxuds4Rate"
	send_traffic -alias allport -actiontype stop
	set receRate [expr $rxuds4Rate * 1.00 / $rxuds3Rate]
	if {($receRate<1.3)&&($receRate>0.7)} { 
		set receRate 1
	}
	check_result -para1 1 -para2 $receRate -condition = \
			-log "rxuds3=$rxuds3Rate, rxuds4=$rxuds4Rate, rxuds4/rxuds3: [expr $rxuds4Rate * 1.00 / $rxuds3Rate]"
	
	
	puts "2222222222222222222222222222***************************\n"
	# 21.config ixia
	config_stream -alias allport -rate 100
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 0
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 1
	clear_stat -alias allport
	
	# 22config filter
	config_filter -alias ixiap3 -uds3 enable -uds3sa sa1 -sa1addr $::ixiaMac1
	config_filter -alias ixiap3 -uds4 enable -uds4sa sa2 -sa2addr $::ixiaMac2
	
	# 23.send frames from port A,B to port C 
	send_traffic -alias allport -actiontype start
	get_ratestat -alias ixiap3 -rxuds3 rxuds3Rate -rxuds4 rxuds4Rate
	puts "rxuds3Rate: $rxuds3Rate"
	puts "rxuds4Rate: $rxuds4Rate"
	send_traffic -alias allport -actiontype stop
	set receRate [expr $rxuds4Rate * 1.00 / $rxuds3Rate]
	if {($receRate<1.3)&&($receRate>0.7)} { 
		set receRate 1
	}
	check_result -para1 1 -para2 $receRate -condition =  \
			-log "rxuds3=$rxuds3Rate, rxuds4=$rxuds4Rate, rxuds4/rxuds3: [expr $rxuds4Rate * 1.00 / $rxuds3Rate]"
	
	
	puts "33333333333333333333333333333333333***************************\n"
	# 31.config ixia
	config_stream -alias allport -rate 100
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 0
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 2
	clear_stat -alias allport
	
	# 32config filter
	config_filter -alias ixiap3 -uds3 enable -uds3sa sa1 -sa1addr $::ixiaMac1
	config_filter -alias ixiap3 -uds4 enable -uds4sa sa2 -sa2addr $::ixiaMac2
	
	# 33.send frames from port A,B to port C 
	send_traffic -alias allport -actiontype start
	get_ratestat -alias ixiap3 -rxuds3 rxuds3Rate -rxuds4 rxuds4Rate
	puts "rxuds3Rate: $rxuds3Rate"
	puts "rxuds4Rate: $rxuds4Rate"
	send_traffic -alias allport -actiontype stop
	set receRate [expr $rxuds4Rate * 1.00 / $rxuds3Rate]
	if {($receRate<2.3)&&($receRate>1.7)} { 
		set receRate 2
	}
	check_result -para1 2 -para2 $receRate -condition = \
			-log "rxuds3=$rxuds3Rate, rxuds4=$rxuds4Rate, rxuds4/rxuds3: [expr $rxuds4Rate * 1.00 / $rxuds3Rate]"
	
	puts "444444444444444444444444444444***************************\n"
    # 41.config ixia
	config_stream -alias allport -rate 100
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 0
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 3
	clear_stat -alias allport
	
	# 42config filter
	config_filter -alias ixiap3 -uds3 enable -uds3sa sa1 -sa1addr $::ixiaMac1
	config_filter -alias ixiap3 -uds4 enable -uds4sa sa2 -sa2addr $::ixiaMac2
	
	# 43.send frames from port A,B to port C 
	send_traffic -alias allport -actiontype start
	get_ratestat -alias ixiap3 -rxuds3 rxuds3Rate -rxuds4 rxuds4Rate
	puts "rxuds3Rate: $rxuds3Rate"
	puts "rxuds4Rate: $rxuds4Rate"
	send_traffic -alias allport -actiontype stop
	
	set receRate [expr $rxuds4Rate * 1.00 / $rxuds3Rate]
	if {($receRate<2.3)&&($receRate>1.7)} { 
		set receRate 2
	}
	check_result -para1 2 -para2 $receRate -condition = \
			-log "rxuds3=$rxuds3Rate, rxuds4=$rxuds4Rate, rxuds4/rxuds3: [expr $rxuds4Rate * 1.00 / $rxuds3Rate]"
			
			
	puts "55555555555555555555555555555**************"		
	# 51.config ixia
	config_stream -alias allport -rate 100
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 0
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 4
	clear_stat -alias allport
	
	# 52config filter
	config_filter -alias ixiap3 -uds3 enable -uds3sa sa1 -sa1addr $::ixiaMac1
	config_filter -alias ixiap3 -uds4 enable -uds4sa sa2 -sa2addr $::ixiaMac2
	
	# 53.send frames from port A,B to port C 
	send_traffic -alias allport -actiontype start
	get_ratestat -alias ixiap3 -rxuds3 rxuds3Rate -rxuds4 rxuds4Rate
	puts "rxuds3Rate: $rxuds3Rate"
	puts "rxuds4Rate: $rxuds4Rate"
	send_traffic -alias allport -actiontype stop
	set receRate [expr $rxuds4Rate * 1.00 / $rxuds3Rate]
	if {($receRate<4.3)&&($receRate>3.7)} { 
		set receRate 4
	}
	check_result -para1 4 -para2 $receRate -condition = \
			-log "rxuds3=$rxuds3Rate, rxuds4=$rxuds4Rate, rxuds4/rxuds3: [expr $rxuds4Rate * 1.00 / $rxuds3Rate]"
	
	
	puts "66666666666666666666666666666*******************"
	# 61.config ixia
	config_stream -alias allport -rate 100
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 0
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 5
	clear_stat -alias allport
	
	# 62config filter
	config_filter -alias ixiap3 -uds3 enable -uds3sa sa1 -sa1addr $::ixiaMac1
	config_filter -alias ixiap3 -uds4 enable -uds4sa sa2 -sa2addr $::ixiaMac2
	
	# 63.send frames from port A,B to port C 
	send_traffic -alias allport -actiontype start
	get_ratestat -alias ixiap3 -rxuds3 rxuds3Rate -rxuds4 rxuds4Rate
	puts "rxuds3Rate: $rxuds3Rate"
	puts "rxuds4Rate: $rxuds4Rate"
	send_traffic -alias allport -actiontype stop
	set receRate [expr $rxuds4Rate * 1.00 / $rxuds3Rate]
	if {($receRate<4.3)&&($receRate>3.7)} { 
		set receRate 4
	}
	check_result -para1 4 -para2 $receRate -condition = \
			-log "rxuds3=$rxuds3Rate, rxuds4=$rxuds4Rate, rxuds4/rxuds3: [expr $rxuds4Rate * 1.00 / $rxuds3Rate]"
	
	puts "7777777777777777777777777777777*******************"
	# 71.config ixia
	config_stream -alias allport -rate 100
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 0
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 6
	clear_stat -alias allport
	
	# 72config filter
	config_filter -alias ixiap3 -uds3 enable -uds3sa sa1 -sa1addr $::ixiaMac1
	config_filter -alias ixiap3 -uds4 enable -uds4sa sa2 -sa2addr $::ixiaMac2
	
	# 73.send frames from port A,B to port C 
	send_traffic -alias allport -actiontype start
	get_ratestat -alias ixiap3 -rxuds3 rxuds3Rate -rxuds4 rxuds4Rate
	puts "rxuds3Rate: $rxuds3Rate"
	puts "rxuds4Rate: $rxuds4Rate"
	send_traffic -alias allport -actiontype stop
	set receRate [expr $rxuds4Rate * 1.00 / $rxuds3Rate]
	if {($receRate<8.3)&&($receRate>7.7)} { 
		set receRate 8
	}
	check_result -para1 8 -para2 $receRate -condition = \
			-log "rxuds3=$rxuds3Rate, rxuds4=$rxuds4Rate, rxuds4/rxuds3: [expr $rxuds4Rate * 1.00 / $rxuds3Rate]"
	
	puts "888888888888888888888888888***************************"
	# 81.config ixia
	config_stream -alias allport -rate 100
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 0
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 7
	clear_stat -alias allport
	
	# 82.config filter
	config_filter -alias ixiap3 -uds3 enable -uds3sa sa1 -sa1addr $::ixiaMac1
	config_filter -alias ixiap3 -uds4 enable -uds4sa sa2 -sa2addr $::ixiaMac2
	
	# 83.send frames from port A,B to port C 
	send_traffic -alias allport -actiontype start
	get_ratestat -alias ixiap3 -rxuds3 rxuds3Rate -rxuds4 rxuds4Rate
	puts "rxuds3Rate: $rxuds3Rate"
	puts "rxuds4Rate: $rxuds4Rate"
	send_traffic -alias allport -actiontype stop
	set receRate [expr $rxuds4Rate * 1.00 / $rxuds3Rate]
	if {($receRate<8.3)&&($receRate>7.7)} { 
		set receRate 8
	}
	check_result -para1 8 -para2 $receRate -condition = \
			-log "rxuds3=$rxuds3Rate, rxuds4=$rxuds4Rate, rxuds4/rxuds3: [expr $rxuds4Rate * 1.00 / $rxuds3Rate]"
	
	
	puts "99999999999999999********************"
	# 91.config ixia
	config_stream -alias allport -rate 100
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 2
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 4
	clear_stat -alias allport
	
	# 92config filter
	config_filter -alias ixiap3 -uds3 enable -uds3sa sa1 -sa1addr $::ixiaMac1
	config_filter -alias ixiap3 -uds4 enable -uds4sa sa2 -sa2addr $::ixiaMac2
	
	# 93.send frames from port A,B to port C 
	send_traffic -alias allport -actiontype start
	get_ratestat -alias ixiap3 -rxuds3 rxuds3Rate -rxuds4 rxuds4Rate
	puts "rxuds3Rate: $rxuds3Rate"
	puts "rxuds4Rate: $rxuds4Rate"
	send_traffic -alias allport -actiontype stop
	set receRate [expr $rxuds4Rate * 1.00 / $rxuds3Rate]
	if {($receRate<2.3)&&($receRate>1.7)} { 
		set receRate 2
	}
	check_result -para1 2 -para2 $receRate -condition = \
			-log "rxuds3=$rxuds3Rate, rxuds4=$rxuds4Rate, rxuds4/rxuds3: [expr $rxuds4Rate * 1.00 / $rxuds3Rate]"
	
	puts "10101010101010110**************************"
	# 101.config ixia
	config_stream -alias allport -rate 100
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 2
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 6
	clear_stat -alias allport
	
	# 102config filter
	config_filter -alias ixiap3 -uds3 enable -uds3sa sa1 -sa1addr $::ixiaMac1
	config_filter -alias ixiap3 -uds4 enable -uds4sa sa2 -sa2addr $::ixiaMac2
	
	# 103.send frames from port A,B to port C 
	send_traffic -alias allport -actiontype start
	get_ratestat -alias ixiap3 -rxuds3 rxuds3Rate -rxuds4 rxuds4Rate
	puts "rxuds3Rate: $rxuds3Rate"
	puts "rxuds4Rate: $rxuds4Rate"
	send_traffic -alias allport -actiontype stop
	set receRate [expr $rxuds4Rate * 1.00 / $rxuds3Rate]
	if {($receRate<4.3)&&($receRate>3.7)} { 
		set receRate 4
	}
	check_result -para1 4 -para2 $receRate -condition = \
			-log "rxuds3=$rxuds3Rate, rxuds4=$rxuds4Rate, rxuds4/rxuds3: [expr $rxuds4Rate * 1.00 / $rxuds3Rate]"
	
	puts "11111111111111111111****************"
	# 111.config ixia
	config_stream -alias allport -rate 100
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 4
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 6
	clear_stat -alias allport
	
	# 112config filter
	config_filter -alias ixiap3 -uds3 enable -uds3sa sa1 -sa1addr $::ixiaMac1
	config_filter -alias ixiap3 -uds4 enable -uds4sa sa2 -sa2addr $::ixiaMac2
	
	# 113.send frames from port A,B to port C 
	send_traffic -alias allport -actiontype start
	get_ratestat -alias ixiap3 -rxuds3 rxuds3Rate -rxuds4 rxuds4Rate
	puts "rxuds3Rate: $rxuds3Rate"
	puts "rxuds4Rate: $rxuds4Rate"
	send_traffic -alias allport -actiontype stop
	set receRate [expr $rxuds4Rate * 1.00 / $rxuds3Rate]
	if {($receRate<2.3)&&($receRate>1.7)} { 
		set receRate 2
	}
	check_result -para1 2 -para2 $receRate -condition = \
			-log "rxuds3=$rxuds3Rate, rxuds4=$rxuds4Rate, rxuds4/rxuds3: [expr $rxuds4Rate * 1.00 / $rxuds3Rate]"
	
	
	
	
	
	
	
	puts "12121212121212121212*******************"
	# 120.config
	go s=$::sutSlot l1p=$::sutP3
	sets port vlan tag mode network
	
	go s=$::sutSlot l1p=$::sutP2
	sets port vlan tag mode network
	sets qos priority tag-type useIEEE
	
    go s=$::sutSlot l1p=$::sutP1
	sets port vlan tag mode network
	sets qos priority tag-type useIEEE
	
	go s = $::sutSlot l1d
	sets vlan-db vid $::vlanid port $::sutP3 memetag tag
	
	# 121.config ixia
	config_stream -alias allport -rate 100
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -priority 0 -frametype ethernetii -qosmode dscp -dscpmode custom -dscpvalue 47
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -priority 1 -frametype ethernetii -qosmode dscp -dscpmode custom -dscpvalue 63
	clear_stat -alias allport
	
	# 122config filter
	config_filter -alias ixiap3 -uds3 enable -uds3sa sa1 -sa1addr $::ixiaMac1
	config_filter -alias ixiap3 -uds4 enable -uds4sa sa2 -sa2addr $::ixiaMac2
	
	# 123.send frames from port A,B to port C 
	send_traffic -alias allport -actiontype start
	get_ratestat -alias ixiap3 -rxuds3 rxuds3Rate -rxuds4 rxuds4Rate
	puts "rxuds3Rate: $rxuds3Rate"
	puts "rxuds4Rate: $rxuds4Rate"
	send_traffic -alias allport -actiontype stop
	set receRate [expr $rxuds4Rate * 1.00 / $rxuds3Rate]
	if {($receRate<1.3)&&($receRate>0.7)} { 
		set receRate 1
	}
	check_result -para1 1 -para2 $receRate -condition = -log "rxuds3=$rxuds3Rate, rxuds4=$rxuds4Rate, rxuds4/rxuds3: [expr $rxuds4Rate  / $rxuds3Rate]"
	
	puts "131313131313131313131313****************"
	# 130.config
	go s=$::sutSlot l1p=$::sutP3
	sets port vlan tag mode network
	
	go s=$::sutSlot l1p=$::sutP2
	sets port vlan tag mode network
	sets qos priority tag-type useIP
	
    go s=$::sutSlot l1p=$::sutP1
	sets port vlan tag mode network
	sets qos priority tag-type useIP
	
	go s = $::sutSlot l1d
	sets vlan-db vid $::vlanid port $::sutP3 memetag tag
	
	# 131.config ixia
	config_stream -alias allport -rate 100
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -priority 0 -frametype ethernetii -qosmode dscp -dscpmode custom -dscpvalue 47
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -priority 1 -frametype ethernetii -qosmode dscp -dscpmode custom -dscpvalue 63
	clear_stat -alias allport
	
	# 132config filter
	config_filter -alias ixiap3 -uds3 enable -uds3sa sa1 -sa1addr $::ixiaMac1
	config_filter -alias ixiap3 -uds4 enable -uds4sa sa2 -sa2addr $::ixiaMac2
	
	# 133.send frames from port A,B to port C 
	send_traffic -alias allport -actiontype start
	get_ratestat -alias ixiap3 -rxuds3 rxuds3Rate -rxuds4 rxuds4Rate
	puts "rxuds3Rate: $rxuds3Rate"
	puts "rxuds4Rate: $rxuds4Rate"
	send_traffic -alias allport -actiontype stop
	set receRate [expr $rxuds4Rate * 1.00 / $rxuds3Rate]
	if {($receRate<2.3)&&($receRate>1.7)} { 
		set receRate 2
	}
	check_result -para1 2 -para2 $receRate -condition = -log "rxuds3=$rxuds3Rate, rxuds4=$rxuds4Rate, rxuds4/rxuds3: [expr $rxuds4Rate  / $rxuds3Rate]"
	
	puts "1414141414141414141414********************"
	# 140.config
	go s = $::sutSlot l1d
	sets vlan-db vid $::vlanid port $::sutP3 memetag tag
	
	go s=$::sutSlot l1p=$::sutP1
	sets port vlan tag mode network
	sets qos priority tag-type useIP
	
	go s=$::sutSlot l1p=$::sutP2
	sets port vlan tag mode network
	sets qos priority tag-type useIEEE
	
	go s=$::sutSlot l1p=$::sutP3
	sets port vlan tag mode network
	
	# 141.config ixia
	config_stream -alias allport -rate 100
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -priority 0 -frametype ethernetii -qosmode dscp -dscpmode custom -dscpvalue 47
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -priority 1 -frametype ethernetii -qosmode dscp -dscpmode custom -dscpvalue 63
	clear_stat -alias allport
	
	# 142config filter
	config_filter -alias ixiap3 -uds3 enable -uds3sa sa1 -sa1addr $::ixiaMac1
	config_filter -alias ixiap3 -uds4 enable -uds4sa sa2 -sa2addr $::ixiaMac2
	
	# 143.send frames from port A,B to port C 
	send_traffic -alias allport -actiontype start
	get_ratestat -alias ixiap3 -rxuds3 rxuds3Rate -rxuds4 rxuds4Rate
	puts "rxuds3Rate: $rxuds3Rate"
	puts "rxuds4Rate: $rxuds4Rate"
	send_traffic -alias allport -actiontype stop
	set receRate [expr $rxuds3Rate * 1.00 / $rxuds4Rate]
	if {($receRate<4.3)&&($receRate>3.7)} { 
		set receRate 4
	}
	check_result -para1 4 -para2 $receRate -condition = -log "rxuds3=$rxuds3Rate, rxuds4=$rxuds4Rate, rxuds3/rxuds4: [expr $rxuds3Rate  / $rxuds4Rate]"
	
	
	puts "15151515151515151515*******************"
	# 150.config
	go s = $::sutSlot l1d
	sets vlan-db vid $::vlanid port $::sutP3 memetag tag
	sets dot1dbridge ip-priority-index 47 remap-priority 0
	
	go s=$::sutSlot l1p=$::sutP1
	sets port vlan tag mode network
	sets qos priority tag-type useIP
	
	go s=$::sutSlot l1p=$::sutP2
	sets port vlan tag mode network
	sets qos priority tag-type useIP
	
	go s=$::sutSlot l1p=$::sutP3
	sets port vlan tag mode network
	
	# 151.config ixia
	config_stream -alias allport -rate 100
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -priority 0 -frametype ethernetii -qosmode dscp -dscpmode custom -dscpvalue 47
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -priority 1 -frametype ethernetii -qosmode dscp -dscpmode custom -dscpvalue 63
	clear_stat -alias allport
	
	# 152.config filter
	config_filter -alias ixiap3 -uds3 enable -uds3sa sa1 -sa1addr $::ixiaMac1
	config_filter -alias ixiap3 -uds4 enable -uds4sa sa2 -sa2addr $::ixiaMac2
	
	# 153.send frames from port A,B to port C 
	send_traffic -alias allport -actiontype start
	get_ratestat -alias ixiap3 -rxuds3 rxuds3Rate -rxuds4 rxuds4Rate
	puts "rxuds3Rate: $rxuds3Rate"
	puts "rxuds4Rate: $rxuds4Rate"
	send_traffic -alias allport -actiontype stop
	set receRate [expr $rxuds4Rate * 1.00 / $rxuds3Rate]
	if {($receRate<8.3)&&($receRate>7.7)} { 
		set receRate 8
	}
	check_result -para1 8 -para2 $receRate -condition = -log "rxuds3=$rxuds3Rate, rxuds4=$rxuds4Rate, rxuds4/rxuds3: [expr $rxuds4Rate  / $rxuds3Rate]"
	
	
	
	puts "161616161616161616******************"
	# 160.config
	go s = $::sutSlot l1d
	sets vlan-db vid $::vlanid port $::sutP3 memetag tag
	sets dot1dbridge ip-priority-index 47 remap-priority 1
	
	go s=$::sutSlot l1p=$::sutP1
	sets port vlan tag mode network
	sets qos priority tag-type useIP
	
	go s=$::sutSlot l1p=$::sutP2
	sets port vlan tag mode network
	sets qos priority tag-type useIP
	
	go s=$::sutSlot l1p=$::sutP3
	sets port vlan tag mode network
	
	# 161.config ixia
	config_stream -alias allport -rate 100
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -priority 0 -frametype ethernetii -qosmode dscp -dscpmode custom -dscpvalue 47
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -priority 1 -frametype ethernetii -qosmode dscp -dscpmode custom -dscpvalue 63
	clear_stat -alias allport
	
	# 162.config filter
	config_filter -alias ixiap3 -uds3 enable -uds3sa sa1 -sa1addr $::ixiaMac1
	config_filter -alias ixiap3 -uds4 enable -uds4sa sa2 -sa2addr $::ixiaMac2
	
	# 163.send frames from port A,B to port C 
	send_traffic -alias allport -actiontype start
	get_ratestat -alias ixiap3 -rxuds3 rxuds3Rate -rxuds4 rxuds4Rate
	puts "rxuds3Rate: $rxuds3Rate"
	puts "rxuds4Rate: $rxuds4Rate"
	send_traffic -alias allport -actiontype stop
	set receRate [expr $rxuds4Rate * 1.00 / $rxuds3Rate]
	if {($receRate<4.3)&&($receRate>3.7)} { 
		set receRate 4
	}
	check_result -para1 4 -para2 $receRate -condition = -log "rxuds3=$rxuds3Rate, rxuds4=$rxuds4Rate, rxuds4/rxuds3: [expr $rxuds4Rate  / $rxuds3Rate]"
	##############2
	
	puts "171717171717171717*****************"
	# 170.config
	go s = $::sutSlot l1d
	sets vlan-db vid $::vlanid port $::sutP3 memetag tag
	sets dot1dbridge ip-priority-index 47 remap-priority 3
	
	go s=$::sutSlot l1p=$::sutP1
	sets port vlan tag mode network
	sets qos priority tag-type useIP
	
	go s=$::sutSlot l1p=$::sutP2
	sets port vlan tag mode network
	sets qos priority tag-type useIP
	
	go s=$::sutSlot l1p=$::sutP3
	sets port vlan tag mode network
	
	# 171.config ixia
	config_stream -alias allport -rate 100
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -priority 0 -frametype ethernetii -qosmode dscp -dscpmode custom -dscpvalue 47
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -priority 1 -frametype ethernetii -qosmode dscp -dscpmode custom -dscpvalue 63
	clear_stat -alias allport
	
	# 172.config filter
	config_filter -alias ixiap3 -uds3 enable -uds3sa sa1 -sa1addr $::ixiaMac1
	config_filter -alias ixiap3 -uds4 enable -uds4sa sa2 -sa2addr $::ixiaMac2
	
	# 173.send frames from port A,B to port C 
	send_traffic -alias allport -actiontype start
	get_ratestat -alias ixiap3 -rxuds3 rxuds3Rate -rxuds4 rxuds4Rate
	puts "rxuds3Rate: $rxuds3Rate"
	puts "rxuds4Rate: $rxuds4Rate"
	send_traffic -alias allport -actiontype stop
	set receRate [expr $rxuds4Rate * 1.00 / $rxuds3Rate]
	if {($receRate<1.3)&&($receRate>0.7)} { 
		set receRate 1
	}
	check_result -para1 1 -para2 $receRate -condition = -log "rxuds3=$rxuds3Rate, rxuds4=$rxuds4Rate, rxuds4/rxuds3: [expr $rxuds4Rate  / $rxuds3Rate]"
	###################2
	
	puts "181818181818181818********************"
	# 180.config
	go s = $::sutSlot l1d
	sets vlan-db vid $::vlanid port $::sutP3 memetag tag
	sets dot1dbridge ip-priority-index 47 remap-priority 2
	
	go s=$::sutSlot l1p=$::sutP1
	sets port vlan tag mode network
	sets qos priority tag-type useIP
	
	go s=$::sutSlot l1p=$::sutP2
	sets port vlan tag mode network
	sets qos priority tag-type useIP
	
	go s=$::sutSlot l1p=$::sutP3
	sets port vlan tag mode network
	
	# 181.config ixia
	config_stream -alias allport -rate 100
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -priority 0 -frametype ethernetii -qosmode dscp -dscpmode custom -dscpvalue 47
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -priority 1 -frametype ethernetii -qosmode dscp -dscpmode custom -dscpvalue 63
	clear_stat -alias allport
	
	# 182.config filter
	config_filter -alias ixiap3 -uds3 enable -uds3sa sa1 -sa1addr $::ixiaMac1
	config_filter -alias ixiap3 -uds4 enable -uds4sa sa2 -sa2addr $::ixiaMac2
	
	# 183.send frames from port A,B to port C 
	send_traffic -alias allport -actiontype start
	get_ratestat -alias ixiap3 -rxuds3 rxuds3Rate -rxuds4 rxuds4Rate
	puts "rxuds3Rate: $rxuds3Rate"
	puts "rxuds4Rate: $rxuds4Rate"
	send_traffic -alias allport -actiontype stop
	set receRate [expr $rxuds4Rate * 1.00 / $rxuds3Rate]
	if {($receRate<2.3)&&($receRate>1.7)} { 
		set receRate 2 
	}
	check_result -para1 2 -para2 $receRate -condition = -log "rxuds3=$rxuds3Rate, rxuds4=$rxuds4Rate, rxuds4/rxuds3: [expr $rxuds4Rate  / $rxuds3Rate]"
	
	
	
	puts "19191919109191919***********"
	# 190.config
	go s = $::sutSlot l1d
	sets vlan-db vid $::vlanid port $::sutP3 memetag tag
	
	go s=$::sutSlot l1p=$::sutP1
	sets port vlan tag mode network
	sets qos priority tag-type useIEEE
	
	go s=$::sutSlot l1p=$::sutP2
	sets port vlan tag mode network
	sets qos priority tag-type useIEEE
	
	go s=$::sutSlot l1p=$::sutP3
	sets port vlan tag mode network
	
	# 191.config ixia
	config_stream -alias allport -rate 100
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -priority 0 -frametype ethernetii -qosmode dscp -dscpmode custom -dscpvalue 47
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -priority 1 -frametype ethernetii -qosmode dscp -dscpmode custom -dscpvalue 63
	clear_stat -alias allport
	
	# 192.config filter
	config_filter -alias ixiap3 -uds3 enable -uds3sa sa1 -sa1addr $::ixiaMac1
	config_filter -alias ixiap3 -uds4 enable -uds4sa sa2 -sa2addr $::ixiaMac2
	
	# 193.send frames from port A,B to port C 
	send_traffic -alias allport -actiontype start
	get_ratestat -alias ixiap3 -rxuds3 rxuds3Rate -rxuds4 rxuds4Rate
	puts "rxuds3Rate: $rxuds3Rate"
	puts "rxuds4Rate: $rxuds4Rate"
	send_traffic -alias allport -actiontype stop
	set receRate [expr $rxuds4Rate * 1.00 / $rxuds3Rate]
	if {($receRate<1.3)&&($receRate>0.7)} { 
		set receRate 1 
	}
	check_result -para1 1 -para2 $receRate -condition = -log "rxuds3=$rxuds3Rate, rxuds4=$rxuds4Rate, rxuds4/rxuds3: [expr $rxuds4Rate * 1.00 / $rxuds3Rate]"
	
	
	
	
	puts "2020202020202020***********************"
	# 200.config
	go s = $::sutSlot l1d
	sets vlan-db vid $::vlanid port $::sutP3 memetag tag
	
	go s=$::sutSlot l1p=$::sutP1
	sets port vlan tag mode network
	sets qos priority tag-type useIEEE
	
	go s=$::sutSlot l1p=$::sutP2
	sets port vlan tag mode network
	sets qos priority tag-type useIEEE
	
	go s=$::sutSlot l1p=$::sutP3
	sets port vlan tag mode network
	
	# 201.config ixia
	config_stream -alias allport -rate 100
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -priority 0 -frametype ethernetii -qosmode dscp -dscpmode custom -dscpvalue 47
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -priority 3 -frametype ethernetii -qosmode dscp -dscpmode custom -dscpvalue 63
	clear_stat -alias allport
	
	# 202.config filter
	config_filter -alias ixiap3 -uds3 enable -uds3sa sa1 -sa1addr $::ixiaMac1
	config_filter -alias ixiap3 -uds4 enable -uds4sa sa2 -sa2addr $::ixiaMac2
	
	# 203.send frames from port A,B to port C 
	send_traffic -alias allport -actiontype start
	get_ratestat -alias ixiap3 -rxuds3 rxuds3Rate -rxuds4 rxuds4Rate
	puts "rxuds3Rate: $rxuds3Rate"
	puts "rxuds4Rate: $rxuds4Rate"
	send_traffic -alias allport -actiontype stop
	set receRate [expr $rxuds4Rate * 1.00 / $rxuds3Rate]
	if {($receRate<2.3)&&($receRate>1.7)} { 
		set receRate 2
	}
	check_result -para1 2 -para2 $receRate -condition = -log "rxuds3=$rxuds3Rate, rxuds4=$rxuds4Rate, rxuds4/rxuds3: [expr $rxuds4Rate * 1.00 / $rxuds3Rate]"
	
	
	
	# 210.config
	go s = $::sutSlot l1d
	sets vlan-db vid $::vlanid port $::sutP3 memetag tag
	
	go s=$::sutSlot l1p=$::sutP1
	sets port vlan tag mode network
	sets qos priority tag-type useIEEE
	
	go s=$::sutSlot l1p=$::sutP2
	sets port vlan tag mode network
	sets qos priority tag-type useIEEE
	
	go s=$::sutSlot l1p=$::sutP3
	sets port vlan tag mode network
	
	
	puts "21212121212121************************"
	# 211.config ixia
	config_stream -alias allport -rate 100
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -priority 0 -frametype ethernetii -qosmode dscp -dscpmode custom -dscpvalue 47
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -priority 4 -frametype ethernetii -qosmode dscp -dscpmode custom -dscpvalue 63
	clear_stat -alias allport
	
	# 212.config filter
	config_filter -alias ixiap3 -uds3 enable -uds3sa sa1 -sa1addr $::ixiaMac1
	config_filter -alias ixiap3 -uds4 enable -uds4sa sa2 -sa2addr $::ixiaMac2
	
	# 213.send frames from port A,B to port C 
	send_traffic -alias allport -actiontype start
	get_ratestat -alias ixiap3 -rxuds3 rxuds3Rate -rxuds4 rxuds4Rate
	puts "rxuds3Rate: $rxuds3Rate"
	puts "rxuds4Rate: $rxuds4Rate"
	send_traffic -alias allport -actiontype stop
	set receRate [expr $rxuds4Rate * 1.00 / $rxuds3Rate]
	if {($receRate<4.3)&&($receRate>3.7)} { 
		set receRate 4 
	}
	check_result -para1 4 -para2 $receRate -condition = -log "rxuds3=$rxuds3Rate, rxuds4=$rxuds4Rate, rxuds4/rxuds3: [expr $rxuds4Rate * 1.00 / $rxuds3Rate]"
	
	
	
	
	puts "222222222222222222***********************8"
	# 220.config
	go s = $::sutSlot l1d
	sets vlan-db vid $::vlanid port $::sutP3 memetag tag
	
	go s=$::sutSlot l1p=$::sutP1
	sets port vlan tag mode network
	sets qos priority tag-type useIEEE
	
	go s=$::sutSlot l1p=$::sutP2
	sets port vlan tag mode network
	sets qos priority tag-type useIEEE
	
	go s=$::sutSlot l1p=$::sutP3
	sets port vlan tag mode network
	
	# 221.config ixia
	config_stream -alias allport -rate 100
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -priority 0 -frametype ethernetii -qosmode dscp -dscpmode custom -dscpvalue 47
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -priority 7 -frametype ethernetii -qosmode dscp -dscpmode custom -dscpvalue 63
	clear_stat -alias allport
	
	# 222.config filter
	config_filter -alias ixiap3 -uds3 enable -uds3sa sa1 -sa1addr $::ixiaMac1
	config_filter -alias ixiap3 -uds4 enable -uds4sa sa2 -sa2addr $::ixiaMac2
	
	# 223.send frames from port A,B to port C 
	send_traffic -alias allport -actiontype start
	get_ratestat -alias ixiap3 -rxuds3 rxuds3Rate -rxuds4 rxuds4Rate
	puts "rxuds3Rate: $rxuds3Rate"
	puts "rxuds4Rate: $rxuds4Rate"
	set receRate [expr $rxuds4Rate * 1.00 / $rxuds3Rate]
	if {($receRate<8.3)&&($receRate>7.7)} { 
		set receRate 8
	}
	check_result -para1 8 -para2 $receRate -condition = -log "rxuds3=$rxuds3Rate, rxuds4=$rxuds4Rate, rxuds4/rxuds3: [expr $rxuds4Rate * 1.00 / $rxuds3Rate]"
	
	
	puts "2424242424242424************************"
	# 240 config
	go s = $::sutSlot l1d
	sets vlan-db vid $::vlanid port $::sutP3 memetag tag
	sets vlan-db vid 10 fid 0 pri-override enable
	
	go s=$::sutSlot l1p=$::sutP1
	sets port vlan tag mode network
	sets qos priority tag-type useIP
	sets qos priority by-vlan-id enable
	
	go s=$::sutSlot l1p=$::sutP2
	sets port vlan tag mode network
	sets qos priority tag-type useIP
	
	go s=$::sutSlot l1p=$::sutP3
	sets port vlan tag mode network
	
	# 241.config ixia
	config_stream -alias allport -rate 100
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -priority 0 -frametype ethernetii -qosmode dscp -dscpmode custom -dscpvalue 47
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -priority 1 -frametype ethernetii -qosmode dscp -dscpmode custom -dscpvalue 63
	clear_stat -alias allport
	
	# 242.config filter
	config_filter -alias ixiap3 -uds3 enable -uds3sa sa1 -sa1addr $::ixiaMac1
	config_filter -alias ixiap3 -uds4 enable -uds4sa sa2 -sa2addr $::ixiaMac2
	
	# 243.send frames from port A,B to port C 
	send_traffic -alias allport -actiontype start
	get_ratestat -alias ixiap3 -rxuds3 rxuds3Rate -rxuds4 rxuds4Rate
	puts "rxuds3Rate: $rxuds3Rate"
	puts "rxuds4Rate: $rxuds4Rate"
	send_traffic -alias allport -actiontype stop
	set receRate [expr $rxuds4Rate * 1.00 / $rxuds3Rate]
	if {($receRate<2.3)&&($receRate>1.7)} { 
		set receRate 2 
	}
	check_result -para1 2 -para2 $receRate -condition = -log "rxuds3=$rxuds3Rate, rxuds4=$rxuds4Rate, rxuds4/rxuds3: [expr $rxuds4Rate * 1.00 / $rxuds3Rate]"

	
	
	
	puts "25252525252525***************"
	# 250 config
	go s = $::sutSlot l1d
	sets vlan-db vid $::vlanid port $::sutP3 memetag tag
	
	go s=$::sutSlot l1p=$::sutP1
	sets port vlan tag mode network
	sets qos priority tag-type useIP
	sets qos priority by-dst-mac enable
	
	go s=$::sutSlot l1p=$::sutP2
	sets port vlan tag mode network
	sets qos priority tag-type useIP
	
	go s=$::sutSlot l1p=$::sutP3
	sets port vlan tag mode network
	
	# 251.config ixia
	config_stream -alias allport -rate 100
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -priority 0 -frametype ethernetii -qosmode dscp -dscpmode custom -dscpvalue 47
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -priority 1 -frametype ethernetii -qosmode dscp -dscpmode custom -dscpvalue 63
	clear_stat -alias allport
	
	# 252.config filter
	config_filter -alias ixiap3 -uds3 enable -uds3sa sa1 -sa1addr $::ixiaMac1
	config_filter -alias ixiap3 -uds4 enable -uds4sa sa2 -sa2addr $::ixiaMac2
	
	# 253.send frames from port A,B to port C 
	send_traffic -alias allport -actiontype start
	get_ratestat -alias ixiap3 -rxuds3 rxuds3Rate -rxuds4 rxuds4Rate
	puts "rxuds3Rate: $rxuds3Rate"
	puts "rxuds4Rate: $rxuds4Rate"
	send_traffic -alias allport -actiontype stop
	set receRate [expr $rxuds4Rate * 1.00 / $rxuds3Rate]
	if {($receRate<1.3)&&($receRate>0.7)} { 
		set receRate 1 
	}
	check_result -para1 1 -para2 $receRate -condition = -log "rxuds3=$rxuds3Rate, rxuds4=$rxuds4Rate, rxuds4/rxuds3: [expr $rxuds4Rate * 1.00 / $rxuds3Rate]"
	
	go s=$::sutSlot l1p=$::sutP1
	sets qos priority by-dst-mac enable
	
	
	
	
	
	puts "262626262626******************"
	# 260 config
	go s = $::sutSlot l1d
	sets vlan-db vid $::vlanid port $::sutP3 memetag tag
	
	go s=$::sutSlot l1p=$::sutP1
	sets port vlan tag mode network
	sets qos priority tag-type useIP
	sets qos priority by-src-mac enable
	
	go s=$::sutSlot l1p=$::sutP2
	sets port vlan tag mode network
	sets qos priority tag-type useIP
	
	go s=$::sutSlot l1p=$::sutP3
	sets port vlan tag mode network
	
	# 261.config ixia
	config_stream -alias allport -rate 100
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -priority 0 -frametype ethernetii -qosmode dscp -dscpmode custom -dscpvalue 47
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -priority 1 -frametype ethernetii -qosmode dscp -dscpmode custom -dscpvalue 63
	clear_stat -alias allport
	
	# 262.config filter
	config_filter -alias ixiap3 -uds3 enable -uds3sa sa1 -sa1addr $::ixiaMac1
	config_filter -alias ixiap3 -uds4 enable -uds4sa sa2 -sa2addr $::ixiaMac2
	
	# 263.send frames from port A,B to port C 
	send_traffic -alias allport -actiontype start
	get_ratestat -alias ixiap3 -rxuds3 rxuds3Rate -rxuds4 rxuds4Rate
	puts "rxuds3Rate: $rxuds3Rate"
	puts "rxuds4Rate: $rxuds4Rate"
	send_traffic -alias allport -actiontype stop
	set receRate [expr $rxuds4Rate * 1.00 / $rxuds3Rate]
	if {($receRate<1.3)&&($receRate>0.7)} { 
		set receRate 1 
	}
	check_result -para1 1 -para2 $receRate -condition = -log "rxuds3=$rxuds3Rate, rxuds4=$rxuds4Rate, rxuds4/rxuds3: [expr $rxuds4Rate * 1.00 / $rxuds3Rate]"
	
	go s=$::sutSlot l1p=$::sutP1
	sets qos priority by-src-mac enable
	
	
	puts "27272727272727******************8"
	# 270 config
	go s=$::sutSlot l1p=$::sutP1
	sets port vlan tag mode customer
	sets qos priority by-dst-mac enable
	
	go s=$::sutSlot l1p=$::sutP2
	sets port vlan tag mode customer
	
	go s=$::sutSlot l1p=$::sutP3
	sets port vlan tag mode customer
	
	# 271.config ixia
	config_stream -alias allport -rate 100
	config_frame -alias ixiap1 -vlanmode none -frametype ethernetii -qosmode dscp -dscpmode custom -dscpvalue 47
	config_frame -alias ixiap2 -vlanmode none -frametype ethernetii -qosmode dscp -dscpmode custom -dscpvalue 63
	clear_stat -alias allport
	
	# 272.config filter
	config_filter -alias ixiap3 -uds3 enable -uds3sa sa1 -sa1addr $::ixiaMac1
	config_filter -alias ixiap3 -uds4 enable -uds4sa sa2 -sa2addr $::ixiaMac2
	
	# 273.send frames from port A,B to port C 
	send_traffic -alias allport -actiontype start
	get_ratestat -alias ixiap3 -rxuds3 rxuds3Rate -rxuds4 rxuds4Rate
	puts "rxuds3Rate: $rxuds3Rate"
	puts "rxuds4Rate: $rxuds4Rate"
	send_traffic -alias allport -actiontype stop
	set receRate [expr $rxuds4Rate * 1.00 / $rxuds3Rate]
	if {($receRate<1.3)&&($receRate>0.7)} { 
		set receRate 1 
	}
	check_result -para1 1 -para2 $receRate -condition = -log "rxuds3=$rxuds3Rate, rxuds4=$rxuds4Rate, rxuds4/rxuds3: [expr $rxuds4Rate * 1.00 / $rxuds3Rate]"
	
	go s=$::sutSlot l1p=$::sutP1
	sets qos priority by-dst-mac disable
	
	settodefaultconfig
	
}
#SP with IEEE package transmission
#
proc qos_9 {} {
	
	# config parameter
	go s=$::sutSlot l1p=$::sutP3
	sets port vlan tag mode network
	sets port egress queuingmethod=sp
	
	go s=$::sutSlot l1p=$::sutP2
	sets port vlan tag mode network
	sets qos priority tag-type=useIEEE
	
    go s=$::sutSlot l1p=$::sutP1
	sets port vlan tag mode network
	sets qos priority tag-type=useIEEE
	
	puts "1111111111111111111*******************"
	# 11.config ixia
	config_stream -alias allport -rate 100
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 0
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 0
	clear_stat -alias allport
	
	# 12config filter
	config_filter -alias ixiap3 -uds3 enable -uds3sa sa1 -sa1addr $::ixiaMac1
	config_filter -alias ixiap3 -uds4 enable -uds4sa sa2 -sa2addr $::ixiaMac2
	
	# 13.send frames from port A,B to port C 
	send_traffic -alias allport -actiontype start
	get_ratestat -alias ixiap3 -rxuds3 rxuds3Rate -rxuds4 rxuds4Rate
	puts "rxuds3Rate: $rxuds3Rate"
	puts "rxuds4Rate: $rxuds4Rate"
	send_traffic -alias allport -actiontype stop
	set receRate [expr $rxuds3Rate * 1.00 / $rxuds4Rate]
	check_result -para1 1 -para2 $receRate -condition != -percentage $::ratePercentage \
			-log "rxuds3=$rxuds3Rate, rxuds4=$rxuds4Rate, rxuds3/rxuds4: [expr $rxuds3Rate * 1.00 / $rxuds4Rate]"
	
	
	go s=$::sutSlot l1p=$::sutP3
	sets port vlan tag mode network
	sets port egress queuingmethod=sp
	
	
	puts "222222222222222222222*******************"
	# 21.config ixia
	config_stream -alias allport -rate 100
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 0
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 1
	clear_stat -alias allport
	
	# 22config filter
	config_filter -alias ixiap3 -uds3 enable -uds3sa sa1 -sa1addr $::ixiaMac1
	config_filter -alias ixiap3 -uds4 enable -uds4sa sa2 -sa2addr $::ixiaMac2
	
	# 23.send frames from port A,B to port C 
	send_traffic -alias allport -actiontype start
	get_ratestat -alias ixiap3 -rxuds3 rxuds3Rate -rxuds4 rxuds4Rate
	puts "rxuds3Rate: $rxuds3Rate"
	puts "rxuds4Rate: $rxuds4Rate"
	send_traffic -alias allport -actiontype stop
	
	set receRate [expr $rxuds3Rate * 1.00 / $rxuds4Rate]
	check_result -para1 1 -para2 $receRate -condition != -percentage $::ratePercentage \
			-log "rxuds3=$rxuds3Rate, rxuds4=$rxuds4Rate, rxuds3/rxuds4: [expr $rxuds3Rate * 1.00 / $rxuds4Rate]"
	  
    
    
	
	
	puts "33333333333333333333333333333*******************"
    go s=$::sutSlot l1p=$::sutP3
	sets port vlan tag mode network
	sets port egress queuingmethod=sp
	
	# 31.config ixia
	config_stream -alias allport -rate 100
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 0
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 2
	clear_stat -alias allport
	
	# 32config filter
	config_filter -alias ixiap3 -uds3 enable -uds3sa sa1 -sa1addr $::ixiaMac1
	config_filter -alias ixiap3 -uds4 enable -uds4sa sa2 -sa2addr $::ixiaMac2
	
	# 33.send frames from port A,B to port C 
	send_traffic -alias allport -actiontype start
	get_ratestat -alias ixiap3 -rxuds3 rxuds3Rate -rxuds4 rxuds4Rate
	puts "rxuds3Rate: $rxuds3Rate"
	puts "rxuds4Rate: $rxuds4Rate"
	send_traffic -alias allport -actiontype stop
	check_result -para1 $::rateCount -para2 $rxuds3Rate -condition > -log "rxuds3Rate=$rxuds3Rate"
    check_result -para1 0 -para2 $rxuds4Rate -condition != -log "rxuds4Rate!=0"
	
	puts "4444444444444444444444444444444*******************"
	# 41.config ixia
	config_stream -alias allport -rate 100
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 0
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 3
	clear_stat -alias allport
	
	# 42config filter
	config_filter -alias ixiap3 -uds3 enable -uds3sa sa1 -sa1addr $::ixiaMac1
	config_filter -alias ixiap3 -uds4 enable -uds4sa sa2 -sa2addr $::ixiaMac2
	
	# 43.send frames from port A,B to port C 
	send_traffic -alias allport -actiontype start
	get_ratestat -alias ixiap3 -rxuds3 rxuds3Rate -rxuds4 rxuds4Rate
	puts "rxuds3Rate: $rxuds3Rate"
	puts "rxuds4Rate: $rxuds4Rate"
	send_traffic -alias allport -actiontype stop
	check_result -para1 $::rateCount -para2 $rxuds3Rate -condition > -log "rxuds3Rate=$rxuds3Rate"
    check_result -para1 0 -para2 $rxuds4Rate -condition != -log "rxuds4Rate!=0"
    
	
	puts "55555555555555555555555555*******************"
	# 51.config ixia
	config_stream -alias allport -rate 100
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 0
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 4
	clear_stat -alias allport
	
	# 52config filter
	config_filter -alias ixiap3 -uds3 enable -uds3sa sa1 -sa1addr $::ixiaMac1
	config_filter -alias ixiap3 -uds4 enable -uds4sa sa2 -sa2addr $::ixiaMac2
	
	# 53.send frames from port A,B to port C 
	send_traffic -alias allport -actiontype start
	get_ratestat -alias ixiap3 -rxuds3 rxuds3Rate -rxuds4 rxuds4Rate
	puts "rxuds3Rate: $rxuds3Rate"
	puts "rxuds4Rate: $rxuds4Rate"
	send_traffic -alias allport -actiontype stop
	check_result -para1 $::rateCount -para2 $rxuds3Rate -condition > -log "rxuds3Rate=$rxuds3Rate"
    check_result -para1 0 -para2 $rxuds4Rate -condition != -log "rxuds4Rate!=0"
	
	puts "6666666666666666666666666666*******************"
	# 61.config ixia
	config_stream -alias allport -rate 100
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 0
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 5
	clear_stat -alias allport
	
	# 62config filter
	config_filter -alias ixiap3 -uds3 enable -uds3sa sa1 -sa1addr $::ixiaMac1
	config_filter -alias ixiap3 -uds4 enable -uds4sa sa2 -sa2addr $::ixiaMac2
	
	# 63.send frames from port A,B to port C 
	send_traffic -alias allport -actiontype start
	get_ratestat -alias ixiap3 -rxuds3 rxuds3Rate -rxuds4 rxuds4Rate
	puts "rxuds3Rate: $rxuds3Rate"
	puts "rxuds4Rate: $rxuds4Rate"
	send_traffic -alias allport -actiontype stop
	check_result -para1 $::rateCount -para2 $rxuds3Rate -condition > -log "rxuds3Rate=$rxuds3Rate"
    check_result -para1 0 -para2 $rxuds4Rate -condition != -log "rxuds4Rate!=0"
	
	puts "77777777777777777777777777777*******************"
	# 71.config ixia
	config_stream -alias allport -rate 100
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 0
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 6
	clear_stat -alias allport
	
	# 72config filter
	config_filter -alias ixiap3 -uds3 enable -uds3sa sa1 -sa1addr $::ixiaMac1
	config_filter -alias ixiap3 -uds4 enable -uds4sa sa2 -sa2addr $::ixiaMac2
	
	# 73.send frames from port A,B to port C 
	send_traffic -alias allport -actiontype start
	get_ratestat -alias ixiap3 -rxuds3 rxuds3Rate -rxuds4 rxuds4Rate
	puts "rxuds3Rate: $rxuds3Rate"
	puts "rxuds4Rate: $rxuds4Rate"
	send_traffic -alias allport -actiontype stop
	check_result -para1 $::rateCount -para2 $rxuds3Rate -condition > -log "rxuds3Rate=$rxuds3Rate"
    check_result -para1 0 -para2 $rxuds4Rate -condition != -log "rxuds4Rate!=0"
	
	puts "8888888888888888888888888*******************"
	# 81.config ixia
	config_stream -alias allport -rate 100
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 0
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 7
	clear_stat -alias allport
	
	# 82config filter
	config_filter -alias ixiap3 -uds3 enable -uds3sa sa1 -sa1addr $::ixiaMac1
	config_filter -alias ixiap3 -uds4 enable -uds4sa sa2 -sa2addr $::ixiaMac2
	
	# 83.send frames from port A,B to port C 
	send_traffic -alias allport -actiontype start
	get_ratestat -alias ixiap3 -rxuds3 rxuds3Rate -rxuds4 rxuds4Rate
	puts "rxuds3Rate: $rxuds3Rate"
	puts "rxuds4Rate: $rxuds4Rate"
	send_traffic -alias allport -actiontype stop
	check_result -para1 $::rateCount -para2 $rxuds3Rate -condition > -log "rxuds3Rate=$rxuds3Rate"
    check_result -para1 0 -para2 $rxuds4Rate -condition != -log "rxuds4Rate!=0"
	

    settodefaultconfig	
}

#
#
proc qos_10 {} {
    go s = $::sutSlot l1d
    sets vlan-db vid $::vlanid port $::sutP3 memetag tag
	
	puts "11111111111111111111111111***********************"
	# 11.config device
	go s=$::sutSlot l1p=$::sutP3
	sets port vlan tag mode network
	
	
	go s=$::sutSlot l1p=$::sutP2
	sets port vlan tag mode network
	
    go s=$::sutSlot l1p=$::sutP1
	sets port vlan tag mode network
	sets qos default-priority 2
	
	# 12.config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode none -priority 0
	clear_stat -alias allport
	
	# 13.send frames from port A to port C 
    start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length [expr $::ixiaFrameSize + 4] -srcmac $::ixiaMac1 -dstmac $::ixiaMac3 -framedata frameData
	check_frame -framedata $frameData -vlanid 10 -priority 2
	
	puts "22222222222222222222***********************"
	# 21.config
	go s = $::sutSlot l1d
	sets vlan-db vid 10 fid 0 pri-override enable
	go s=$::sutSlot l1p=$::sutP1
	sets qos priority by-vlan-id enable
	
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 0
	clear_stat -alias allport
	
	# 22.send frames from port A to port C 
	start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length $::ixiaFrameSize -srcmac $::ixiaMac1 -dstmac $::ixiaMac3 -framedata frameData
	check_frame -framedata $frameData -tpid 8100 -vlanid 10 -priority 4
	sets qos priority by-vlan-id disable
	
	puts "33333333333333333333333333***********************"
	# 31.config
	go s=$::sutSlot l1p=$::sutP1
	sets qos priority by-src-mac enable
	
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 0
	clear_stat -alias allport
	
	# 32.send frames from port A to port C 
	start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length $::ixiaFrameSize -srcmac $::ixiaMac1 -dstmac $::ixiaMac3 -framedata frameData
	check_frame -framedata $frameData -tpid 8100 -vlanid 10 -priority 5
	
	sets qos priority by-src-mac disable
	
	puts "44444444444444444444444444444***********************"
	# 41.config
	go s=$::sutSlot l1p=$::sutP1
	sets qos priority by-dst-mac enable
	
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 0
	clear_stat -alias allport
	
	# 42.send frames from port A to port C 
	start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length $::ixiaFrameSize -srcmac $::ixiaMac1 -dstmac $::ixiaMac3 -framedata frameData
    check_frame -framedata $frameData -tpid 8100 -vlanid 10 -priority 6

	sets qos priority by-dst-mac disable
	
	
	puts "5555555555555555555555555555555555***********************"
	# 51.config
	go s=$::sutSlot l1p=$::sutP1
	sets qos priority by-vlan-id enable
	
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 0
	clear_stat -alias allport
	
	# 52.send frames from port A to port C 
	start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length $::ixiaFrameSize -srcmac $::ixiaMac1 -dstmac $::ixiaMac3 -framedata frameData
	check_frame -framedata $frameData -tpid 8100 -vlanid 10 -priority 4
	sets qos priority by-vlan-id disable
	
	
	puts "66666666666666666666666666666***********************"
	# 61.config
	go s=$::sutSlot l1p=$::sutP1
	sets qos priority by-vlan-id enable
	sets qos priority by-src-mac enable
	
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 0
	clear_stat -alias allport
	
	# 62.send frames from port A to port C 
	start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length $::ixiaFrameSize -srcmac $::ixiaMac1 -dstmac $::ixiaMac3 -framedata frameData
    check_frame -framedata $frameData -tpid 8100 -vlanid 10 -priority 5
	
	sets qos priority by-vlan-id disable
	sets qos priority by-src-mac disable
	
	puts "77777777777777777777777777***********************"
	# 71.config
	go s=$::sutSlot l1p=$::sutP1
	sets qos priority by-vlan-id enable
	sets qos priority by-dst-mac enable
	
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 0
	clear_stat -alias allport
	
	# 72.send frames from port A to port C 
	start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length $::ixiaFrameSize -srcmac $::ixiaMac1 -dstmac $::ixiaMac3 -framedata frameData
   check_frame -framedata $frameData -tpid 8100 -vlanid 10 -priority 6

	sets qos priority by-vlan-id disable
	sets qos priority by-dst-mac disable
	
	puts "88888888888888888888888***********************"
	# 81.config
	go s=$::sutSlot l1p=$::sutP1
	sets qos priority by-src-mac enable

	
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 0
	clear_stat -alias allport
	
	# 82.send frames from port A to port C 
	start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length $::ixiaFrameSize -srcmac $::ixiaMac1 -dstmac $::ixiaMac3 -framedata frameData
   check_frame -framedata $frameData -tpid 8100 -vlanid 10 -priority 5

	sets qos priority by-src-mac disable
	
	
	puts "9999999999999999999999999999999***********************"
	# 91.config
	go s=$::sutSlot l1p=$::sutP1
	sets qos priority by-src-mac enable
	sets qos priority by-dst-mac enable
	
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 0
	clear_stat -alias allport
	
	# 92.send frames from port A to port C 
	start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length $::ixiaFrameSize -srcmac $::ixiaMac1 -dstmac $::ixiaMac3 -framedata frameData
    check_frame -framedata $frameData -tpid 8100 -vlanid 10 -priority 6

	sets qos priority by-src-mac disable
	sets qos priority by-dst-mac disable
	
	puts "101010101010101010101010101010***********************"
	# 101.config
	go s=$::sutSlot l1p=$::sutP1
	sets qos priority by-src-mac enable
	sets qos priority by-dst-mac enable
	sets qos priority by-vlan-id enable
	
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100 -priority 0
	clear_stat -alias allport
	
	# 102.send frames from port A to port C 
	start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length $::ixiaFrameSize -srcmac $::ixiaMac1 -dstmac $::ixiaMac3 -framedata frameData
    check_frame -framedata $frameData -tpid 8100 -vlanid 10 -priority 6

	sets qos priority by-src-mac disable
	sets qos priority by-dst-mac disable
	sets qos priority by-vlan-id disable
	
	
	settodefaultconfig
}


# WRR with IP package transmission
#
proc qos_11 {} {

    puts "111111111111111111111***************************"
	# 1.config card
    go s = $::sutSlot l1d
	sets dot1dbridge ip-priority-index 47 remap-priority 0
    sets vlan-db vid $::vlanid port $::sutP3 memetag tag
	
	
	go s=$::sutSlot l1p=$::sutP1
	sets port vlan tag mode network
	sets qos priority tag-type useIP
	
	go s=$::sutSlot l1p=$::sutP2
	sets port vlan tag mode network
	sets qos priority tag-type useIP
	
    go s=$::sutSlot l1p=$::sutP3
	sets port vlan tag mode network
	sets port egress queuingmethod wrr
	
	# 11.config ixia
	config_stream -alias allport -rate 100
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -priority 0 -frametype ethernetii -qosmode dscp -dscpmode custom -dscpvalue 47
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -priority 1 -frametype ethernetii -qosmode dscp -dscpmode custom -dscpvalue 63
	clear_stat -alias allport
	
	# 12config filter
	config_filter -alias ixiap3 -uds3 enable -uds3sa sa1 -sa1addr $::ixiaMac1
	config_filter -alias ixiap3 -uds4 enable -uds4sa sa2 -sa2addr $::ixiaMac2
	
	# 13.send frames from port A,B to port C 
	send_traffic -alias allport -actiontype start
	get_ratestat -alias ixiap3 -rxuds3 rxuds3Rate -rxuds4 rxuds4Rate
	puts "rxuds3Rate: $rxuds3Rate"
	puts "rxuds4Rate: $rxuds4Rate"
	send_traffic -alias allport -actiontype stop
	 
	set receRate [expr $rxuds4Rate * 1.00 / $rxuds3Rate]
	if {($receRate<8.3)&&($receRate>7.7)} { 
		set receRate 8
	}
	
	check_result -para1 8 -para2 $receRate -condition = \
			-log "rxuds3=$rxuds3Rate, rxuds4=$rxuds4Rate, rxuds3/rxuds4: [expr $rxuds4Rate * 1.00 / $rxuds3Rate]"
	
	
	puts "222222222222222222*********************"
    # 21.config ixia
	go s = $::sutSlot l1d
	sets dot1dbridge ip-priority-index 47 remap-priority 1
	config_stream -alias allport -rate 100
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -priority 0 -frametype ethernetii -qosmode dscp -dscpmode custom -dscpvalue 47
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -priority 1 -frametype ethernetii -qosmode dscp -dscpmode custom -dscpvalue 63
	clear_stat -alias allport
	
	# 22config filter
	config_filter -alias ixiap3 -uds3 enable -uds3sa sa1 -sa1addr $::ixiaMac1
	config_filter -alias ixiap3 -uds4 enable -uds4sa sa2 -sa2addr $::ixiaMac2
	
	# 23.send frames from port A,B to port C 
	send_traffic -alias allport -actiontype start
	get_ratestat -alias ixiap3 -rxuds3 rxuds3Rate -rxuds4 rxuds4Rate
	puts "rxuds3Rate: $rxuds3Rate"
	puts "rxuds4Rate: $rxuds4Rate"
	send_traffic -alias allport -actiontype stop
	set receRate [expr $rxuds4Rate * 1.00 / $rxuds3Rate]
	set receRate [expr $rxuds4Rate * 1.00 / $rxuds3Rate]
	if {($receRate<4.3)&&($receRate>3.7)} { 
		set receRate 4
	}
	check_result -para1 4 -para2 $receRate -condition = \
			-log "rxuds3=$rxuds3Rate, rxuds4=$rxuds4Rate, rxuds3/rxuds4: [expr $rxuds4Rate * 1.00 / $rxuds3Rate]"
	
	
	
	puts "333333333333333333333333**************************"
	# 31.config ixia
	go s = $::sutSlot l1d
	sets dot1dbridge ip-priority-index 47 remap-priority 3
	config_stream -alias allport -rate 100
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -priority 0 -frametype ethernetii -qosmode dscp -dscpmode custom -dscpvalue 47
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -priority 1 -frametype ethernetii -qosmode dscp -dscpmode custom -dscpvalue 63
	clear_stat -alias allport
	
	# 32config filter
	config_filter -alias ixiap3 -uds3 enable -uds3sa sa1 -sa1addr $::ixiaMac1
	config_filter -alias ixiap3 -uds4 enable -uds4sa sa2 -sa2addr $::ixiaMac2
	
	# 33.send frames from port A,B to port C 
	send_traffic -alias allport -actiontype start
	get_ratestat -alias ixiap3 -rxuds3 rxuds3Rate -rxuds4 rxuds4Rate
	puts "rxuds3Rate: $rxuds3Rate"
	puts "rxuds4Rate: $rxuds4Rate"
	send_traffic -alias allport -actiontype stop
	set receRate [expr $rxuds4Rate * 1.00 / $rxuds3Rate]
	
	set receRate [expr $rxuds4Rate * 1.00 / $rxuds3Rate]
	if {($receRate<1.3)&&($receRate>0.7)} { 
		set receRate 1
	}
	check_result -para1 1 -para2 $receRate -condition = \
			-log "rxuds3=$rxuds3Rate, rxuds4=$rxuds4Rate, rxuds3/rxuds4: [expr $rxuds4Rate * 1.00 / $rxuds3Rate]"
	
	
	puts "4444444444444444444444444444*********************"
	# 41.config ixia
	go s = $::sutSlot l1d
	sets dot1dbridge ip-priority-index 47 remap-priority 2
	config_stream -alias allport -rate 100
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -priority 0 -frametype ethernetii -qosmode dscp -dscpmode custom -dscpvalue 47
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -priority 1 -frametype ethernetii -qosmode dscp -dscpmode custom -dscpvalue 63
	clear_stat -alias allport
	
	# 42config filter
	config_filter -alias ixiap3 -uds3 enable -uds3sa sa1 -sa1addr $::ixiaMac1
	config_filter -alias ixiap3 -uds4 enable -uds4sa sa2 -sa2addr $::ixiaMac2
	
	# 43.send frames from port A,B to port C 
	send_traffic -alias allport -actiontype start
	get_ratestat -alias ixiap3 -rxuds3 rxuds3Rate -rxuds4 rxuds4Rate
	puts "rxuds3Rate: $rxuds3Rate"
	puts "rxuds4Rate: $rxuds4Rate"
	send_traffic -alias allport -actiontype stop
	set receRate [expr $rxuds4Rate * 1.00 / $rxuds3Rate]
	set receRate [expr $rxuds4Rate * 1.00 / $rxuds3Rate]
	if {($receRate<2.3)&&($receRate>1.7)} { 
		set receRate 2
	}
	check_result -para1 2 -para2 $receRate -condition =  \
			-log "rxuds3=$rxuds3Rate, rxuds4=$rxuds4Rate, rxuds3/rxuds4: [expr $rxuds4Rate * 1.00 / $rxuds3Rate]"
	
	
	go s = $::sutSlot l1d
    sets vlan-db vid $::vlanid port $::sutP3 memetag noMod
	
    go s=$::sutSlot l1p=$::sutP1
	sets qos priority tag-type useIEEE
	
	go s=$::sutSlot l1p=$::sutP2
	sets qos priority tag-type useIEEE
	
    go s=$::sutSlot l1p=$::sutP3
	sets port egress queuingmethod wrr
	# settodefaultconfig
}

#
#SP with IP  package transmission
#pass
proc qos_12 {} {

    # 1.config device
    go s = $::sutSlot l1d
	sets vlan-db vid $::vlanid port $::sutP3 memetag tag
	sets dot1dbridge ip-priority-index 47 remap-priority 0
	
	
	go s=$::sutSlot l1p=$::sutP1
	sets port vlan tag mode network
	sets qos priority tag-type useIP
	
	go s=$::sutSlot l1p=$::sutP2
	sets port vlan tag mode network
	sets qos priority tag-type useIP
	
    go s=$::sutSlot l1p=$::sutP3
	sets port vlan tag mode network
	sets port egress queuingmethod sp
	
	
	
	# 11.config ixia
	go s = $::sutSlot l1d
	sets dot1dbridge ip-priority-index 47 remap-priority 0
	config_stream -alias allport -rate 100
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -priority 0 -frametype ethernetii -qosmode dscp -dscpmode custom -dscpvalue 47
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -priority 1 -frametype ethernetii -qosmode dscp -dscpmode custom -dscpvalue 63
	clear_stat -alias allport
	
	# 12config filter
	config_filter -alias ixiap3 -uds3 enable -uds3sa sa1 -sa1addr $::ixiaMac1
	config_filter -alias ixiap3 -uds4 enable -uds4sa sa2 -sa2addr $::ixiaMac2
	
	# 13.send frames from port A,B to port C 
	send_traffic -alias allport -actiontype start
	get_ratestat -alias ixiap3 -rxuds3 rxuds3Rate -rxuds4 rxuds4Rate
	puts "rxuds3Rate: $rxuds3Rate"
	puts "rxuds4Rate: $rxuds4Rate"
	send_traffic -alias allport -actiontype stop
	check_result -para1 0 -para2 $rxuds4Rate -condition != -log "rxuds4:$rxuds4Rate!=0"
	
	
    # 21.config ixia
	go s = $::sutSlot l1d
	sets dot1dbridge ip-priority-index 47 remap-priority 1
	config_stream -alias allport -rate 100
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -priority 0 -frametype ethernetii -qosmode dscp -dscpmode custom -dscpvalue 47
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -priority 1 -frametype ethernetii -qosmode dscp -dscpmode custom -dscpvalue 63
	clear_stat -alias allport
	
	# 22config filter
	config_filter -alias ixiap3 -uds3 enable -uds3sa sa1 -sa1addr $::ixiaMac1
	config_filter -alias ixiap3 -uds4 enable -uds4sa sa2 -sa2addr $::ixiaMac2
	
	# 23.send frames from port A,B to port C 
	send_traffic -alias allport -actiontype start
	get_ratestat -alias ixiap3 -rxuds3 rxuds3Rate -rxuds4 rxuds4Rate
	puts "rxuds3Rate: $rxuds3Rate"
	puts "rxuds4Rate: $rxuds4Rate"
	send_traffic -alias allport -actiontype stop
	check_result -para1 0 -para2 $rxuds4Rate -condition != -log "rxuds4:$rxuds4Rate!=0"
	
	
	
	# 31.config ixia
	go s = $::sutSlot l1d
	sets dot1dbridge ip-priority-index 47 remap-priority 3
	config_stream -alias allport -rate 100
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -priority 0 -frametype ethernetii -qosmode dscp -dscpmode custom -dscpvalue 47
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -priority 1 -frametype ethernetii -qosmode dscp -dscpmode custom -dscpvalue 63
	clear_stat -alias allport
	
	# 32config filter
	config_filter -alias ixiap3 -uds3 enable -uds3sa sa1 -sa1addr $::ixiaMac1
	config_filter -alias ixiap3 -uds4 enable -uds4sa sa2 -sa2addr $::ixiaMac2
	
	# 33.send frames from port A,B to port C 
	send_traffic -alias allport -actiontype start
	get_ratestat -alias ixiap3 -rxuds3 rxuds3Rate -rxuds4 rxuds4Rate
	puts "rxuds3Rate: $rxuds3Rate"
	puts "rxuds4Rate: $rxuds4Rate"
	send_traffic -alias allport -actiontype stop
	set receRate [expr $rxuds4Rate * 1.00 / $rxuds3Rate]
	check_result -para1 1 -para2 $receRate -condition != -percentage $::ratePercentage \
	        -log "rxuds3=$rxuds3Rate, rxuds4=$rxuds4Rate, rxuds4/rxuds3: [expr $rxuds4Rate  / $rxuds3Rate]"
	
	
	
	# 41.config ixia
	go s = $::sutSlot l1d
	sets dot1dbridge ip-priority-index 47 remap-priority 2
	config_stream -alias allport -rate 100
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -priority 0 -frametype ethernetii -qosmode dscp -dscpmode custom -dscpvalue 47
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -priority 1 -frametype ethernetii -qosmode dscp -dscpmode custom -dscpvalue 63
	clear_stat -alias allport
	
	# 42config filter
	config_filter -alias ixiap3 -uds3 enable -uds3sa sa1 -sa1addr $::ixiaMac1
	config_filter -alias ixiap3 -uds4 enable -uds4sa sa2 -sa2addr $::ixiaMac2
	
	# 43.send frames from port A,B to port C 
	send_traffic -alias allport -actiontype start
	get_ratestat -alias ixiap3 -rxuds3 rxuds3Rate -rxuds4 rxuds4Rate
	puts "rxuds3Rate: $rxuds3Rate"
	puts "rxuds4Rate: $rxuds4Rate"
	send_traffic -alias allport -actiontype stop
	check_result -para1 0 -para2 $rxuds4Rate -condition != -log "rxuds4:$rxuds4Rate!=0"
	
	
	
	
	go s = $::sutSlot l1d
	sets vlan-db vid $::vlanid port $::sutP3 memetag noMod
	
	go s=$::sutSlot l1p=$::sutP1
	sets qos priority tag-type useIEEE
	
	go s=$::sutSlot l1p=$::sutP2
	sets qos priority tag-type useIEEE
	
    go s=$::sutSlot l1p=$::sutP3
	sets port egress queuingmethod wrr
	settodefaultconfig
}
proc settodefaultconfig {} {
	global tcLogId
	uController -printlog yes
	go s=$::sutSlot l1d
	# remove vlan all -printlog no
	remove vlan-db vid 10
	sets dot1dbridge ip-priority-index 47 remap-priority 2
	
	go s=$::sutSlot l1p=$::sutP1 
	sets port vlan tag mode customer 
	sets port default-vid 1 
	sets port discard-untagged false
	sets port discard-tagged false 
	sets port force-default-vid false 
	sets qos default-priority 0 
	sets qos priority by-vlan-id disable
	sets qos priority by-src-mac disable
	sets qos priority by-dst-mac disable
	
	go s=$::sutSlot l1p=$::sutP2
	sets port vlan tag mode customer
	sets port default-vid 1 
	sets port discard-untagged false 
	sets port discard-tagged false 
	sets port force-default-vid false 
	sets qos priority by-vlan-id disable 
	sets qos priority by-src-mac disable 
	sets qos priority by-dst-mac disable 
	
	
	go s=$::sutSlot l1p=$::sutP3 
	sets qos default-priority 0 
	sets qos priority by-vlan-id disable 
	sets qos priority by-src-mac disable 
	sets qos priority by-dst-mac disable 
	sets port vlan tag mode customer
	
	uController -printlog yes
	printlog -fileid $tcLogId -res conf -cmd "set all qos related parameters to default value"
}
