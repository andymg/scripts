# Summary: this is a VLAN test suit for ION platform
# Topology: ixiap1 <-> sutP1 -- sutP2 <-> ixiap2
# DUT: x322x, x323x, x222x
# Owner: Mark Wang
# Date: 2011-5-17
# version: 1.0.0
# Scope: 1-10,13
#
#pass
proc vlan_1 {} {
	login -ipaddr $::sutIpAddr -sutname sut1
	settodefaultconfig
	connect_ixia -ipaddr $::ixiaIpAddr -portlist $::ixiaPort1,ixiap1,$::ixiaPort2,ixiap2 -alias allport
	config_portprop -alias ixiap1 -phymode copper
	config_portprop -alias ixiap2 -phymode copper
	config_frame -alias ixiap1 -srcmac $::ixiaMac1 -dstmac $::ixiaMac2 -framesize $::ixiaFrameSize
	config_frame -alias ixiap2 -srcmac $::ixiaMac2 -dstmac $::ixiaMac1 -framesize $::ixiaFrameSize
	config_stream -alias allport -rate $::ixiaSendRate
	
	go s=$::sutSlot l1p=$::sutP1
	sets loam admin state disable
	sets tndp tx state disable

	go s=$::sutSlot l1p=$::sutP2
	sets ether phymode=phySGMII
	sets loam admin state disable
	sets tndp tx state disable
	
	
	go s=$::sutSlot l1p=$::sutP3
	sets ether phymode=phySGMII
	sets loam admin state disable
	sets tndp tx state disable
}
#
#pass
proc vlan_2 {} {
	
	go s = $::sutSlot l1d
	
	# check vlan table
	show vlan-db config -vid 1 -fid 0 -priority 0 -override disable -port$::sutP1 noMod -port$::sutP2 noMod
	uController -expres fail
	sets vlan-db vid 1 fid 0 priority 1
	sets vlan-db vid 1 fid 0 pri-override enable
	sets vlan-db vid 1 port $::sutP1 memetag tag
	sets vlan-db vid 1 port $::sutP2 memetag notMember
	add vlan-db vid 1
	add vlan-db vid 4095
	uController -expres pass
	add vlan-db vid 2
	add vlan-db vid 4094
	remove vlan-db vid 2
	remove vlan-db vid 4094
	
	#check port fwd list ??
	go l1p = $::sutP1
	show fwd portlist -portlist 2
	go l1p = $::sutP2
	show fwd portlist -portlist 1
	
	# #check vlan forwarding rules
	go s=$::sutSlot l1p=$::sutP1
	show port vlan config -state vlanDisabled -tag false -untag false -defid 1 -forceid false
	show port vlan tag config -mode customer
	go s=$::sutSlot l1p=$::sutP2
	show port vlan config -state vlanDisabled -tag false -untag false -defid 1 -forceid false
	show port vlan tag config -mode customer
	
	# reset all vlan parameters to factory default value	successful
	settodefaultconfig
	
}

