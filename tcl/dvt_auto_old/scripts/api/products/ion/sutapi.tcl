

# only used for write test case log
# -fileid
# -res		pass|fail|conf|warn|chck
# -cmd		any action which user want to write to test case log file
# -comment	any comments which user want to write to test case log file
# printlog -fileid $abc -res pass -cmd "add vlan-db vid 100" -note "this is a note information"
proc printlog1 {args} {
	global tcLogId debuglogid
	
	set lenOfCmd 		45; # the length of cmd 
	set lenOfComment	30; # the length of comment
	
	# deal with the parameters
	foreach {handle para} $args {
		if {[regexp {^-(.*)$} $handle all handleval]} {
			lappend handlelist $handleval
			lappend paralist $para
		}
	}
	foreach item1 $handlelist item2 $paralist {
		set $item1\_value $item2
	}
	
	if {[string equal -nocase $::g_printlog yes]} {
		# timeStamp format
		set timeStamp [clock format [clock seconds] -format "%H:%M:%S"]
		if {![info exist fileid_value]} {
			puts "printlog: fileid is a mandatory parameter but missing"
			exit
		}
		if {![info exist res_value]} {
			puts "printlog: res is a mandatory parameter but missing"
			exit
		}
		if {![info exist cmd_value]} {
			puts "printlog: cmd is a mandatory parameter but missing"
			exit
		}
		
		set timeStrLen [string length "$timeStamp <$res_value> "]
		set timeStr "$timeStamp <$res_value>"
		set cmdOk 0
		set commentOk 0
		set blankStr "               "
		
		for {set lineNum 1} {$lineNum <= 100} {incr lineNum} {
			set num 1
			set writeStr ""
			# check the first line or not
			if {$lineNum == 1} {
				append writeStr $timeStr
			} else {
				append writeStr $blankStr
			}
			# cmd string
			if {[string length $cmd_value] <= $lenOfCmd} {
				if {[string length $cmd_value] == 0} {
					for {set j 1} {$j <= [expr $lenOfCmd + 4]} {incr j} {
						append writeStr " "
						set cmdOk 1
					}
				} else {
					append writeStr " \{$cmd_value"
					for {set i 1} {$i < [expr $lenOfCmd - [string length $cmd_value]]} {incr i} {
						append writeStr " "
						if {$i == [expr $lenOfCmd - [string length $cmd_value]]} {
							append writeStr " \}"
						}
					}
					set cmdOk 1
					set cmd_value ""
				}
			} else {
				set partOfCmdValue [string range $cmd_value 0 $lenOfCmd]
				set cmd_value [string range $cmd_value [expr $lenOfCmd + 1] end]
				append writeStr " \{$partOfCmdValue\}"
			}
			# comment string
			if {[info exist comment_value]} {
				if {[string length $comment_value] <= $lenOfComment} {
					append writeStr " \[$comment_value"
					for {set i 1} {$i <= [expr $lenOfComment - [string length $comment_value]]} {incr i} {
						append writeStr " "
						if {$i == [expr $lenOfComment - [string length $comment_value]]} {
							append writeStr " \]"
						}
					}
					set commentOk 1
				} else {
					set partOfCommValue [string range $comment_value 0 $lenOfComment]
					set comment_value [string range $comment_value [expr $lenOfComment + 1] end]
					append writeStr " \[$partOfCommValue\]"
				}
			} else {
				set commentOk 1
			}
			# write log to file
			#if {[catch {puts $fileid_value $writeStr; flush $fileid_value; puts $writeStr}]} {
			#	puts "write test case log failed"
			#	exit
			#}
			if {$cmdOk && $commentOk} {
				break
			}
		}
	}
}




proc printlog {args} {
	global tcLogId debuglogid
	
	set lenOfCmd 		45; # the length of cmd 
	set lenOfComment	30; # the length of comment
	
	# deal with the parameters
	foreach {handle para} $args {
		if {[regexp {^-(.*)$} $handle all handleval]} {
			lappend handlelist $handleval
			lappend paralist $para
		}
	}
	foreach item1 $handlelist item2 $paralist {
		set $item1\_value $item2
	}
	
	if {[string equal -nocase $::g_printlog yes]} {
		# timeStamp format
		set timeStamp [clock format [clock seconds] -format "%H:%M:%S"]
		if {![info exist fileid_value]} {
			puts "printlog: fileid is a mandatory parameter but missing"
			exit
		}
		if {![info exist res_value]} {
			puts "printlog: res is a mandatory parameter but missing"
			exit
		}
		if {![info exist cmd_value]} {
			puts "printlog: cmd is a mandatory parameter but missing"
			exit
		}
		
		#set timeStrLen [string length "$timeStamp <$res_value> "]
		set timeStr "$timeStamp <$res_value> "
		set cmdOk 0
		set commentOk 0
		set blankStr "                "

		for {set lineNum 1} {$lineNum <= 100} {incr lineNum} {
			set writeStr ""
			# check the first line or not
			if {$lineNum == 1} {
				append writeStr $timeStr
			} else {
				append writeStr $blankStr
			}
			
			# cmd string
			if {[string length $cmd_value] == $lenOfCmd} {
				append writeStr \{$cmd_value\}
				set cmdOk 1
				set cmd_value ""
			} elseif {[string length $cmd_value] == 0} {
				set cmdOk 1
				set cmd_value ""
			} elseif {[string length $cmd_value] < $lenOfCmd} {
				set blankLen [expr $lenOfCmd - [string length $cmd_value] +1]
				for {set j 1} {$j <= $blankLen} {incr j} {
					if {$j == 1} {
						append writeStr \{$cmd_value
					}
					append writeStr " "
					if {$j == $blankLen} {
						append writeStr \}
					}
					set cmdOk 1
					set cmd_value ""
				}
			} else {
				set partOfCmdValue [string range $cmd_value 0 $lenOfCmd]
				set cmd_value [string range $cmd_value [expr $lenOfCmd + 1] end]
				append writeStr \{$partOfCmdValue\}
			}
			# comment string
			if {[info exist comment_value]} {
				set len1 [string length $writeStr]
				append writeStr " "
				if {$len1 <= [string length $timeStr] && [string length $comment_value] != 0} {
					for {set l 1} {$l <= [expr $lenOfCmd + 3]} {incr l} {
						append writeStr " "
					}
				}
				
				if {[string length $comment_value] == $lenOfComment} {
					append writeStr \[$comment_value\]
					set commentOk 1
					set comment_value ""
				} elseif {[string length $comment_value] == 0} {
					set commentOk 1
					set comment_value ""
				} elseif {[string length $comment_value] < $lenOfComment} {
					set blankLen [expr $lenOfComment - [string length $comment_value] + 1]
					for {set k 1} {$k <= $blankLen} {incr k} {
						if {$k == 1} {
							append writeStr \[$comment_value
						}
						append writeStr " "
						if {$k == $blankLen} {
							append writeStr \]
						}
						set commentOk 1
						set comment_value ""
					}
				} else {
					set partOfCommandValue [string range $comment_value 0 $lenOfComment]
					set comment_value [string range $comment_value [expr $lenOfComment + 1] end]
					append writeStr \[$partOfCommandValue\]
				}
			} else {
				set commentOk 1
			}
			# write log to file
			#if {[string length $writeStr] > [string length $timeStr]} {
		#		if {[catch {puts $fileid_value $writeStr; flush $fileid_value; puts $writeStr}]} {
		#			puts "write test case log failed"
		#			exit
		#		}
			}
			
			if {$cmdOk && $commentOk} {
				break
			}
		}
	}
}


