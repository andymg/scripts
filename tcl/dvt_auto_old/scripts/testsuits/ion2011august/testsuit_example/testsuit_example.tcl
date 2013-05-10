#Owner: Mark Wang
# this is a example test suit for new user study


# login system and remove all vlan from SUTs
proc example_1 {} {
	login -ipaddr $::sut1Ip -sutname sut1
	
	login -ipaddr $::sut2Ip -sutname sut2
	
	gotosut -sutname sut1
	
	go s=$::sut1Slot1 l1d
	
	remove vlan all
	
	gotosut -sutname sut2
	
	go s=$::sut2Slot1 l1d
	
	remove vlan all
	
}

# only one SUT, add a vlan to vlan table and check each parameter's value
proc example_2 {} {
	
	gotosut -sutname sut1
	
	go s=$::sut1Slot1 l1d
	
	remove vlan all
	
	add vlan-db vid 10
	
	sets vlan-db vid 10 fid 0 priority 3
	
	sets vlan-db vid 10 fid 0 pri-override enable
	
	sets vlan-db vid 10 port 1 memetag tag
	
	sets vlan-db vid 10 port 2 memetag noMod
	
	show vlan-db config -vid 10 -priority 3 -override enable -port1 tag -port2 noMod
	
	show vlan-db config -vid 10 -priority 5
	
}

# control two SUTs, add a vlan to vlan table and check each parameter's value
proc example_3 {} {
	
	gotosut -sutname sut1
	
	go s=$::sut1Slot1 l1d
	
	add vlan-db vid 100
	
	sets vlan-db vid 100 fid 0 priority 3
	
	sets vlan-db vid 100 fid 0 pri-override enable
	
	sets vlan-db vid 100 port 1 memetag tag
	
	sets vlan-db vid 100 port 2 memetag noMod
	
	show vlan-db config -vid 100 -priority 3 -override enable -port1 tag -port2 noMod
	
	show vlan-db config -vid 100 -priority 5
	
	gotosut -sutname sut2
	
	go s=$::sut2Slot1 l1d
	
	add vlan-db vid 200
	
	sets vlan-db vid 200 fid 0 priority 3
	
	sets vlan-db vid 200 fid 0 pri-override enable
	
	sets vlan-db vid 200 port 1 memetag tag
	
	sets vlan-db vid 200 port 2 memetag noMod
	
	show vlan-db config -vid 200 -priority 3 -override enable -port1 tag -port2 noMod
	
	show vlan-db config -vid 200 -priority 5
	
}

# ixia analyzer
# topo: ixiap1 <=> ixiap2
proc example_4 {} {
	
	# connect ixia analyzer
	connect_ixia -ipaddr $::ixiaIp -portlist $::ixiaPort1,ixiap1,$::ixiaPort2,ixiap2 -alias allport
	
	# config ixia port properties
	config_portprop -alias allport -phymode $::ixiaPhyMode
	
	# config frame
	config_frame -alias ixiap1 -srcmac "00 00 00 00 01 01" -dstmac "00 00 00 00 02 02" -framesize 100
	config_frame -alias ixiap2 -srcmac "00 00 00 00 02 02" -dstmac "00 00 00 00 01 01" -framesize 200
	
	# config stream
	config_stream -alias allport -rate 100
	
	# clear statistic counter
	clear_stat -alias allport
	
	# send traffic
	send_traffic -alias allport -actiontype start -time 10
	
	# get counter
	get_stat -alias ixiap1 -txframe ixiap1tx -rxframe ixiap1rx
	get_stat -alias ixiap2 -txframe ixiap2tx -rxframe ixiap2rx
	
	# check result
	check_result -para1 $ixiap1tx -para2 $ixiap2rx -condition = -log "ixiap1tx: $ixiap1tx, ixiap2rx: $ixiap2rx"
	check_result -para1 $ixiap2tx -para2 $ixiap1rx -condition = -log "ixiap2tx: $ixiap2tx, ixiap1rx: $ixiap1rx"
	
}