#
#pass
proc vlan_3 {} {
	# 1. config sut
	go s=$::sutSlot l1d
	add vlan-db vid $::vlanid
	sets vlan-db vid $::vlanid port $::sutP1 memetag unTag
	sets vlan-db vid $::vlanid port $::sutP2 memetag tag
	go s=$::sutSlot l1p=$::sutP1
	sets port vlan tag mode network
	sets port default-vid $::vlanid
	go s=$::sutSlot l1p=$::sutP2
	sets port vlan tag mode network
	sets port default-vid $::vlanid
	
	# 2. config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100
	clear_stat -alias allport
	
	# 3. send frame from ixia port1 time=1s, then check ixia p2 received frame	ixia p1_tx=ixia p2_rx, frame length=104, vid=10
	start_capture -alias ixiap2
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap2 -length [expr $::ixiaFrameSize + 4] -srcmac $::ixiaMac1 -dstmac $::ixiaMac2 -framedata frameData
	get_stat -alias ixiap1 -txframe ixiap1tx
	get_stat -alias ixiap2 -rxframe ixiap2rx
	check_result -para1 $ixiap1tx -para2 $ixiap2rx -condition = -log "ixiap1_tx_frame: $ixiap1tx, ixiap2_rx_frame: $ixiap2rx"
	check_frame -framedata $frameData -tpid 8100 -vlanid 10
	
	# 4. send frame from ixia port2 time=1s, then check ixia p1 received frame
	# ixia p2_tx=ixia p1_rx, frame length=96, no vid existed
	start_capture -alias ixiap1
	send_traffic -alias ixiap2 -actiontype start -time 1
	stop_capture -alias ixiap1 -length [expr $::ixiaFrameSize - 4] -srcmac $::ixiaMac2 -dstmac $::ixiaMac1 -framedata frameData
	get_stat -alias ixiap2 -txframe ixiap2tx
	get_stat -alias ixiap1 -rxframe ixiap1rx
	check_result -para1 $ixiap2tx -para2 $ixiap1rx -condition = -log "ixiap2_tx_frame: $ixiap2tx, ixiap1_rx_frame: $ixiap1rx"
	
	# 5. reset all vlan parameters to factory default value	successful
	settodefaultconfig
	
}
#
#
proc vlan_4 {} {
	# 1.config sut
	go s=$::sutSlot l1d
	add vlan-db vid $::vlanid
	sets vlan-db vid $::vlanid port $::sutP1 memetag noMod
	sets vlan-db vid $::vlanid port $::sutP2 memetag noMod

	go s=$::sutSlot l1p=$::sutP1 
	sets port vlan tag mode customer
	sets port default-vid $::vlanid

	go s=$::sutSlot l1p=$::sutP2
	sets port vlan tag mode provider
	sets port vlan tag provider ethtype x88a8
	sets port default-vid $::vlanid

	#2.config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -tpid 88a8
	clear_stat -alias allport


	#3. send frame from ixia port1 time=1s, then check ixia p2 received frame
	start_capture -alias ixiap2
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap2 -length [expr $::ixiaFrameSize + 4] -srcmac $::ixiaMac1 -dstmac $::ixiaMac2 -framedata frameData
	get_stat -alias ixiap1 -txframe ixiap1tx
	get_stat -alias ixiap2 -rxframe ixiap2rx
	check_result -para1 $ixiap1tx -para2 $ixiap2rx -condition = -log "ixiap1_tx_frame: $ixiap1tx, ixiap2_rx_frame: $ixiap2rx"
	check_frame -framedata $frameData -tpid 88a8 -vlanid 10


	#4.send frame from ixia port2 time=1s, then check ixia p1 received frame
	start_capture -alias ixiap1
	send_traffic -alias ixiap2 -actiontype start -time 1
	stop_capture -alias ixiap1 -length [expr $::ixiaFrameSize - 4] -srcmac $::ixiaMac2 -dstmac $::ixiaMac1 -framedata frameData
	get_stat -alias ixiap2 -txframe ixiap2tx
	get_stat -alias ixiap1 -rxframe ixiap1rx
	check_result -para1 $ixiap2tx -para2 $ixiap1rx -condition = -log "ixiap2_tx_frame: $ixiap2tx, ixiap1_rx_frame: $ixiap1rx"

	#5.reset all vlan parameters to factory default value
	settodefaultconfig

	# 6.config sut
	go s=$::sutSlot l1d
	add vlan-db vid $::vlanid
	sets vlan-db vid $::vlanid port $::sutP1 memetag noMod
	sets vlan-db vid $::vlanid port $::sutP2 memetag noMod

	go s=$::sutSlot l1p=$::sutP1 
	sets port vlan tag mode customer
	sets port default-vid $::vlanid

	go s=$::sutSlot l1p=$::sutP2
	sets port vlan tag mode provider
	sets port vlan tag provider ethtype x9100
	sets port default-vid $::vlanid

	#7.config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -tpid 88a8
	clear_stat -alias allport

	#8. send frame from ixia port1 time=1s, then check ixia p2 received frame
	start_capture -alias ixiap2
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap2 -length [expr $::ixiaFrameSize + 4] -srcmac $::ixiaMac1 -dstmac $::ixiaMac2 -framedata frameData
	get_stat -alias ixiap1 -txframe ixiap1tx
	get_stat -alias ixiap2 -rxframe ixiap2rx
	check_result -para1 $ixiap1tx -para2 $ixiap2rx -condition = -log "ixiap1_tx_frame: $ixiap1tx, ixiap2_rx_frame: $ixiap2rx"
	check_frame -framedata $frameData -tpid 9100 -vlanid 10


	#9.send frame from ixia port2 time=1s, then check ixia p1 received frame
	start_capture -alias ixiap1
	send_traffic -alias ixiap2 -actiontype start -time 1
	stop_capture -alias ixiap1 -length $::ixiaFrameSize  -srcmac $::ixiaMac2 -dstmac $::ixiaMac1 -framedata frameData
	get_stat -alias ixiap2 -txframe ixiap2tx
	get_stat -alias ixiap1 -rxframe ixiap1rx
	check_result -para1 $ixiap2tx -para2 $ixiap1rx -condition = -log "ixiap2_tx_frame: $ixiap2tx, ixiap1_rx_frame: $ixiap1rx"

	#10.reset all vlan parameters to factory default value
	settodefaultconfig
}
#
#pass
proc vlan_5 {} {
	# 1.config sut
	go s=$::sutSlot l1d
	add vlan-db vid $::vlanid
	sets vlan-db vid $::vlanid port $::sutP1 memetag noMod
	sets vlan-db vid $::vlanid port $::sutP2 memetag noMod

	go s=$::sutSlot l1p=$::sutP1 
	sets port vlan tag mode network
	sets port default-vid $::vlanid

	go s=$::sutSlot l1p=$::sutP2
	sets port vlan tag mode network
	sets port default-vid $::vlanid

	#2.config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100
	clear_stat -alias allport


	#3. send frame from ixia port1 time=1s, then check ixia p2 received frame
	start_capture -alias ixiap2
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap2 -length $::ixiaFrameSize -srcmac $::ixiaMac1 -dstmac $::ixiaMac2 -framedata frameData
	get_stat -alias ixiap1 -txframe ixiap1tx
	get_stat -alias ixiap2 -rxframe ixiap2rx
	check_result -para1 $ixiap1tx -para2 $ixiap2rx -condition = -log "ixiap1_tx_frame: $ixiap1tx, ixiap2_rx_frame: $ixiap2rx"
	check_frame -framedata $frameData -tpid 8100 -vlanid 10


	# #4.send frame from ixia port2 time=1s, then check ixia p1 received frame
	start_capture -alias ixiap1
	send_traffic -alias ixiap2 -actiontype start -time 1
	stop_capture -alias ixiap1 -length $::ixiaFrameSize -srcmac $::ixiaMac2 -dstmac $::ixiaMac1 -framedata frameData
	get_stat -alias ixiap2 -txframe ixiap2tx
	get_stat -alias ixiap1 -rxframe ixiap1rx
	check_result -para1 $ixiap2tx -para2 $ixiap1rx -condition = -log "ixiap2_tx_frame: $ixiap2tx, ixiap1_rx_frame: $ixiap1rx"
	check_frame -framedata $frameData -tpid 8100 -vlanid 10

	#5.reset all vlan parameters to factory default value
	settodefaultconfig

	# 6.config sut
	go s=$::sutSlot l1d
	go s=$::sutSlot l1p=$::sutP1 
	sets port vlan tag mode customer
	go s=$::sutSlot l1p=$::sutP2
	sets port vlan tag mode customer

	# #7.config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100
	clear_stat -alias allport

	#8. send frame from ixia port1 time=1s, then check ixia p2 received frame
	start_capture -alias ixiap2
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap2 -length $::ixiaFrameSize -srcmac $::ixiaMac1 -dstmac $::ixiaMac2 -framedata frameData
	get_stat -alias ixiap1 -txframe ixiap1tx
	get_stat -alias ixiap2 -rxframe ixiap2rx
	check_result -para1 $ixiap1tx -para2 $ixiap2rx -condition = -log "ixiap1_tx_frame: $ixiap1tx, ixiap2_rx_frame: $ixiap2rx"
	check_frame -framedata $frameData -tpid 8100 -vlanid 10


	#9.send frame from ixia port2 time=1s, then check ixia p1 received frame
	start_capture -alias ixiap1
	send_traffic -alias ixiap2 -actiontype start -time 1
	stop_capture -alias ixiap1 -length $::ixiaFrameSize -srcmac $::ixiaMac2 -dstmac $::ixiaMac1 -framedata frameData
	get_stat -alias ixiap2 -txframe ixiap2tx
	get_stat -alias ixiap1 -rxframe ixiap1rx
	check_result -para1 $ixiap2tx -para2 $ixiap1rx -condition = -log "ixiap2_tx_frame: $ixiap2tx, ixiap1_rx_frame: $ixiap1rx"
	check_frame -framedata $frameData -tpid 8100 -vlanid 10

	#10.reset all vlan parameters to factory default value
	settodefaultconfig
}