# -ipaddr x.x.x.x 
# -usr ION 				default: ION
# -psd private			default: private 
# -port 23				default: 23
# -sutname					default: no default value
# login -ipaddr 192.168.0.64 -usr ION -psd private -port 23
# login -ipaddr 192.168.0.63
proc login {args} {
	global tnExp1StrArr tcLogId g_tnSutInfoArr g_tnSutName
	set aftertime 500
	set timeStamp [clock format [clock seconds] -format "%H:%M:%S"]
	
	# get command and handle/parameters
	foreach {handle para} $args {
		if {[regexp {^-(.*)$} $handle all handleval]} {
			lappend handlelist $handleval
			lappend paralist $para
		}
	}
	
	# set all of the parameters value
	foreach item1 $handlelist item2 $paralist {
		set $item1\_value $item2
	}
	
	# check and set default value
	if {![info exist ipaddr_value]} {
		exp1_puts "$timeStamp: login, error, ipaddr is a mandatory parameter but missing"
		exp1_exit
	}
	if {![info exist sutname_value]} {
		exp1_puts "$timeStamp: login, error, sutname is a mandatory parameter but missing"
		exp1_exit
	}
	if {![info exist usr_value]} { set usr_value ION }
	if {![info exist psd_value]} { set psd_value private }
	if {![info exist port_value]} { set port_value 23 }
	
	#global [subst $sutname_value]
	set g_tnSutName $sutname_value
	
	# launch a telnet
	set expId [exp1_connect -ipaddr $ipaddr_value -port $port_value]
	exp1_config -spawnid $expId -logUser 0 -maxNum 8000
	
	# set g_sutInfo
	set g_tnSutInfoArr($sutname_value,name) 	$sutname_value
	set g_tnSutInfoArr($sutname_value,spawnid) 	$expId
	set g_tnSutInfoArr($sutname_value,ipaddr) 	$ipaddr_value
	set g_tnSutInfoArr($sutname_value,port) 	$port_value
	
	# send the user name and password to SUT
	exp1_send_cmd -spawnid $expId -cmdlist $usr_value -expchar Password:
	set getStr [exp1_send_cmd -spawnid $expId -cmdlist $psd_value]
	
	# get expect_out(buffer) array
	exp1_getstr -inputstr $getStr
	
	#print log
	set logStr "login sut $ipaddr_value port $port_value successful"
	printlog -fileid $tcLogId -res pass -cmd $logStr -comment $tnExp1StrArr(fullprompt)
	
}

# go to a appointed slot or port
# go s=4 l1d
# go s=4 l1p=1
# go s=4 l1ap=2 l2d
# go s=4 l1ap=2 l2p=1
# go s=4 l1ap=2 l2ap=1 l3d
# go s=4 l1ap=2 l2ap=1 l3p=1
# return: N/A

proc go {args} {
	global tnExp1StrArr tcLogId g_tnSutInfoArr g_tnSutName
	set procName go
	set tnErrInfo ""
	
	# get cli command string
	set cmdStr [uGetCmdStr $args $procName]
	
	# send command to SUT
	set getStr [exp1_send_cmd -spawnid $g_tnSutInfoArr($g_tnSutName,spawnid) -cmdlist $cmdStr]
	
	# get expect_out(buffer) array
	exp1_getstr -inputstr $getStr
	
	# check result
	if {$tnExp1StrArr(retstrlen) == 0} {
		set res pass
	} else {
		set res fail
		set tnErrInfo $tnExp1StrArr(retstr)
	}
	set logicRes [uCheckResult -actRes $res]
	printlog -fileid $tcLogId -res $logicRes -cmd "$procName $args" -comment "$tnExp1StrArr(fullprompt) $tnErrInfo"
	
}


# add vlan-db vid 107
proc add {args} {
	global tnExp1StrArr tcLogId g_tnSutInfoArr g_tnSutName
	set procName add
	set tnErrInfo ""
	# get cli command string
	set cmdStr [uGetCmdStr $args $procName]
	
	# send command to SUT
	set getStr [exp1_send_cmd -spawnid $g_tnSutInfoArr($g_tnSutName,spawnid) -cmdlist $cmdStr]
	
	# get expect_out(buffer) array
	exp1_getstr -inputstr $getStr
	
	# check result
	if {$tnExp1StrArr(retstrlen) <= 10} {
		set res pass
	} else {
		set res fail
		set tnErrInfo $tnExp1StrArr(retstr)
	}
	
	# print log
	set logicRes [uCheckResult -actRes $res]
	printlog -fileid $tcLogId -res $logicRes -cmd "$procName $args" -comment "$tnErrInfo"
	
}


# sets vlan-db vid 101 fid 0 priority 3
proc sets {args} {
	global tnExp1StrArr tcLogId g_tnSutInfoArr g_tnSutName
	set procName set
	set tnErrInfo ""
	
	# get cli command string
	set cmdStr [uGetCmdStr $args $procName]
	
	# send command to SUT
	set getStr [exp1_send_cmd -spawnid $g_tnSutInfoArr($g_tnSutName,spawnid) -cmdlist $cmdStr]
	
	# get expect_out(buffer) array
	exp1_getstr -inputstr $getStr
	
	# check result
	if {$tnExp1StrArr(retstrlen) <= 5} {
		set res pass
	} else {
		set res fail
		set tnErrInfo $tnExp1StrArr(retstr)
	}
	
	set logicRes [uCheckResult -actRes $res]
	printlog -fileid $tcLogId -res $logicRes -cmd "$procName $args" -comment "$tnErrInfo"
}


# remove vlan-db vid 100
# remove vlan all
proc remove {args} {
	global tnExp1StrArr tcLogId g_tnSutInfoArr g_tnSutName
	set procName remove
	set tnErrInfo ""
	
	# get cli command string
	set cmdStr [uGetCmdStr $args $procName]
	
	# send command to SUT
	set getStr [exp1_send_cmd -spawnid $g_tnSutInfoArr($g_tnSutName,spawnid) -cmdlist $cmdStr]
	
	# get expect_out(buffer) array
	exp1_getstr -inputstr $getStr
	
	# check result
	if {$tnExp1StrArr(retstrlen) <= 5} {
		set res pass
	} else {
		switch -regexp $tnExp1StrArr(retstr) {
			"Flush VLANdb succeeded!" {set res pass}
			default					  {set res fail; set tnErrInfo $tnExp1StrArr(retstr)}
		}
	}
	
	# print log
	set logicRes [uCheckResult -actRes $res]
	printlog -fileid $tcLogId -res $logicRes -cmd "$procName $args" -comment "$tnErrInfo"
}

# reset uptime 
# reset all ports counters
# reset factory
proc reset {args} {
	global tnExp1StrArr tcLogId g_tnSutInfoArr g_tnSutName
	set procName reset
	
	# get cli command string
	set cmdStr [uGetCmdStr $args $procName]
	
	# send command to SUT
	set getStr [exp1_send_cmd -spawnid $g_tnSutInfoArr($g_tnSutName,spawnid) -cmdlist $cmdStr]
	
	# get expect_out(buffer) array
	exp1_getstr -inputstr $getStr
	
	# check result
	if {$tnExp1StrArr(retstrlen) <= 5} {
		set res pass
	} else {
		switch -regexp $tnExp1StrArr(retstr) {
			"Warning: this command will restart the specified card, connection will be lost!" \
				{set res pass; puts "card is restarting, please wait about 3 minutes!"; sleep 180}
			default	{set res fail; set tnErrInfo $tnExp1StrArr(retstr)}
		}
	}
	
	# print log
	if {[info exist tnErrInfo]} {
		printlog -fileid $tcLogId -res $res -cmd "$procName $args" -comment "tnErrInfo: $tnErrInfo"
	} else {
		printlog -fileid $tcLogId -res $res -cmd "$procName $args"
	}
}


