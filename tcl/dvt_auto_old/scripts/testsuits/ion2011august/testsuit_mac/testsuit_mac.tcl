# Summary: this is a MAC test suit for ION platform
# Topology: ixiap1 <-> sutP1 ------ sutP3(SGMII) <-> ixiap3
#           ixiap2 <-> sutP2(SGMII) /
# DUT: x322x, x323x, x222x
# Owner: Field Tian
# Date: 2011-10-28
# version: 1.0.0
# Scope:



#
#init 
#
proc mac_0 {} {
    login -ipaddr  $::sutIpAddr -sutname $::sutSlot
	connect_ixia -ipaddr $::ixiaIpAddr -portlist $::ixiaPort1,ixiap1,$::ixiaPort2,ixiap2,$::ixiaPort3,ixiap3 -alias allport -loginname tianlong
	config_portprop -alias ixiap1 -autonego enable -phymode copper 
	config_portprop -alias ixiap2 -autonego enable -phymode copper
	config_portprop -alias ixiap3 -autonego enable -phymode copper
	config_frame -alias ixiap1 -srcmac $::ixiaMac1 -dstmac $::ixiaMac3 -framesize $::ixiaFrameSize
	config_frame -alias ixiap2 -srcmac $::ixiaMac2 -dstmac $::ixiaMac3 -framesize $::ixiaFrameSize
	config_frame -alias ixiap3 -srcmac $::ixiaMac3
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
#MAC Table:Dymanic
#除了show命令之外，其他的都是没有问题的
proc mac_1 {} {
	go s = $::sutSlot l1d
	sets dot1bridge aging-time 600
	
	#send traffic from IXIA port1
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode none -srcmac "00 00 00 00 01 01" -dstmac $::ixiaMac3 -framesize $::ixiaFrameSize
	clear_stat -alias allport
	send_traffic -alias ixiap1 -actiontype start -time 1
	# show fwddb config fdbid 0 –mac 00-00-00-00-01-01 –priority 0 –connectport 1 -type dynamic
	
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode none -srcmac "00 00 00 00 01 02" -dstmac $::ixiaMac3 -framesize $::ixiaFrameSize
	clear_stat -alias allport
	send_traffic -alias ixiap1 -actiontype start -time 1
	# show fwddb config fdbid 0 –mac 00-00-00-00-01-02 –priority 0 –connectport 1 -type dynamic
	
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode none -srcmac "00 00 00 00 01 03" -dstmac $::ixiaMac3 -framesize $::ixiaFrameSize
	clear_stat -alias allport
	send_traffic -alias ixiap1 -actiontype start -time 1
	# show fwddb config fdbid 0 –mac 00-00-00-00-01-03 –priority 0 –connectport 1 -type dynamic
	

   
    #send traffic from IXIA port2
	config_stream -alias allport -rate 1
	config_frame -alias ixiap2 -vlanmode none -srcmac "00 00 00 00 02 01" -dstmac $::ixiaMac3 -framesize $::ixiaFrameSize
	clear_stat -alias allport
	send_traffic -alias ixiap2 -actiontype start -time 1
	# show fwddb config fdbid 0 –mac 00-00-00-00-02-01 –priority 0 –connectport 2 -type dynamic
	
	config_stream -alias allport -rate 1
	config_frame -alias ixiap2 -vlanmode none -srcmac "00 00 00 00 02 02" -dstmac $::ixiaMac3 -framesize $::ixiaFrameSize
	clear_stat -alias allport
	send_traffic -alias ixiap2 -actiontype start -time 1
	# show fwddb config fdbid 0 –mac 00-00-00-00-02-02 –priority 0 –connectport 2 -type dynamic
	
	config_stream -alias allport -rate 1
	config_frame -alias ixiap2 -vlanmode none -srcmac "00 00 00 00 02 03" -dstmac $::ixiaMac3 -framesize $::ixiaFrameSize
	clear_stat -alias allport
	send_traffic -alias ixiap2 -actiontype start -time 1
	# show fwddb config fdbid 0 –mac 00-00-00-00-02-03 –priority 0 –connectport 2 -type dynamic


	#reset aging time to 300
	go s = $::sutSlot l1d
	sets dot1bridge aging-time 300

	# flush FDB table
	remove fwddb all
	
	
	
}



#
#MAC Table:Static&&StaticPA
#pass
proc mac_2 {} {
	go s = $::sutSlot l1d
	add fwddb mac 00-00-00-00-00-08 conn-port 2 priority 3 type static
	#show fwddb config fdbid 0 –mac 00-00-00-00-00-08 –priority 3 –connectport 2 -type static
	sets fwddb mac 00-00-00-00-00-08 fdbid 0 conn-port 3
	sets fwddb mac 00-00-00-00-00-08 fdbid 0 priority 7 
	
	#send traffic from IXIA port1
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode none -dstmac "00 00 00 00 00 08" -framesize $::ixiaFrameSize
	clear_stat -alias allport
	
	start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length $::ixiaFrameSize -dstmac "00 00 00 00 00 08"
	
	remove fwddb all
	
	

    add fwddb mac 00-00-00-00-01-08 conn-port 1 priority 7 type staticPA
    sets fwddb mac 00-00-00-00-01-08 fdbid 0 conn-port 2
    sets fwddb mac 00-00-00-00-01-08 fdbid 0 priority 6 

	go s = $::sutSlot l1d
	add vlan-db vid $::vlanid
	sets vlan-db vid $::vlanid port $::sutP1 memetag unTag
	sets vlan-db vid $::vlanid port $::sutP2 memetag noMod
	sets vlan-db vid $::vlanid port $::sutP3 memetag noMod
	
	go s = $::sutSlot l1d
	sets vlan-db vid $::vlanid fid 0 pri-override enable
	go s=$::sutSlot l1p=$::sutP1
	sets qos priority by-dst-mac enable
	go s=$::sutSlot l1p=$::sutP2
	sets port vlan tag mode provider
	
	
	#send traffic from IXIA port1
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode none -dstmac "00 00 00 00 01 08" -framesize $::ixiaFrameSize
	clear_stat -alias allport
	
	start_capture -alias ixiap2
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap2 -framedata frameData
	#check_frame -framedata $frameData -vlanid $::vlanid -priority 6
	
	
	go s = $::sutSlot l1d
	remove fwddb all
	remove vlan-db vid $::vlanid
	
	go s=$::sutSlot l1p=$::sutP2
	sets port vlan tag mode customer

}

#
#MAC Table:StaticNRL
#pass
proc mac_3 {} {
	go s = $::sutSlot l1d
	add fwddb mac 01-00-5e-00-01-01 conn-port  1  priority 3 type staticNRL
	sets fwddb mac 01-00-5e-00-01-01 fdbid 0 conn-port 3
	sets fwddb mac 01-00-5e-00-01-01 fdbid 0 priority 7 

	go s=$::sutSlot l1p=$::sutP1
	sets irate=rate2M erate=unLimited
	
	#send traffic from IXIA port1
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode none -dstmac "01 00 5E 00 01 01" -framesize $::ixiaFrameSize
	clear_stat -alias allport
	
	start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length $::ixiaFrameSize -dstmac "01 00 5E 00 01 01"
	
	go s = $::sutSlot l1d
	remove fwddb all
}



#
#MAC Security:SA Lock
#
proc mac_4 {} {
	go s=$::sutSlot l1p=$::sutP1
	#show ether security config -salock disable -lockaction discardandnotify -uni disable -mul disable

	go s = $::sutSlot l1d
	sets dot1bridge aging-time 15
	
	#send traffic from IXIA port1
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode none -srcmac "00 00 00 00 01 01" -framesize $::ixiaFrameSize
	clear_stat -alias allport
	send_traffic -alias ixiap1 -actiontype start -time 1
	#show fwddb config fdbid 0 –mac 00-00-00-00-01-01 –priority 0 –connectport 1 -type dynamic
	
	config_frame -alias ixiap1 -vlanmode none -srcmac "00 00 00 00 01 02" -framesize $::ixiaFrameSize
	clear_stat -alias allport
	send_traffic -alias ixiap1 -actiontype start -time 1
	#show fwddb config fdbid 0 –mac 00-00-00-00-01-02 –priority 0 –connectport 1 -type dynamic
	
	config_frame -alias ixiap1 -vlanmode none -srcmac "00 00 00 00 01 03" -framesize $::ixiaFrameSize
	clear_stat -alias allport
	send_traffic -alias ixiap1 -actiontype start -time 1
	#show fwddb config fdbid 0 –mac 00-00-00-00-01-03 –priority 0 –connectport 1 -type dynamic
	
	config_frame -alias ixiap1 -vlanmode none -srcmac "00 00 00 00 01 04" -framesize $::ixiaFrameSize
	clear_stat -alias allport
	send_traffic -alias ixiap1 -actiontype start -time 1
	#show fwddb config fdbid 0 –mac 00-00-00-00-01-04 –priority 0 –connectport 1 -type dynamic
	
	config_frame -alias ixiap1 -vlanmode none -srcmac "00 00 00 00 01 05" -framesize $::ixiaFrameSize
	clear_stat -alias allport
	send_traffic -alias ixiap1 -actiontype start -time 1
	#show fwddb config fdbid 0 –mac 00-00-00-00-01-05 –priority 0 –connectport 1 -type dynamic
	
	config_frame -alias ixiap1 -vlanmode none -srcmac "00 00 00 00 01 06" -framesize $::ixiaFrameSize
	clear_stat -alias allport
	send_traffic -alias ixiap1 -actiontype start -time 1
	#show fwddb config fdbid 0 –mac 00-00-00-00-01-06 –priority 0 –connectport 1 -type dynamic
	
	config_frame -alias ixiap1 -vlanmode none -srcmac "00 00 00 00 01 07" -framesize $::ixiaFrameSize
	clear_stat -alias allport
	send_traffic -alias ixiap1 -actiontype start -time 1
	#show fwddb config fdbid 0 –mac 00-00-00-00-01-07 –priority 0 –connectport 1 -type dynamic
	
	config_frame -alias ixiap1 -vlanmode none -srcmac "00 00 00 00 01 08" -framesize $::ixiaFrameSize
	clear_stat -alias allport
	send_traffic -alias ixiap1 -actiontype start -time 1
	#show fwddb config fdbid 0 –mac 00-00-00-00-01-08 –priority 0 –connectport 1 -type dynamic
	
	
	
	go s=$::sutSlot l1p=$::sutP1
	sets ether src-addr-lock enable
	sets ether src-addr-lock action discard
	sleep 20
	
	#send traffic from IXIA port1
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode none -srcmac "00 00 00 00 01 01" -framesize $::ixiaFrameSize
	clear_stat -alias allport
	start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length 0
	
	config_frame -alias ixiap1 -vlanmode none -srcmac "00 00 00 00 01 02" -framesize $::ixiaFrameSize
	clear_stat -alias allport
	start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length 0
	
	config_frame -alias ixiap1 -vlanmode none -srcmac "00 00 00 00 01 03" -framesize $::ixiaFrameSize
	clear_stat -alias allport
	start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length 0
	
	config_frame -alias ixiap1 -vlanmode none -srcmac "00 00 00 00 01 04" -framesize $::ixiaFrameSize
	clear_stat -alias allport
	start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length 0
	
	config_frame -alias ixiap1 -vlanmode none -srcmac "00 00 00 00 01 05" -framesize $::ixiaFrameSize
	clear_stat -alias allport
	start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length 0
	
	config_frame -alias ixiap1 -vlanmode none -srcmac "00 00 00 00 01 06" -framesize $::ixiaFrameSize
	clear_stat -alias allport
	start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length 0
	
	config_frame -alias ixiap1 -vlanmode none -srcmac "00 00 00 00 01 07" -framesize $::ixiaFrameSize
	clear_stat -alias allport
	start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length 0
	
	config_frame -alias ixiap1 -vlanmode none -srcmac "00 00 00 00 01 08" -framesize $::ixiaFrameSize
	clear_stat -alias allport
	start_capture -alias ixiap3
	send_traffic -alias ixiap1 -actiontype start -time 1
	stop_capture -alias ixiap3 -length 0

	
}
#
#FDB flushing
#pass
proc mac_6 {} {
	go s = $::sutSlot l1d

	add fwddb mac 00-00-00-00-00-01 conn-port  1 priority 0 type static
	remove fwddb all

	add fwddb mac 00-00-00-00-00-02 conn-port  1 priority 0 type staticPA
	remove fwddb all

	add fwddb mac 01-00-5e-00-01-01 conn-port  1 priority 0 type staticNRL
	remove fwddb all

	add fwddb mac 00-00-00-00-00-01 conn-port  1 priority 0 type static;
	add fwddb mac 00-00-00-00-00-02 conn-port  1 priority 0 type staticPA;
	add fwddb mac 01-00-5e-00-01-01 conn-port  1 priority 0 type staticNRL
	
	
	remove fwddb all
}



#
#Aging Time
#show 命令有问题 不能验证
proc mac_7 {} {
	go s = $::sutSlot l1d
	show dot1bridge aging-time –time 300
	# input command:
    # Not support this comamnd in current scripts!!!
	
	#1.From IXIA port 1, send a packet with source address of "00 00 03 00 00 00";
    config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode none -srcmac "00 00 03 00 00 00" -dstmac $::ixiaMac3 -framesize $::ixiaFrameSize
	clear_stat -alias allport
	send_traffic -alias ixiap1 -actiontype start -time 1
	show fwddb config fdbid 0 –mac 00-00-03-00-00-00 –priority 0 –connectport 1 -type dynamic
	#这个命令不起作用
	sleep 350
    #如何检验FDB表为空
	
	#2.From IXIA port 1, send a packet with source address of "00 00 03 00 00 00";
	sets dot1bridge aging-time 0
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode none -srcmac "00 00 03 00 00 00" -dstmac $::ixiaMac3 -framesize $::ixiaFrameSize
	clear_stat -alias allport
	send_traffic -alias ixiap1 -actiontype start -time 1
	show fwddb config fdbid 0 –mac 00-00-03-00-00-00 –priority 0 –connectport 1 -type dynamic
	sleep 60
	show fwddb config fdbid 0 –mac 00-00-03-00-00-00 –priority 0 –connectport 1 -type dynamic
	
	
	#3.From IXIA port 1, send a packet with source address of "00 00 03 00 00 15";
	sets dot1bridge aging-time 15
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode none -srcmac "00 00 03 00 00 15" -dstmac $::ixiaMac3 -framesize $::ixiaFrameSize
	clear_stat -alias allport
	send_traffic -alias ixiap1 -actiontype start -time 1
	show fwddb config fdbid 0 –mac 00-00-03-00-00-15 –priority 0 –connectport 1 -type dynamic
	sleep 20
	
	sets dot1bridge aging-time 3825
	sets dot1bridge aging-time 300
	remove fwddb all
}


#
#MAC Adress learning
#如何验证FDB为空
proc mac_8 {} {
	go s = $::sutSlot l1d
	show port mac_learning state -port1 enable -port2 enable -port3 enable
	
	go s=$::sutSlot l1p=$::sutP1
	sets fwd portlist 1
	
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode none -srcmac "00 00 00 00 00 01" -framesize $::ixiaFrameSize
	clear_stat -alias allport
	send_traffic -alias ixiap1 -actiontype start -time 1
	#show fwddb config fdbid 0 –mac 00-00-00-00-00-01 –priority 0 –connectport 1 -type dynamic
	
	go s = $::sutSlot l1d
	remove fwddb all
	sets mac_learning enable portlist=2,3

	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode none -srcmac "00 00 00 00 00 01" -framesize $::ixiaFrameSize
	clear_stat -alias allport
	send_traffic -alias ixiap1 -actiontype start -time 1
	#如何验证FDB为空
	
	go s = $::sutSlot l1d
	sets mac_learning enable portlist=1,2,3
	
	
	config_stream -alias allport -rate 1
	config_frame -alias ixiap1 -vlanmode none -srcmac "00 00 00 00 00 01" -framesize $::ixiaFrameSize
	clear_stat -alias allport
	send_traffic -alias ixiap1 -actiontype start -time 1
	#show fwddb config fdbid 0 –mac 00-00-00-00-00-01 –priority 0 –connectport 1 -type dynamic

	remove fwddb all
}

#
#pass
#Stress Testing
proc mac_9 {} {
	go s = $::sutSlot l1d
	
	add fwddb mac 00-00-00-00-00-01 conn-port  1 priority 0 type static
	add fwddb mac 00-00-00-00-00-02 conn-port  1 priority 2 type static
	add fwddb mac 00-00-00-00-00-03 conn-port  1 priority 4 type static
	add fwddb mac 00-00-00-00-00-04 conn-port  1 priority 6 type static
	add fwddb mac 00-00-00-00-00-05 conn-port  1 priority 0 type staticPA
	add fwddb mac 00-00-00-00-00-06 conn-port  1 priority 2 type staticPA
	add fwddb mac 00-00-00-00-00-07 conn-port  1 priority 4 type staticPA
	add fwddb mac 00-00-00-00-00-08 conn-port  1 priority 6 type staticPA
	add fwddb mac 01-00-5E-00-01-01 conn-port  1 priority 0 type staticNRL
	add fwddb mac 01-00-5E-00-01-02 conn-port  1 priority 2 type staticNRL
	add fwddb mac 01-00-5E-00-01-03 conn-port  1 priority 4 type staticNRL
	add fwddb mac 01-00-5E-00-01-04 conn-port  1 priority 6 type staticNRL
	
	add fwddb mac 00-00-00-00-01-05 conn-port  2 priority 0 type static
	add fwddb mac 00-00-00-00-01-06 conn-port  2 priority 2 type static
	add fwddb mac 00-00-00-00-01-07 conn-port  2 priority 4 type static
	add fwddb mac 00-00-00-00-01-08 conn-port  2 priority 6 type static
	add fwddb mac 00-00-00-00-02-01 conn-port  2 priority 0 type staticPA
	add fwddb mac 00-00-00-00-02-02 conn-port  2 priority 2 type staticPA
	add fwddb mac 00-00-00-00-02-03 conn-port  2 priority 4 type staticPA
	add fwddb mac 00-00-00-00-02-04 conn-port  2 priority 6 type staticPA
	add fwddb mac 01-00-5E-00-02-05 conn-port  2 priority 0 type staticNRL
	add fwddb mac 01-00-5E-00-02-07 conn-port  2 priority 2 type staticNRL
	add fwddb mac 01-00-5E-00-02-08 conn-port  2 priority 4 type staticNRL
	add fwddb mac 01-00-5E-00-03-01 conn-port  2 priority 6 type staticNRL
	
	add fwddb mac 00-00-00-00-03-02 conn-port  3 priority 0 type static
	add fwddb mac 00-00-00-00-03-03 conn-port  3 priority 2 type static
	add fwddb mac 00-00-00-00-03-04 conn-port  3 priority 4 type static
	add fwddb mac 00-00-00-00-03-05 conn-port  3 priority 6 type static
	add fwddb mac 00-00-00-00-03-06 conn-port  3 priority 0 type staticPA
	add fwddb mac 00-00-00-00-03-07 conn-port  3 priority 2 type staticPA
	add fwddb mac 00-00-00-00-03-08 conn-port  3 priority 4 type staticPA
	add fwddb mac 00-00-00-00-04-01 conn-port  3 priority 6 type staticPA
	add fwddb mac 01-00-5E-00-04-02 conn-port  3 priority 0 type staticNRL
	add fwddb mac 01-00-5E-00-04-03 conn-port  3 priority 2 type staticNRL
	add fwddb mac 01-00-5E-00-04-04 conn-port  3 priority 4 type staticNRL
	add fwddb mac 01-00-5E-00-04-05 conn-port  3 priority 6 type staticNRL
	
	
	#flush all 
	remove fwddb all
 
}