#
#pass
proc vlan_6 {} {
	# 1.config sut
	go s=$::sutSlot l1d
	add vlan-db vid $::vlanid
	sets vlan-db vid $::vlanid port $::sutP1 memetag noMod
	sets vlan-db vid $::vlanid port $::sutP2 memetag noMod

	go s=$::sutSlot l1p=$::sutP1 
	sets port vlan tag mode provider
	sets port vlan tag provider ethtype x8100
	sets port default-vid $::vlanid

	go s=$::sutSlot l1p=$::sutP2
	sets port vlan tag mode provider
	sets port vlan tag provider ethtype x88a8
	sets port default-vid $::vlanid

	#2.config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -tpid 88a8
	clear_stat -alias allport


	#3. send frame from ixia port1 time=1s, then check ixia p2 received frame
	start_capture -alias ixiap2
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap2 -length $::ixiaFrameSize -srcmac $::ixiaMac1 -dstmac $::ixiaMac2 -framedata frameData
	get_stat -alias ixiap1 -txframe ixiap1tx
	get_stat -alias ixiap2 -rxframe ixiap2rx
	check_result -para1 $ixiap1tx -para2 $ixiap2rx -condition = -log "ixiap1_tx_frame: $ixiap1tx, ixiap2_rx_frame: $ixiap2rx"
	check_frame -framedata $frameData -tpid 88a8 -vlanid 10


	#4.send frame from ixia port2 time=1s, then check ixia p1 received frame
	start_capture -alias ixiap1
	send_traffic -alias ixiap2 -actiontype start -time 1
	stop_capture -alias ixiap1 -length [expr $::ixiaFrameSize + 0] -srcmac $::ixiaMac2 -dstmac $::ixiaMac1 -framedata frameData
	get_stat -alias ixiap2 -txframe ixiap2tx
	get_stat -alias ixiap1 -rxframe ixiap1rx
	check_result -para1 $ixiap2tx -para2 $ixiap1rx -condition = -log "ixiap2_tx_frame: $ixiap2tx, ixiap1_rx_frame: $ixiap1rx"
	check_frame -framedata $frameData -tpid 8100 -vlanid 10

	#5.reset all vlan parameters to factory default value
	settodefaultconfig

	# 6.config sut
	go s=$::sutSlot l1d
	add vlan-db vid $::vlanid
	sets vlan-db vid $::vlanid port $::sutP1 memetag noMod
	sets vlan-db vid $::vlanid port $::sutP2 memetag noMod

	go s=$::sutSlot l1p=$::sutP1 
	sets port vlan tag mode provider
	sets port vlan tag provider ethtype x8100
	sets port default-vid $::vlanid

	go s=$::sutSlot l1p=$::sutP2
	sets port vlan tag mode provider
	sets port vlan tag provider ethtype x9100
	sets port default-vid $::vlanid

	#7.config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -tpid 9100
	clear_stat -alias allport

	#8. send frame from ixia port1 time=1s, then check ixia p2 received frame
	start_capture -alias ixiap2
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap2 -length $::ixiaFrameSize -srcmac $::ixiaMac1 -dstmac $::ixiaMac2 -framedata frameData
	get_stat -alias ixiap1 -txframe ixiap1tx
	get_stat -alias ixiap2 -rxframe ixiap2rx
	check_result -para1 $ixiap1tx -para2 $ixiap2rx -condition = -log "ixiap1_tx_frame: $ixiap1tx, ixiap2_rx_frame: $ixiap2rx"
	check_frame -framedata $frameData -tpid 9100 -vlanid 10


	#9.send frame from ixia port2 time=1s, then check ixia p1 received frame
	start_capture -alias ixiap1
	send_traffic -alias ixiap2 -actiontype start -time 1
	stop_capture -alias ixiap1 -length $::ixiaFrameSize -srcmac $::ixiaMac2 -dstmac $::ixiaMac1 -framedata frameData
	get_stat -alias ixiap2 -txframe ixiap2tx
	get_stat -alias ixiap1 -rxframe ixiap1rx
	check_result -para1 $ixiap2tx -para2 $ixiap1rx -condition = -log "ixiap2_tx_frame: $ixiap2tx, ixiap1_rx_frame: $ixiap1rx"
	check_frame -framedata $frameData -tpid 8100 -vlanid 10

	#10.reset all vlan parameters to factory default value
	settodefaultconfig
}
#
#pass
proc vlan_7 {} {
	# 1.config sut
	go s=$::sutSlot l1d
	add vlan-db vid $::vlanid
	sets vlan-db vid $::vlanid port $::sutP1 memetag noMod
	sets vlan-db vid $::vlanid port $::sutP2 memetag noMod

	go s=$::sutSlot l1p=$::sutP1 
	sets port vlan tag mode customer
	sets port default-vid $::vlanid

	go s=$::sutSlot l1p=$::sutP2
	sets port vlan tag mode provider
	sets port vlan tag provider ethtype x88a8
	sets port default-vid $::vlanid

	#2.config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -tpid 88a8
	clear_stat -alias allport


	#3. send frame from ixia port1 time=1s, then check ixia p2 received frame
	start_capture -alias ixiap2
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap2 -length [expr $::ixiaFrameSize + 4] -srcmac $::ixiaMac1 -dstmac $::ixiaMac2 -framedata frameData
	get_stat -alias ixiap1 -txframe ixiap1tx
	get_stat -alias ixiap2 -rxframe ixiap2rx
	check_result -para1 $ixiap1tx -para2 $ixiap2rx -condition = -log "ixiap1_tx_frame: $ixiap1tx, ixiap2_rx_frame: $ixiap2rx"
	check_frame -framedata $frameData -tpid 88a8 -vlanid 10


	# 4.send frame from ixia port2 time=1s, then check ixia p1 received frame
	start_capture -alias ixiap1
	send_traffic -alias ixiap2 -actiontype start -time 1
	stop_capture -alias ixiap1 -length [expr $::ixiaFrameSize - 4] -srcmac $::ixiaMac2 -dstmac $::ixiaMac1 -framedata frameData
	get_stat -alias ixiap2 -txframe ixiap2tx
	get_stat -alias ixiap1 -rxframe ixiap1rx
	check_result -para1 $ixiap2tx -para2 $ixiap1rx -condition = -log "ixiap2_tx_frame: $ixiap2tx, ixiap1_rx_frame: $ixiap1rx"
	

	#5.reset all vlan parameters to factory default value
	settodefaultconfig

	# 6.config sut
	go s=$::sutSlot l1d
	add vlan-db vid $::vlanid
	sets vlan-db vid $::vlanid port $::sutP1 memetag noMod
	sets vlan-db vid $::vlanid port $::sutP2 memetag noMod

	go s=$::sutSlot l1p=$::sutP1 
	sets port vlan tag mode customer
	sets port default-vid $::vlanid

	go s=$::sutSlot l1p=$::sutP2
	sets port vlan tag mode provider
	sets port vlan tag provider ethtype x9100
	sets port default-vid $::vlanid

	#7.config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100
	config_frame -alias ixiap2 -vlanmode singlevlan -vlanid $::vlanid -tpid 9100
	clear_stat -alias allport

	#8. send frame from ixia port1 time=1s, then check ixia p2 received frame
	start_capture -alias ixiap2
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap2 -length [expr $::ixiaFrameSize + 4] -srcmac $::ixiaMac1 -dstmac $::ixiaMac2 -framedata frameData
	get_stat -alias ixiap1 -txframe ixiap1tx
	get_stat -alias ixiap2 -rxframe ixiap2rx
	check_result -para1 $ixiap1tx -para2 $ixiap2rx -condition = -log "ixiap1_tx_frame: $ixiap1tx, ixiap2_rx_frame: $ixiap2rx"
	check_frame -framedata $frameData -tpid 9100 -vlanid 10


	#9.send frame from ixia port2 time=1s, then check ixia p1 received frame
	start_capture -alias ixiap1
	send_traffic -alias ixiap2 -actiontype start -time 1
	stop_capture -alias ixiap1 -length [expr $::ixiaFrameSize - 4] -srcmac $::ixiaMac2 -dstmac $::ixiaMac1 -framedata frameData
	get_stat -alias ixiap2 -txframe ixiap2tx
	get_stat -alias ixiap1 -rxframe ixiap1rx
	check_result -para1 $ixiap2tx -para2 $ixiap1rx -condition = -log "ixiap2_tx_frame: $ixiap2tx, ixiap1_rx_frame: $ixiap1rx"
   
	
	#10.reset all vlan parameters to factory default value
	settodefaultconfig
	
	}