# reboot
proc reboot {args} {
	global tnExp1StrArr tcLogId g_tnSutInfoArr g_tnSutName
	set procName reboot
	
	# get cli command string
	set cmdStr [uGetCmdStr $args $procName]
	
	# send command to SUT
	set getStr [exp1_send_cmd -spawnid $g_tnSutInfoArr($g_tnSutName,spawnid) -cmdlist $cmdStr]
	
	# get expect_out(buffer) array
	exp1_getstr -inputstr $getStr
	
	# check result
	if {$tnExp1StrArr(retstrlen) <= 5} {
		set res pass
	} else {
		switch -regexp $tnExp1StrArr(retstr) {
			"Warning: this command will restart system, connection will be lost and please login again!" \
				{set res pass; puts "card is restarting, please wait about 3 minutes!"; sleep 180}
			default	{set res fail; set tnErrInfo $tnExp1StrArr(retstr)}
		}
	}
	
	# print log
	if {[info exist tnErrInfo]} {
		printlog -fileid $tcLogId -res $res -cmd "$procName $args" -comment "tnErrInfo: $tnErrInfo"
	} else {
		printlog -fileid $tcLogId -res $res -cmd "$procName $args"
	}
}


proc show {args} {
	set procName show
	set fullCmdStr [append procName " " $args]
	set idx [string first " -" $fullCmdStr]
	set cliCmd [string range $fullCmdStr 0 $idx]
	set paraList [string range $fullCmdStr [expr $idx + 1] end]
	#puts "cliCmd: $cliCmd"
	#puts "paraList: $paraList"
	
	switch -regexp $cliCmd {
		{\s*show\s+vlan-db\s+config.*}									{set res [showVlanTable $paraList]}
		{\s*show\s+port\s+vlan\s+config.*}								{set res [showPortVlanConfig $paraList]}
		{\s*show\s+fwddb\s+config\s+fdbid.*}							{set res [showFwddbConfig $paraList]}
		{\s*show\s+port\s+vlan\s+tag\s+config.*}						{set res [showPortVlanTagConfig $paraList]}
		{\s*show\s+ether\s+security\s+config.*}							{set res [showEtherSecurityConfig $paraList]}
		{\s*show\s+bandwidth\s+allocation.*}							{set res [showBandwidthAllocation $paraList]}
		{\s*show\s+qos\s+config.*}										{set res [showQosConfig $paraList]}
		{\s*show\s+qos\s+priority remapping.*}							{set res [showQosPriorityRemapping $paraList]}
		{\s*show\s+dot1bridge\s+aging\-time.*}							{set res [showDot1bridgeAgingtime $paraList]}
		{\s*show\s+port\s+mac_learning\s+state.*}						{set res [showPortMaclearningState $paraList]}
		{\s*show\s+dot1dbridge\s+ieee\-tag\s+priority\s+remapping.*}	{set res [showDot1dbridgeIeeetagPriorityRemapping $paraList]}
		{\s*show\s+dot1dbridge\s+ip\-tc\s+priority\s+remapping.*}		{set res [showDot1dbridgeIptcPriorityRemapping $paraList]}
		{\s*show\s+fwd\s+portlist.*}									{set res [showFwdPortlist $paraList]}
		{\s*show\s+card\s+info.*}										{set res [showCardInfo $paraList]}
		default {puts "input command: $cliCmd\nNot support this comamnd in current scripts!!!"; set res ""}
	}
	return $res
}


# -vid 					[1-4094]
# -fid 					[0-4094]
# -priority				[0-7]
# -priv_override		[enable|disable]
# -port1 				[nomember|nomod|tag|untag]
# -port2 				[nomember|nomod|tag|untag]
# -port3				[nomember|nomod|tag|untag]
proc showVlanTable {args} {
	global tnExp1StrArr tcLogId g_tnSutInfoArr g_tnSutName
	set args [split [join $args]]
	set cmdStr "show vlan-db config"
	
	# get parameter handle and parameter value
	foreach {handle para} $args {
		if {[regexp {^-(.*)$} $handle all handleval]} {
			lappend handlelist $handleval
			lappend paralist $para
		}
	}
	
	# set all of the parameters value
	foreach item1 $handlelist item2 $paralist {
		set $item1\_value $item2
	}
	
	# check and set default value
	if {![info exist vid_value]} {
		exp1_puts "showVlanTable, error, vid is a mandatory parameter but missing"
		exp1_exit
	}
	
	# send command to SUT
	set getStr [exp1_send_cmd -spawnid $g_tnSutInfoArr($g_tnSutName,spawnid) -cmdlist $cmdStr]

	# get expect_out(buffer) array
	exp1_getstr -inputstr $getStr
	
	#get full string which each vid related
	set retFullStr $tnExp1StrArr(retstr)
	set vlanNum 0
	while {1} {
		if {[regexp -start 10 {vid:\d+} $retFullStr]} {
			incr vlanNum
			regexp -indices -start 10 {vid:\d+} $retFullStr idx
			set showStr(line,$vlanNum) [string range $retFullStr 0 [expr [lindex $idx 0] - 1]]
			set retFullStr [string range $retFullStr [lindex $idx 0] end]
		} else {
			incr vlanNum
			set showStr(line,$vlanNum) $retFullStr
			break
		}
	}
	
	#deal with each vid related string and save all parameters value to an array
	for {set i 1} {$i <= $vlanNum} {incr i} {
		if {[string first port3 $showStr(line,$i)] > 0} {
			regexp {vid:(\d+)\s+fid:(\d+)\s+priority:(\d+)\s+priv_override:(\w+)\W+port1:\s+(\w+)\s+port2:\s+(\w+)\s+port3:\s+(\w+)} \
			$showStr(line,$i) match showStr(vid) showStr(fid) showStr(priority) showStr(priv_override) \
			showStr(port1) showStr(port2) showStr(port3)
		} else {
			regexp {vid:(\d+)\s+fid:(\d+)\s+priority:(\d+)\s+priv_override:(\w+)\W+port1:\s+(\w+)\s+port2:\s+(\w+)} \
			$showStr(line,$i) match showStr(vid) showStr(fid) showStr(priority) showStr(priv_override) \
			showStr(port1) showStr(port2)
		}
		set showStr(line) $showStr(line,$i)
		if {[string equal $vid_value $showStr(vid)]} {
			break
		}
	}
	
	#compare the input value with actual value
	set errPara ""
	set chk1 1
	if {[info exist fid_value]} {
		if {![string equal $fid_value $showStr(fid)]} {
			set chk1 0
			lappend errPara "fid: $showStr(fid)"
		}
	}
	set chk2 1
	if {[info exist priority_value]} {
		if {![string equal $priority_value $showStr(priority)]} {
			set chk2 0
			lappend errPara "priority: $showStr(priority)"
		}
	}
	set chk3 1
	if {[info exist priv_override_value]} {
		if {![string equal $priv_override_value $showStr(priv_override)]} {
			set chk3 0
			lappend errPara "priv_override: $showStr(priv_override)"
		}
	}
	set chk4 1
	if {[info exist port1_value]} {
		if {![string equal $port1_value $showStr(port1)]} {
			set chk4 0
			lappend errPara "port1: $showStr(port1)"
		}
	}
	set chk5 1
	if {[info exist port2_value]} {
		if {![string equal $port2_value $showStr(port2)]} {
			set chk5 0
			lappend errPara "port2: $showStr(port2)"
		}
	}
	set chk6 1
	if {[info exist port3_value]} {
		if {![string equal $port3_value $showStr(port3)]} {
			set chk6 0
			lappend errPara "port3: $showStr(port3)"
		}
	}
	
	if {$chk1 && $chk2 && $chk3 && $chk4 && $chk5 && $chk6} {
		set res pass
	} else {
		set res fail
	}
	
	set logicRes [uCheckResult -actRes $res]
	printlog -fileid $tcLogId -res $logicRes -cmd "$cmdStr $args" -comment $errPara
	return $getStr
}



