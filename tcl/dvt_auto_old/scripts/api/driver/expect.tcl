# this file include all of the API of expect

# -fileid		string
# -timestamp	yes|no
# -info			string
# exp1_writelog -fileid file123 -info "the debug information" -timestamp yes
proc exp1_writelog {args} {


}



proc exp1_puts {str} {
	puts $str
}



# -ipaddr	the SUT's ip address
# -port		default value = 23
# return 	spawn_id
# exp1_connect -ipaddr 192.168.0.64 -port 23
proc exp1_connect {args} {
	set default_port 23
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
		exp1_puts "$timeStamp: exp1_connect, error, ipaddr is a mandatory parameter but missing"
		exp1_exit
	}
	
	if {[catch {exp_spawn telnet $ipaddr_value $default_port} err]} {
		exp1_puts "$timeStamp: exp1_connect, error, exp_spawn telnet $ipaddr_value $default_port\nerrorInfo: $err"
		exp1_exit
	} else {
		return $spawn_id
	}
}	
	
	
	
# -cmdlist	[string]	the command list that user want to send to SUT
# -expchar	[string]	the expected characters
# -after	[number]	the gap between two commands
# -offset1	[number]	the start offset of expect_out(buffer)
# -offset2	[number]	the end offset of expect_out(buffer)
# return: 	[string]	expect_out(buffer)
# exp1_send_cmd -spawnid $spawn_id -cmdlist ION -expchar Password:
proc exp1_send_cmd {args} {
	global g_exp1OutBuf g_exp1SpawnId g_tnSutInfoArr g_tnSutName
	# initialize default value
	set default_after 100;		# the default value of after time, the unit is ms
	set default_expChar >
	set default_offset1 0
	set default_offset2 0
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
	if {![info exist cmdlist_value]} {
		exp1_puts "$timeStamp: send_cmd, error, cmdlist is a mandatory parameter but missing"
		exp1_exit
	}
	if {[info exist after_value]} {
		after $after_value
	} else {
		after $default_after
	}
	if {[info exist expchar_value]} {
		set expChar $expchar_value
	} else {
		set expChar $default_expChar
	}
	if {[info exist offset1_value]} {
		set offset1 $offset1_value
	} else {
		set offset1 $default_offset1
	}
	if {[info exist offset2_value]} {
		set offset2 $offset2_value
	} else {
		set offset2 $default_offset2
	}
	
	# send a string or command to SUT
	set expect_out(buffer) ""
	after $::g_after
	if {[catch {exp_send -i $g_tnSutInfoArr($g_tnSutName,spawnid) "$cmdlist_value\r"} err]} {
		exp1_puts "$timeStamp: send_cmd, error, exp_send -i $g_tnSutInfoArr($g_tnSutName,spawnid) $cmdlist_value\nerrorInfo: $err"
		exp1_exit
	}
	
	# expected characters
	expect {
		-i $g_tnSutInfoArr($g_tnSutName,spawnid) $expChar 
			{
				set retStr [string range $expect_out(buffer) $offset1 end-$offset2]
				set g_exp1OutBuf $retStr
				return $retStr
			}
		-re $expChar 
			{
				set retStr [string range $expect_out(buffer) $offset1 end-$offset2]
				set g_exp1OutBuf $retStr
				return $retStr
			}
		timeout 
			{
				exp1_puts "$timeStamp: send_cmd, error, timeout -i $g_tnSutInfoArr($g_tnSutName,spawnid) $cmdlist_value"
				exp1_exit
			}
	}

}


# -spawnid	[string]		the configuration will apply to this spawn_id
# -timeout	[numerical]		the value of timeout
# -logUser	[1|0]			print the detail info on screen or not
# -maxNum	[numerical]		the value of expect's match_max
# -retry	[numerical]		retry times about one command, the gap between two command is: times*3s
# exp1_config -spawnid $expId -logUser 0 -maxNum 8000
proc exp1_config {args} {
	global timeout
	# initialize default value
	set default_timeout $::g_timeOut;		# the timeout time
	set default_logUser $::g_logUser; 		# do not print detail information on screen
	set default_maxNum 	$::g_maxNum; 		# the default value match_max
	set default_retry 	$::g_retryTimes;	# the default value of retry times

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
	
	# check and set dbgInfo
	if {[info exist timeout_value]} {
		set timeout $timeout_value
	} else {
		set timeout $default_timeout
	}
	
	# check and set logUser
	if {[info exist logUser_value]} {
		exp_log_user $logUser_value
	} else {
		exp_log_user $default_logUser
	}
	
	# check and set maxNum
	if {[info exist maxNum_value]} {
		exp_match_max -i $spawnid_value $maxNum_value
	} else {
		exp_match_max -i $spawnid_value $default_maxNum
	}
	
	# check and set retry
	if {[info exist retry_value]} {
		set retryTimes $retry_value
	} else {
		set retryTimes $default_retry
	}
	
	#exp1_puts "dateTime procName result information"
}


# -inputstr:   				input string
# tnExp1StrArr(clicmd): 		cli command list
# tnExp1StrArr(retstr): 		return string
# tnExp1StrArr(fullprompt): 	prompt
# tnExp1StrArr(sysname): 		system name
# tnExp1StrArr(prompt): 		real prompt
# tnExp1StrArr(retstrlen): 	real prompt
# exp1_getstr -inputstr $expect_out(buffer)
proc exp1_getstr {args} {
	global tnExp1StrArr
	
	# set array element value of tnExp1StrArr to empty
	set tnExp1StrArr(clicmd) 		""
	set tnExp1StrArr(fullprompt)	""
	set tnExp1StrArr(retstr) 		""
	set tnExp1StrArr(retstrlen) 	""
	set tnExp1StrArr(sysname) 		""
	set tnExp1StrArr(prompt) 		""
	
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
	if {![info exist inputstr_value]} {
		exp1_puts "$timeStamp: exp1_getstr, error, inputstr is a mandatory parameter but missing"
		exp1_exit
	}
	
	set fullStr   	[string trim $inputstr_value]
	#puts "*****\n$fullStr\n*****"
	set firstFlag	[string first \n $fullStr]
	set lastFlag  	[string last \n $fullStr]
	
	set tnExp1StrArr(clicmd) 		[string trim [string range $fullStr 0 $firstFlag]]
	set tnExp1StrArr(fullprompt) 	[string trim [string range $fullStr $lastFlag end]]
	set tnExp1StrArr(retstr)		[string trim [string range $fullStr $firstFlag $lastFlag]]
	set tnExp1StrArr(retstrlen)		[string length $tnExp1StrArr(retstr)]
	set promptBlankFlag				[string first " " $tnExp1StrArr(fullprompt)]
	set tnExp1StrArr(sysname)		[string trim [string range $tnExp1StrArr(fullprompt) 0 $promptBlankFlag]]
	set tnExp1StrArr(prompt)		[string trim [string range $tnExp1StrArr(fullprompt) $promptBlankFlag end]]
}


# exist tcl interpreter
proc exp1_exit {} {
	exit
}

# -spawnid
# exp1_close -spawnid $sut1
proc exp1_close {args} {

}

# -fileid 	optional, if no this optional, print to screen directly
# -buffer	yes|no
# -bufarr	yes|no
# exp1_printbuffer -fileid 
proc exp1_printbuffer {args} {
	global g_exp1OutBuf tnExp1StrArr
	set timeStamp [clock format [clock seconds] -format "%H:%M:%S"]
	

}