#
#pass
proc vlan_8 {} {
	# 1.config sut
	go s=$::sutSlot l1d
	add vlan-db vid 100
	sets vlan-db vid 100 port $::sutP1 memetag noMod
	sets vlan-db vid 100 port $::sutP2 memetag tag

	go s=$::sutSlot l1p=$::sutP1 
	sets port vlan tag mode network
	sets port default-vid 100

	go s=$::sutSlot l1p=$::sutP2
	sets port vlan tag mode network

	# 2.config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode none
    clear_stat -alias allport

	# 3.send frame from ixia port1, then check ixia port2 received frame
	start_capture -alias ixiap2
	send_traffic -alias ixiap1 -actiontype  start -time 1
	stop_capture -alias ixiap2 -length [expr $::ixiaFrameSize + 4] -srcmac $::ixiaMac1 -dstmac $::ixiaMac2 -framedata frameData
	get_stat -alias ixiap1 -txframe ixiap1tx
	get_stat -alias ixiap2 -rxframe ixiap2rx
	check_result -para1 $ixiap1tx -para2 $ixiap2rx -condition = -log "ixiap1_tx_frame: $ixiap1tx, ixiap2_rx_frame: $ixiap2rx"
	
	# 4.config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid 100 -tpid 8100
	clear_stat -alias allport

	# 5.send frame from ixia port1, then check ixia port2 received frame
	start_capture -alias ixiap2
	send_traffic -alias ixiap1 -actiontype  start -time 1
	stop_capture -alias ixiap2 -length $::ixiaFrameSize  -srcmac $::ixiaMac1 -dstmac $::ixiaMac2 -framedata frameData
	get_stat -alias ixiap1 -txframe ixiap1tx
	get_stat -alias ixiap2 -rxframe ixiap2rx
	check_result -para1 $ixiap1tx -para2 $ixiap2rx -condition = -log "ixiap1_tx_frame: $ixiap1tx, ixiap2_rx_frame: $ixiap2rx"
	check_frame -framedata $frameData -tpid 8100 -vlanid 100
	
	
	# 5.config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid 200 -tpid 8100
	clear_stat -alias allport

	# 6.send frame from ixia port1, then check ixia port2 received frame
	send_traffic -alias ixiap1 -actiontype  start -time 1
	get_stat -alias ixiap1 -txframe ixiap1tx
	get_stat -alias ixiap2 -rxframe ixiap2rx
	check_result -para1 0 -para2 $ixiap2rx -condition = -log "ixiap2_rx_frame: $ixiap2rx=0"
   
   # 7.reset all vlan parameters to factory default value
	settodefaultconfig
}
#
#pass
proc vlan_9 {} {
	# 1.config sut
	go s=$::sutSlot l1d
	add vlan-db vid 1000
	sets vlan-db vid 1000 port $::sutP1 memetag noMod
	sets vlan-db vid 1000 port $::sutP2 memetag noMod
	
	add vlan-db vid 2000
	sets vlan-db vid 2000 port $::sutP1 memetag noMod
	sets vlan-db vid 2000 port $::sutP2 memetag noMod
	
	add vlan-db vid 4094
	sets vlan-db vid 4094 port $::sutP1 memetag noMod
	sets vlan-db vid 4094 port $::sutP2 memetag noMod
	
	go s=$::sutSlot l1p=$::sutP1
	sets port vlan tag mode network
	sets port discard-untagged true
	
	go s=$::sutSlot l1p=$::sutP2
	sets port vlan tag mode network
	
	# 2.config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode none
	clear_stat -alias allport
	
	# 3.send frame from ixia port1 time=1s, then check ixia p2 received frame
	send_traffic -alias ixiap1 -actiontype  start -time 1
	get_stat -alias ixiap1 -txframe ixiap1tx
	get_stat -alias ixiap2 -rxframe ixiap2rx
	check_result -para1 0 -para2 $ixiap2rx -condition = -log "ixiap1_tx_frame: $ixiap1tx, ixiap2_rx_frame: $ixiap2rx"
   
	# 4.config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid 1000 -tpid 8100
	clear_stat -alias allport
	
	# 5.send frame from ixia port1 time=1s, then check ixia p2 received frame
	start_capture -alias ixiap2
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap2 -length 100 -srcmac $::ixiaMac1 -dstmac $::ixiaMac2 -framedata frameData
	get_stat -alias ixiap1 -txframe ixiap1tx
	get_stat -alias ixiap2 -rxframe ixiap2rx
	check_result -para1 $ixiap1tx -para2 $ixiap2rx -condition = -log "ixiap1_tx_frame: $ixiap1tx, ixiap2_rx_frame: $ixiap2rx"
	check_frame -framedata $frameData -tpid 8100 -vlanid 1000
	
	# 6.config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid 2000 -tpid 8100
	clear_stat -alias allport
	
	# 7.send frame from ixia port1 time=1s, then check ixia p2 received frame
	start_capture -alias ixiap2
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap2 -length 100 -srcmac $::ixiaMac1 -dstmac $::ixiaMac2 -framedata frameData
	get_stat -alias ixiap1 -txframe ixiap1tx
	get_stat -alias ixiap2 -rxframe ixiap2rx
	check_result -para1 $ixiap1tx -para2 $ixiap2rx -condition = -log "ixiap1_tx_frame: $ixiap1tx, ixiap2_rx_frame: $ixiap2rx"
	check_frame -framedata $frameData -tpid 8100 -vlanid 2000
	
	# 8.config ixia
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid 4094 -tpid 8100
	clear_stat -alias allport
	
	# 9.send frame from ixia port1 time=1s, then check ixia p2 received frame
	start_capture -alias ixiap2
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap2 -length 100 -srcmac $::ixiaMac1 -dstmac $::ixiaMac2 -framedata frameData
	get_stat -alias ixiap1 -txframe ixiap1tx
	get_stat -alias ixiap2 -rxframe ixiap2rx
	check_result -para1 $ixiap1tx -para2 $ixiap2rx -condition = -log "ixiap1_tx_frame: $ixiap1tx, ixiap2_rx_frame: $ixiap2rx"
	check_frame -framedata $frameData -tpid 8100 -vlanid 4094
	
	# 10.config ixia
	go s=$::sutSlot l1d
	remove vlan-db vid 2000
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid 2000 -tpid 8100
	clear_stat -alias allport
	
	# 11.send frame from ixia port1 time=1s, then check ixia p2 received frame
	send_traffic -alias ixiap1 -actiontype  start -time 1
	get_stat -alias ixiap1 -txframe ixiap1tx
	get_stat -alias ixiap2 -rxframe ixiap2rx
	check_result -para1 0 -para2 $ixiap2rx -condition = -log "ixiap1_tx_frame: $ixiap1tx, ixiap2_rx_frame: $ixiap2rx"
   
	
	# 12.reset all vlan parameters to factory default value
	remove vlan-db vid 1000
	settodefaultconfig
}