# -state
# -tag
# -untag
# -defid
# -forceid
proc showPortVlanConfig {args} {
	global tnExp1StrArr tcLogId g_tnSutInfoArr g_tnSutName
	set args [split [join $args]]
	set cmdStr "show port vlan config"
	
	# get parameter handle and parameter value
	foreach {handle para} $args {
		if {[regexp {^-(.*)$} $handle all handleval]} {
			lappend handlelist $handleval
			lappend paralist $para
		}
	}
	
	# set all of the parameters value
	foreach item1 $handlelist item2 $paralist {
		set $item1\_value $item2
	}
	
	# send command to SUT
	set getStr [exp1_send_cmd -spawnid $g_tnSutInfoArr($g_tnSutName,spawnid) -cmdlist $cmdStr]

	# get expect_out(buffer) array
	exp1_getstr -inputstr $getStr
	
	# get actual value of each parameters
	regexp {Dot1q state:\s+(\w+)} $getStr match showStr(state)
	regexp {Discard-tagged:\s+(\w+)} $getStr match showStr(tag)
	regexp {Discard-untagged:\s+(\w+)} $getStr match showStr(untag)
	regexp {Default VLAN id:\s+(\w+)} $getStr match showStr(defid)
	regexp {Force use default VLAN id:\s+(\w+)} $getStr match showStr(forceid)
	
	#compare the input value with actual value
	set errPara ""
	set chk1 1
	if {[info exist state_value]} {
		if {![string equal -nocase $state_value $showStr(state)]} {
			set chk1 0
			lappend errPara "state: $showStr(state)"
		}
	}
	set chk2 1
	if {[info exist tag_value]} {
		if {![string equal -nocase $tag_value $showStr(tag)]} {
			set chk2 0
			lappend errPara "tag: $showStr(tag)"
		}
	}
	set chk3 1
	if {[info exist untag_value]} {
		if {![string equal -nocase $untag_value $showStr(untag)]} {
			set chk3 0
			lappend errPara "untag: $showStr(untag)"
		}
	}
	set chk4 1
	if {[info exist defid_value]} {
		if {![string equal -nocase $defid_value $showStr(defid)]} {
			set chk4 0
			lappend errPara "defid: $showStr(defid)"
		}
	}
	set chk5 1
	if {[info exist forceid_value]} {
		if {![string equal -nocase $forceid_value $showStr(forceid)]} {
			set chk5 0
			lappend errPara "forceid: $showStr(forceid)"
		}
	}
	
	if {$chk1 && $chk2 && $chk3 && $chk4 && $chk5} {
		set res pass
	} else {
		set res fail
	}
	set logicRes [uCheckResult -actRes $res]
	printlog -fileid $tcLogId -res $logicRes -cmd "$cmdStr $args" -comment $errPara
	return $getStr
}




# fdbid     MAC                 connect port        priority            type
# -----------------------------------------------------------------------------------------------------
# 0         00-00-00-00-00-01   1                   0                   static
# 0         00-00-00-00-00-02   1                   2                   staticPA
# 0         00-00-00-00-00-03   2                   4                   static

# -mac
# -connectport
# -priority
# -type
proc showFwddbConfig {args} {
	global tnExp1StrArr tcLogId g_tnSutInfoArr g_tnSutName
	set args [split [join $args]]
	set cmdStr "show fwddb config fdbid 0"
	
	# get parameter handle and parameter value
	foreach {handle para} $args {
		if {[regexp {^-(.*)$} $handle all handleval]} {
			lappend handlelist $handleval
			lappend paralist $para
		}
	}
	
	# set all of the parameters value
	foreach item1 $handlelist item2 $paralist {
		set $item1\_value $item2
	}
	
	# check and set default value
	if {![info exist mac_value]} {
		exp1_puts "showFwddbConfig, error, mac is a mandatory parameter but missing"
		exp1_exit
	}
	
	# send command to SUT
	set getStr [exp1_send_cmd -spawnid $g_tnSutInfoArr($g_tnSutName,spawnid) -cmdlist $cmdStr]

	# get expect_out(buffer) array
	exp1_getstr -inputstr $getStr
	set retFullStr [string range $tnExp1StrArr(retstr) [expr [string last "----" $tnExp1StrArr(retstr)] + 5] end]
	
	# check mac existed or not in mac table
	set errPara ""
	set existMac [string first $mac_value $retFullStr]
	
	set chk1 1
	set chk2 1
	set chk3 1
	set chk4 1
	if {$existMac} {
		set showStr(connectport) 	[string index $retFullStr [expr $existMac + 20]]
		set showStr(priority)		[string index $retFullStr [expr $existMac + 40]]
		set showStr(type)			[string range $retFullStr [expr $existMac + 60] [expr $existMac + 67]]
		# puts "showStr(connectport): $showStr(connectport)"
		# puts "showStr(priority): $showStr(priority)"
		# puts "showStr(type): $showStr(type)"

		#compare the input value with actual value
		if {[info exist connectport_value]} {
			if {![string equal $connectport_value $showStr(connectport)]} {
				set chk1 0
				lappend errPara "connectport: $showStr(connectport)"
			}
		}
		
		if {[info exist priority_value]} {
			if {![string equal $priority_value $showStr(priority)]} {
				set chk2 0
				lappend errPara "priority: $showStr(priority)"
			}
		}
		
		if {[info exist type_value]} {
			if {![string equal -nocase -length 8 $type_value $showStr(type)]} {
				set chk3 0
				lappend errPara "type: $showStr(type)"
			}
		}
	} else {
		set chk4 0
		lappend errPara "this mac not existed"
	}
	
	if {$chk1 && $chk2 && $chk3 && $chk4} {
		set res pass
	} else {
		set res fail
	}
	
	set logicRes [uCheckResult -actRes $res]
	printlog -fileid $tcLogId -res $logicRes -cmd "$cmdStr $args" -comment $errPara
	return $getStr
}

# C1|S10|L1P1>show port vlan tag config 
# Tagging mode:                 provider
# Provider Ethernet type:       x8100
# C1|S10|L1P1>

# -mode
# -type

proc showPortVlanTagConfig {args} {
	global tnExp1StrArr tcLogId g_tnSutInfoArr g_tnSutName
	set args [split [join $args]]
	set cmdStr "show port vlan tag config"
	
	# get parameter handle and parameter value
	foreach {handle para} $args {
		if {[regexp {^-(.*)$} $handle all handleval]} {
			lappend handlelist $handleval
			lappend paralist $para
		}
	}
	
	# set all of the parameters value
	foreach item1 $handlelist item2 $paralist {
		set $item1\_value $item2
	}
	
	# send command to SUT
	set getStr [exp1_send_cmd -spawnid $g_tnSutInfoArr($g_tnSutName,spawnid) -cmdlist $cmdStr]

	# get expect_out(buffer) array
	exp1_getstr -inputstr $getStr
	
	# get actual value of each parameters
	set showStr(type) ""
	regexp {Tagging mode:\s+(\w+)} $getStr match showStr(mode)
	regexp {Provider Ethernet type:\s+(\w+)} $getStr match showStr(type)
	
	#compare the input value with actual value
	set errPara ""
	set chk1 1
	if {[info exist mode_value]} {
		if {![string equal -nocase $mode_value $showStr(mode)]} {
			set chk1 0
			lappend errPara "mode: $showStr(mode)"
		}
	}
	set chk2 1
	if {[info exist type_value]} {
		if {![string equal -nocase $type_value $showStr(type)]} {
			set chk2 0
			lappend errPara "type: $showStr(type)"
		}
	}
	
	if {$chk1 && $chk2} {
		set res pass
	} else {
		set res fail
	}
	set logicRes [uCheckResult -actRes $res]
	printlog -fileid $tcLogId -res $logicRes -cmd "$cmdStr $args" -comment $errPara
	return $getStr
}


# C1|S10|L1P1>show ether security config 
# Ethernet port security configuration:
# ----------------------------------------------------------------------------
# Source MAC address lock:           disable
# Source MAC address lock action:    discardandnotify
# Filter unknown dest unicast:       disable
# Filter unknown dest multicast:     disable
# C1|S10|L1P1>

# -salock
# -lockaction
# -uni
# -mul

proc showEtherSecurityConfig {args} {
	global tnExp1StrArr tcLogId g_tnSutInfoArr g_tnSutName
	set args [split [join $args]]
	set cmdStr "show ether security config"
	
	# get parameter handle and parameter value
	foreach {handle para} $args {
		if {[regexp {^-(.*)$} $handle all handleval]} {
			lappend handlelist $handleval
			lappend paralist $para
		}
	}
	
	# set all of the parameters value
	foreach item1 $handlelist item2 $paralist {
		set $item1\_value $item2
	}
	
	# send command to SUT
	set getStr [exp1_send_cmd -spawnid $g_tnSutInfoArr($g_tnSutName,spawnid) -cmdlist $cmdStr]

	# get expect_out(buffer) array
	exp1_getstr -inputstr $getStr
	
	# get actual value of each parameters
	regexp {Source MAC address lock:\s+(\w+)} 			$getStr match showStr(salock)
	regexp {Source MAC address lock action:\s+(\w+)} 	$getStr match showStr(lockaction)
	regexp {Filter unknown dest unicast:\s+(\w+)} 		$getStr match showStr(uni)
	regexp {Filter unknown dest multicast:\s+(\w+)} 	$getStr match showStr(mul)
	
	#compare the input value with actual value
	set errPara ""
	set chk1 1
	if {[info exist salock_value]} {
		if {![string equal -nocase $salock_value $showStr(salock)]} {
			set chk1 0
			lappend errPara "salock: $showStr(salock)"
		}
	}
	set chk2 1
	if {[info exist lockaction_value]} {
		if {![string equal -nocase $lockaction_value $showStr(lockaction)]} {
			set chk2 0
			lappend errPara "lockaction: $showStr(lockaction)"
		}
	}
	set chk3 1
	if {[info exist uni_value]} {
		if {![string equal -nocase $uni_value $showStr(uni)]} {
			set chk3 0
			lappend errPara "uni: $showStr(uni)"
		}
	}
	set chk4 1
	if {[info exist mul_value]} {
		if {![string equal -nocase $mul_value $showStr(mul)]} {
			set chk4 0
			lappend errPara "mul: $showStr(mul)"
		}
	}
	
	if {$chk1 && $chk2 && $chk3 && $chk4} {
		set res pass
	} else {
		set res fail
	}
	set logicRes [uCheckResult -actRes $res]
	printlog -fileid $tcLogId -res $logicRes -cmd "$cmdStr $args" -comment $errPara
	return $getStr
} 

# C1|S10|L1P1>show bandwidth allocation 
# Bandwidth allocation type:    countAllLayer1
# Ingress rate:                 unLimited
# Egress rate:                  unLimited
# C1|S10|L1P1>

# -batype
# -irate
# -erate

proc showBandwidthAllocation {args} {
	global tnExp1StrArr tcLogId g_tnSutInfoArr g_tnSutName
	set args [split [join $args]]
	set cmdStr "show bandwidth allocation"
	
	# get parameter handle and parameter value
	foreach {handle para} $args {
		if {[regexp {^-(.*)$} $handle all handleval]} {
			lappend handlelist $handleval
			lappend paralist $para
		}
	}
	
	# set all of the parameters value
	foreach item1 $handlelist item2 $paralist {
		set $item1\_value $item2
	}
	
	# send command to SUT
	set getStr [exp1_send_cmd -spawnid $g_tnSutInfoArr($g_tnSutName,spawnid) -cmdlist $cmdStr]

	# get expect_out(buffer) array
	exp1_getstr -inputstr $getStr
	
	# get actual value of each parameters
	regexp {Bandwidth allocation type:\s+(\w+)}	$getStr match showStr(batype)
	regexp {Ingress rate:\s+(\w+)} 				$getStr match showStr(irate)
	regexp {Egress rate:\s+(\w+)} 				$getStr match showStr(erate)
	
	#compare the input value with actual value
	set errPara ""
	set chk1 1
	if {[info exist batype_value]} {
		if {![string equal -nocase $batype_value $showStr(batype)]} {
			set chk1 0
			lappend errPara "batype: $showStr(batype)"
		}
	}
	set chk2 1
	if {[info exist irate_value]} {
		if {![string equal -nocase $irate_value $showStr(irate)]} {
			set chk2 0
			lappend errPara "irate: $showStr(irate)"
		}
	}
	set chk3 1
	if {[info exist erate_value]} {
		if {![string equal -nocase $erate_value $showStr(erate)]} {
			set chk3 0
			lappend errPara "erate: $showStr(erate)"
		}
	}
	
	if {$chk1 && $chk2 && $chk3} {
		set res pass
	} else {
		set res fail
	}
	set logicRes [uCheckResult -actRes $res]
	printlog -fileid $tcLogId -res $logicRes -cmd "$cmdStr $args" -comment $errPara
	return $getStr
}


# C1|S10|L1P1>show qos config 
# Default priority:                            0
# Use IEEE tag for priority:                   enable
# Use IP tag for priority:                     enable
# Tag type for priority if both tag available: useIEEE
# Use source MAC address for priority:         disable
# Use destination MAC address for priority:    disable
# Use VLAN id for priority:                    disable

# -defpri
# -useieee
# -useip
# -useboth
# -sa
# -da
# -vid