#
#pass
proc vlan_10 {} {
# 1.config sut
	go s=$::sutSlot l1d
	add vlan-db vid 100
	sets vlan-db vid 100 port $::sutP1 memetag noMod
	sets vlan-db vid 100 port $::sutP2 memetag tag
	
	add vlan-db vid 200
	sets vlan-db vid 200 port $::sutP1 memetag noMod
	sets vlan-db vid 200 port $::sutP2 memetag tag
	
	go s=$::sutSlot l1p=$::sutP1
	sets port vlan tag mode network
	sets port default-vid 100
	
	go s=$::sutSlot l1p=$::sutP2
	sets port vlan tag mode network
	
	# 2.config ixia
	
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode none
	clear_stat -alias allport
	
	# 3.send frame from ixia port1 time=1s, then check ixia p2 received frame
	start_capture -alias ixiap2
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap2  -length [expr $::ixiaFrameSize + 4] -srcmac $::ixiaMac1 -dstmac $::ixiaMac2 -framedata frameData
	get_stat -alias ixiap1 -txframe ixiap1tx
	get_stat -alias ixiap2 -rxframe ixiap2rx
	check_result -para1 $ixiap1tx -para2 $ixiap2rx -condition = -log "ixiap1_tx_frame: $ixiap1tx, ixiap2_rx_frame: $ixiap2rx"

    # 8.reset all vlan parameters to factory default value
	settodefaultconfig	
}
#
#pass
proc vlan_13 {} {
    # 1.config sut
	go s=$::sutSlot l1d
	add vlan-db vid $::vlanid
	sets vlan-db vid $::vlanid port $::sutP1 memetag noMod
	sets vlan-db vid $::vlanid port $::sutP2 memetag noMod

	go s=$::sutSlot l1p=$::sutP1 
	sets port vlan tag mode customer
	sets port default-vid $::vlanid
    sets fwd  portlist $::sutP2 
	
	go s=$::sutSlot l1p=$::sutP2
	sets port vlan tag mode customer
	sets port default-vid $::vlanid
	
	# 2.config
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode singlevlan -vlanid $::vlanid -tpid 8100
	clear_stat -alias allport
	
	# 3.send frame from ixia port1 time=1s, then check ixia p2 received frame
	start_capture -alias ixiap2
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap2 -length 100 -srcmac $::ixiaMac1 -dstmac $::ixiaMac2 -framedata frameData
	get_stat -alias ixiap1 -txframe ixiap1tx
	get_stat -alias ixiap2 -rxframe ixiap2rx
	check_result -para1 $ixiap1tx -para2 $ixiap2rx -condition = -log "ixiap1_tx_frame: $ixiap1tx, ixiap2_rx_frame: $ixiap2rx"
	check_frame -framedata $frameData -tpid 8100 -vlanid $::vlanid
	
    # 4.config ixia
	go s=$::sutSlot l1p=$::sutP1 
	sets fwd  portlist $::sutP1
	config_stream -alias allport -rate 1
	clear_stat -alias allport
	
	# 5.send frame from ixia port1 time=1s, then check ixia p2 received frame
	send_traffic -alias ixiap1 -actiontype  start -time 1
	get_stat -alias ixiap1 -txframe ixiap1tx
	get_stat -alias ixiap2 -rxframe ixiap2rx
	check_result -para1 0 -para2 $ixiap2rx -condition = -log "ixiap1_tx_frame: $ixiap1tx, ixiap2_rx_frame: $ixiap2rx"
   
	# 6. reset all vlan parameters to factory default value	successful
	settodefaultconfig
	
	go s=$::sutSlot l1p=$::sutP1 
	sets fwd  portlist $::sutP2
}

proc settodefaultconfig {} {
	global tcLogId
	uController -printlog no
	go s=$::sutSlot l1d
	remove vlan all
	go s=$::sutSlot l1p=$::sutP1
	sets port vlan tag mode customer
	sets port default-vid 1
	sets port discard-untagged false
	sets port discard-tagged false
	sets port force-default-vid false
	go s=$::sutSlot l1p=$::sutP2
	sets port vlan tag mode customer
	sets port default-vid 1
	sets port discard-untagged false
	sets port discard-tagged false
	sets port force-default-vid false
	uController -printlog yes
	printlog -fileid $tcLogId -res conf -cmd "set all vlan related parameters to default value"
	
}