proc showQosConfig {args} {
	global tnExp1StrArr tcLogId g_tnSutInfoArr g_tnSutName
	set args [split [join $args]]
	set cmdStr "show qos config"
	
	# get parameter handle and parameter value
	foreach {handle para} $args {
		if {[regexp {^-(.*)$} $handle all handleval]} {
			lappend handlelist $handleval
			lappend paralist $para
		}
	}
	
	# set all of the parameters value
	foreach item1 $handlelist item2 $paralist {
		set $item1\_value $item2
	}
	
	# send command to SUT
	set getStr [exp1_send_cmd -spawnid $g_tnSutInfoArr($g_tnSutName,spawnid) -cmdlist $cmdStr]

	# get expect_out(buffer) array
	exp1_getstr -inputstr $getStr
	
	# get actual value of each parameters
	regexp {Default priority:\s+(\w+)}								$getStr match showStr(defpri)
	regexp {Use IEEE tag for priority:\s+(\w+)} 					$getStr match showStr(useieee)
	regexp {Use IP tag for priority:\s+(\w+)} 						$getStr match showStr(useip)
	regexp {Tag type for priority if both tag available:\s+(\w+)} 	$getStr match showStr(useboth)
	regexp {Use source MAC address for priority:\s+(\w+)} 			$getStr match showStr(sa)
	regexp {Use destination MAC address for priority:\s+(\w+)} 		$getStr match showStr(da)
	regexp {Use VLAN id for priority:\s+(\w+)} 						$getStr match showStr(vid)
	
	#compare the input value with actual value
	set errPara ""
	set chk1 1
	if {[info exist defpri_value]} {
		if {![string equal -nocase $defpri_value $showStr(defpri)]} {
			set chk1 0
			lappend errPara "defpri: $showStr(defpri)"
		}
	}
	set chk2 1
	if {[info exist useieee_value]} {
		if {![string equal -nocase $useieee_value $showStr(useieee)]} {
			set chk2 0
			lappend errPara "useieee: $showStr(useieee)"
		}
	}
	set chk3 1
	if {[info exist useip_value]} {
		if {![string equal -nocase $useip_value $showStr(useip)]} {
			set chk3 0
			lappend errPara "useip: $showStr(useip)"
		}
	}
	set chk4 1
	if {[info exist useboth_value]} {
		if {![string equal -nocase $useboth_value $showStr(useboth)]} {
			set chk4 0
			lappend errPara "useboth: $showStr(useboth)"
		}
	}
	set chk5 1
	if {[info exist sa_value]} {
		if {![string equal -nocase $sa_value $showStr(sa)]} {
			set chk5 0
			lappend errPara "sa: $showStr(sa)"
		}
	}
	set chk6 1
	if {[info exist da_value]} {
		if {![string equal -nocase $da_value $showStr(da)]} {
			set chk6 0
			lappend errPara "da: $showStr(da)"
		}
	}
	set chk7 1
	if {[info exist vid_value]} {
		if {![string equal -nocase $vid_value $showStr(vid)]} {
			set chk7 0
			lappend errPara "vid: $showStr(vid)"
		}
	}
	
	if {$chk1 && $chk2 && $chk3 & $chk4 && $chk5 && $chk6 && $chk7} {
		set res pass
	} else {
		set res fail
	}
	set logicRes [uCheckResult -actRes $res]
	printlog -fileid $tcLogId -res $logicRes -cmd "$cmdStr $args" -comment $errPara
	return $getStr
}

# C1|S10|L1P1>show qos priority remapping 
# ingress-priority                        remapping-priority                      
# -------------------------------------------------------------------
# 0                                       0
# 1                                       1
# 2                                       2
# 3                                       3
# 4                                       4
# 5                                       5
# 6                                       6
# 7                                       7

# -pri0
# -pri1
# -pri2
# -pri3
# -pri4
# -pri5
# -pri6
# -pri7

proc showQosPriorityRemapping {args} {
	global tnExp1StrArr tcLogId g_tnSutInfoArr g_tnSutName
	set args [split [join $args]]
	set cmdStr "show qos priority remapping"
	
	# get parameter handle and parameter value
	foreach {handle para} $args {
		if {[regexp {^-(.*)$} $handle all handleval]} {
			lappend handlelist $handleval
			lappend paralist $para
		}
	}
	
	# set all of the parameters value
	foreach item1 $handlelist item2 $paralist {
		set $item1\_value $item2
	}
	
	# send command to SUT
	set getStr [exp1_send_cmd -spawnid $g_tnSutInfoArr($g_tnSutName,spawnid) -cmdlist $cmdStr]

	# get expect_out(buffer) array
	exp1_getstr -inputstr $getStr
	set retFullStr [string range $tnExp1StrArr(retstr) [expr [string last "----" $tnExp1StrArr(retstr)] + 5] end]
	regexp {\d\s*(\d)\s*\d\s*(\d)\s*\d\s*(\d)\s*\d\s*(\d)\s*\d\s*(\d)\s*\d\s*(\d)\s*\d\s*(\d)\s*\d\s*(\d)\s*} \
	$retFullStr match \
	showStr(pri0) showStr(pri1) showStr(pri2) showStr(pri3) \
	showStr(pri4) showStr(pri5) showStr(pri6) showStr(pri7)
	
	set errPara ""
	set chk 0
	for {set i 0} {$i <= 7} {incr i} {
		if {[info exist pri${i}_value]} {
			if {![string equal -nocase [set pri${i}_value] [set showStr(pri${i})]]} {
				incr chk
				lappend errPara "pri$i: [set showStr(pri${i})]"
			}
		}
	}
	
	if {$chk} {
		set res fail
	} else {
		set res pass
	}
	set logicRes [uCheckResult -actRes $res]
	printlog -fileid $tcLogId -res $logicRes -cmd "$cmdStr $args" -comment $errPara
	return $getStr
}


# C1|S10|L1D>show dot1bridge aging-time 
# Dot1bridge aging time:                  300
# C1|S10|L1D>

# -time

proc showDot1bridgeAgingtime {args} {
	global tnExp1StrArr tcLogId g_tnSutInfoArr g_tnSutName
	set args [split [join $args]]
	set cmdStr "show dot1bridge aging-time"
	
	# get parameter handle and parameter value
	foreach {handle para} $args {
		if {[regexp {^-(.*)$} $handle all handleval]} {
			lappend handlelist $handleval
			lappend paralist $para
		}
	}
	
	# set all of the parameters value
	foreach item1 $handlelist item2 $paralist {
		set $item1\_value $item2
	}
	
	# send command to SUT
	set getStr [exp1_send_cmd -spawnid $g_tnSutInfoArr($g_tnSutName,spawnid) -cmdlist $cmdStr]

	# get expect_out(buffer) array
	exp1_getstr -inputstr $getStr
	
	# get actual value of each parameters
	regexp {Dot1bridge aging time:\s+(\w+)} $getStr match showStr(time)
	
	#compare the input value with actual value
	set errPara ""
	set chk1 1
	if {[info exist time_value]} {
		if {![string equal -nocase $time_value $showStr(time)]} {
			set chk1 0
			lappend errPara "time: $showStr(time)"
		}
	}
	
	if {$chk1} {
		set res pass
	} else {
		set res fail
	}
	set logicRes [uCheckResult -actRes $res]
	printlog -fileid $tcLogId -res $logicRes -cmd "$cmdStr $args" -comment $errPara
	return $getStr
}

# C1|S10|L1D>show port mac_learning state 
# Port Mac learning:
# Port1:                             enable
# Port2:                             enable
# C1|S10|L1D>

# -port1
# -port2
# -port3
proc showPortMaclearningState {args} {
	global tnExp1StrArr tcLogId g_tnSutInfoArr g_tnSutName
	set args [split [join $args]]
	set cmdStr "show port mac_learning state"
	
	# get parameter handle and parameter value
	foreach {handle para} $args {
		if {[regexp {^-(.*)$} $handle all handleval]} {
			lappend handlelist $handleval
			lappend paralist $para
		}
	}
	
	# set all of the parameters value
	foreach item1 $handlelist item2 $paralist {
		set $item1\_value $item2
	}
	
	# send command to SUT
	set getStr [exp1_send_cmd -spawnid $g_tnSutInfoArr($g_tnSutName,spawnid) -cmdlist $cmdStr]

	# get expect_out(buffer) array
	exp1_getstr -inputstr $getStr
	
	# get actual value of each parameters
	regexp {Port1:\s+(\w+)} $getStr match showStr(port1)
	regexp {Port2:\s+(\w+)} $getStr match showStr(port2)
	regexp {Port3:\s+(\w+)} $getStr match showStr(port3)
	
	#compare the input value with actual value
	set errPara ""
	set chk1 1
	if {[info exist port1_value]} {
		if {![string equal -nocase $port1_value $showStr(port1)]} {
			set chk1 0
			lappend errPara "port1: $showStr(port1)"
		}
	}
	set chk2 1
	if {[info exist port2_value]} {
		if {![string equal -nocase $port2_value $showStr(port2)]} {
			set chk2 0
			lappend errPara "port2: $showStr(port2)"
		}
	}
	set chk3 1
	if {[info exist port3_value]} {
		if {![string equal -nocase $port3_value $showStr(port3)]} {
			set chk3 0
			lappend errPara "port3: $showStr(port3)"
		}
	}
	
	if {$chk1 && $chk2 && $chk3} {
		set res pass
	} else {
		set res fail
	}
	set logicRes [uCheckResult -actRes $res]
	printlog -fileid $tcLogId -res $logicRes -cmd "$cmdStr $args" -comment $errPara
	return $getStr
}


# C1|S10|L1D>show dot1dbridge ieee-tag priority remapping 
# IEEE priority-index                     remapping-priority                      
# --------------------------------------------------------
# 0                                       0                                        
# 1                                       0                                        
# 2                                       1                                        
# 3                                       1                                        
# 4                                       2                                        
# 5                                       2                                        
# 6                                       3                                        
# 7                                       3                                        

# -pri0
# -pri1
# -pri2
# -pri3
# -pri4
# -pri5
# -pri6
# -pri7

proc showDot1dbridgeIeeetagPriorityRemapping {args} {
	global tnExp1StrArr tcLogId g_tnSutInfoArr g_tnSutName
	set args [split [join $args]]
	set cmdStr "show dot1dbridge ieee-tag priority remapping"
	
	# get parameter handle and parameter value
	foreach {handle para} $args {
		if {[regexp {^-(.*)$} $handle all handleval]} {
			lappend handlelist $handleval
			lappend paralist $para
		}
	}
	
	# set all of the parameters value
	foreach item1 $handlelist item2 $paralist {
		set $item1\_value $item2
	}
	
	# send command to SUT
	set getStr [exp1_send_cmd -spawnid $g_tnSutInfoArr($g_tnSutName,spawnid) -cmdlist $cmdStr]

	# get expect_out(buffer) array
	exp1_getstr -inputstr $getStr
	set retFullStr [string range $tnExp1StrArr(retstr) [expr [string last "----" $tnExp1StrArr(retstr)] + 5] end]
	regexp {\d\s*(\d)\s*\d\s*(\d)\s*\d\s*(\d)\s*\d\s*(\d)\s*\d\s*(\d)\s*\d\s*(\d)\s*\d\s*(\d)\s*\d\s*(\d)\s*} \
	$retFullStr match \
	showStr(pri0) showStr(pri1) showStr(pri2) showStr(pri3) \
	showStr(pri4) showStr(pri5) showStr(pri6) showStr(pri7)
	
	set errPara ""
	set chk 0
	for {set i 0} {$i <= 7} {incr i} {
		if {[info exist pri${i}_value]} {
			if {![string equal -nocase [set pri${i}_value] [set showStr(pri${i})]]} {
				incr chk
				lappend errPara "pri$i: [set showStr(pri${i})]"
			}
		}
	}
	
	if {$chk} {
		set res fail
	} else {
		set res pass
	}
	set logicRes [uCheckResult -actRes $res]
	printlog -fileid $tcLogId -res $logicRes -cmd "$cmdStr $args" -comment $errPara
	return $getStr
}

# C1|S10|L1D>show dot1dbridge ip-tc priority remapping 
# priority-index      traffic class       remapping-priority  
# ------------------------------------------------------------------------------------------------
# 0                   0                   0                   
# 1                   4                   0                   
# 2                   8                   0                      
# ...

# -pri0
# бн
# -pri63


proc showDot1dbridgeIptcPriorityRemapping {args} {
	global tnExp1StrArr tcLogId g_tnSutInfoArr g_tnSutName
	set args [split [join $args]]
	set cmdStr "show dot1dbridge ip-tc priority remapping"
	
	# get parameter handle and parameter value
	foreach {handle para} $args {
		if {[regexp {^-(.*)$} $handle all handleval]} {
			lappend handlelist $handleval
			lappend paralist $para
		}
	}
	
	# set all of the parameters value
	foreach item1 $handlelist item2 $paralist {
		set $item1\_value $item2
	}
	
	# send command to SUT
	set getStr [exp1_send_cmd -spawnid $g_tnSutInfoArr($g_tnSutName,spawnid) -cmdlist $cmdStr]

	# get expect_out(buffer) array
	exp1_getstr -inputstr $getStr
	set allNum [string range $getStr 200 4100]
	
	set allNumList [split [join $allNum]]
	set i 0
	foreach {priIdx trafficClass actPri} $allNumList {
		incr i
		set showStr(pri$i) $actPri
	}
	
	set errPara ""
	set chk 0
	for {set i 1} {$i <= 63} {incr i} {
		if {[info exist pri${i}_value]} {
			if {![string equal -nocase [set pri${i}_value] [set showStr(pri${i})]]} {
				incr chk
				lappend errPara "pri$i: [set showStr(pri${i})]"
			}
		}
	}
	
	if {$chk} {
		set res fail
	} else {
		set res pass
	}
	set logicRes [uCheckResult -actRes $res]
	printlog -fileid $tcLogId -res $logicRes -cmd "$cmdStr $args" -comment $errPara
	return $getStr
}


# C1|S10|L1P1>show fwd portlist 
# port-id             fwd portlist        mgmt access         
# -------------------------------------------------------------------------------
# 1                   2                   enable              
# C1|S10|L1P1>

# -portlist		string
proc showFwdPortlist {args} {
	global tnExp1StrArr tcLogId g_tnSutInfoArr g_tnSutName
	set args [split [join $args]]
	set cmdStr "show fwd portlist"
	
	# get parameter handle and parameter value
	foreach {handle para} $args {
		if {[regexp {^-(.*)$} $handle all handleval]} {
			lappend handlelist $handleval
			lappend paralist $para
		}
	}
	
	# set all of the parameters value
	foreach item1 $handlelist item2 $paralist {
		set $item1\_value $item2
	}
	
	# send command to SUT
	set getStr [exp1_send_cmd -spawnid $g_tnSutInfoArr($g_tnSutName,spawnid) -cmdlist $cmdStr]

	# get expect_out(buffer) array
	exp1_getstr -inputstr $getStr
	
	# get actual value of each parameters
	regexp {\d\s+(\S+)\s+} $getStr match showStr(portlist)
	
	set errPara ""
	set chk1 1
	if {[info exist portlist_value]} {
		if {[string first $portlist_value $showStr(portlist)] < 0} {
			set chk1 0
			lappend errPara "portlist: $showStr(portlist)"
		}
	}
	
	if {$chk1} {
		set res pass
	} else {
		set res fail
	}
	set logicRes [uCheckResult -actRes $res]
	printlog -fileid $tcLogId -res $logicRes -cmd "$cmdStr $args" -comment $errPara
	return $getStr
}




# C1|S1|L1D>show card info 
# System name:        IONMM
# Uptime:             27 days, 23:00:24
# CPU MAC:            00-c0-f2-20-de-9a
# Port number:        2
# Serial number:      SN-agent-001
# Config mode:        software
# Software:           0.6.5
# Bootloader:         1.2.0
# Hardware:           0.0.1

# -sysname
# -uptime
# -cpumac
# -portnum
# -serial
# -mode
# -swrev
# -blrev
# -hwrev
proc showCardInfo {args} {
	global tnExp1StrArr tcLogId g_tnSutInfoArr g_tnSutName
	set args [split [join $args]]
	set cmdStr "show card info"
	
	# get parameter handle and parameter value
	foreach {handle para} $args {
		if {[regexp {^-(.*)$} $handle all handleval]} {
			lappend handlelist $handleval
			lappend paralist $para
		}
	}
	
	# set all of the parameters value
	foreach item1 $handlelist item2 $paralist {
		set $item1\_value $item2
	}
	
	# send command to SUT
	set getStr [exp1_send_cmd -spawnid $g_tnSutInfoArr($g_tnSutName,spawnid) -cmdlist $cmdStr]

	# get expect_out(buffer) array
	exp1_getstr -inputstr $getStr
	
	# get actual value of each parameters
	regexp {System name:\s+(\S+)} 	$getStr match showStr(sysname)
	regexp {Uptime:\s+(\S+)} 		$getStr match showStr(uptime)
	regexp {CPU MAC:\s+(\S+)} 		$getStr match showStr(cpumac)
	regexp {Port number:\s+(\S+)} 	$getStr match showStr(portnum)
	regexp {Serial number:\s+(\S+)} $getStr match showStr(serial)
	regexp {Config mode:\s+(\S+)} 	$getStr match showStr(mode)
	regexp {Software:\s+(\S+)} 		$getStr match showStr(swrev)
	regexp {Bootloader:\s+(\S+)} 	$getStr match showStr(blrev)
	regexp {Hardware:\s+(\S+)} 		$getStr match showStr(hwrev)
	
	set errPara ""
	set chk1 1
	if {[info exist sysname_value]} {
		if {![string equal -nocase $sysname_value $showStr(sysname)]} {
			set chk1 0
			lappend errPara "sysname: $showStr(sysname)"
		}
	}
	set chk2 1
	if {[info exist uptime_value]} {
		if {![string equal -nocase $uptime_value $showStr(uptime)]} {
			set chk2 0
			lappend errPara "uptime: $showStr(uptime)"
		}
	}
	set chk3 1
	if {[info exist cpumac_value]} {
		if {![string equal -nocase $cpumac_value $showStr(cpumac)]} {
			set chk3 0
			lappend errPara "cpumac: $showStr(cpumac)"
		}
	}
	set chk4 1
	if {[info exist portnum_value]} {
		if {![string equal -nocase $portnum_value $showStr(portnum)]} {
			set chk4 0
			lappend errPara "portnum: $showStr(portnum)"
		}
	}
	set chk5 1
	if {[info exist serial_value]} {
		if {![string equal -nocase $serial_value $showStr(serial)]} {
			set chk5 0
			lappend errPara "serial: $showStr(serial)"
		}
	}
	set chk6 1
	if {[info exist mode_value]} {
		if {![string equal -nocase $mode_value $showStr(mode)]} {
			set chk6 0
			lappend errPara "mode: $showStr(mode)"
		}
	}
	set chk7 1
	if {[info exist swrev_value]} {
		if {![string equal -nocase $swrev_value $showStr(swrev)]} {
			set chk7 0
			lappend errPara "swrev: $showStr(swrev)"
		}
	}
	set chk8 1
	if {[info exist blrev_value]} {
		if {![string equal -nocase $blrev_value $showStr(blrev)]} {
			set chk8 0
			lappend errPara "blrev: $showStr(blrev)"
		}
	}
	set chk9 1
	if {[info exist hwrev_value]} {
		if {![string equal -nocase $hwrev_value $showStr(hwrev)]} {
			set chk9 0
			lappend errPara "hwrev: $showStr(hwrev)"
		}
	}
	
	if {$chk1} {
		set res pass
	} else {
		set res fail
	}
	set logicRes [uCheckResult -actRes $res]
	printlog -fileid $tcLogId -res $logicRes -cmd "$cmdStr $args" -comment $errPara
	return $getStr
}



# -str	checked str
# -str1	first string, default is 0
# -str2 second string, default is end
# return a string between str1 and str2 of the str
# getvalue -str "add vlan-db vid 100" -str1 add -str2 100
proc getvalue {args} {
	#1. get handle and parameter
	foreach {handle para} $args {
		if {[regexp {^-(.*)$} $handle all handleval]} {
			lappend handlelist $handleval
			lappend paralist $para
		}
	}
	if {[set validx [lsearch -glob $handlelist str]]!=-1} {
		set strval [lindex $paralist $validx]
	} else {
		puts "proc: getvalue, str is a mandatory parameter but missing, args: $args"
		exit
	}
	if {[set validx [lsearch -glob $handlelist str1]]!=-1} {
		set str1val [lindex $paralist $validx]
	} else {
		set str1idx 0
	}
	if {[set validx [lsearch -glob $handlelist str2]]!=-1} {
		set str2val [lindex $paralist $validx]
	} else {
		set str2idx end
	}
	if {[info exist str1val]} {
		set index1 [expr [string first $str1val $strval] +[string length $str1val]]
	} else {
		set index1 $str1idx
	}
	if {[info exist str2val]} {
		set index2 [expr [string first $str2val $strval]-1]
	} else {
		set index2 $str2idx
	}
	
	set res [string trim [string range $strval $index1 $index2]]
	return $res
}

# g_tnSutInfoArr($sutname_value,name)
# g_tnSutInfoArr($sutname_value,spawnid)
# g_tnSutInfoArr($sutname_value,ipaddr)
# g_tnSutInfoArr($sutname_value,port)

# -sutname
proc gotosut {args} {
	global g_tnSutInfoArr tcLogId g_tnSutName
	set cmdStr gotosut
	
	# get parameter handle and parameter value
	foreach {handle para} $args {
		if {[regexp {^-(.*)$} $handle all handleval]} {
			lappend handlelist $handleval
			lappend paralist $para
		}
	}
	
	# set all of the parameters value
	foreach item1 $handlelist item2 $paralist {
		set $item1\_value $item2
	}
	if {[info exist sutname_value]} {
		set g_tnSutName $g_tnSutInfoArr($sutname_value,name)
		printlog -fileid $tcLogId -res conf -cmd "$cmdStr $args, ip:$g_tnSutInfoArr($sutname_value,ipaddr)"
	}
}


