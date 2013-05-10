# #uGetSysNameFromPrompt "123sdfsd C1|S3|L1D>"
# #return: 123sdfsd
# proc uGetSysNameFromPrompt {prompt} {
	# set len [string length $prompt]
	# set seperator [string last " " $prompt]
	# set sysName [string range $prompt 0 [expr $seperator - 1]]
	# return $sysName
# }

# #uGetSuffixFromPrompt "123sdfsd C1|S3|L1D>"
# #return: C1|S3|L1D>
# proc uGetSuffixFromPrompt {prompt} {
	# set len [string length $prompt]
	# set seperator [string last " " $prompt]
	# set suffix [string range $prompt [expr $seperator + 1] end]
	# return $suffix
# }

# -errorstop yes/no	default:yes
# -errorinfo
# -cmdname
# uPrtExp -errorinfo "send command error: $cmdlist"
proc uWriteExp {args} {
	# get command and handle/parameters
	foreach {handle para} $args {
		if {[regexp {^-(.*)$} $handle all handleval]} {
			lappend handlelist $handleval
			lappend paralist $para
		}
	}
	foreach item1 $handlelist item2 $paralist {
		set $item1\_value $item2
	}
	
	if {[info exist errorstop_value]} {
		if {[string equal -nocase $errorstop_value yes] == 1} {
			set stopFlag 1
		} else {
			set stopFlag 0
		}
	} else {
		set stopFlag 1
	}
	if {![info exist cmdname_value]} {
		set cmdname_value ""
	}
	
	# print trace start flag
	set traceStartStr "*************** DVT Auto Test Tcl Trace Start ***************"
	puts $traceStartStr
	uWriteDbgLog -fileid $::dbgLogId -cmdname "" -loginfo $traceStartStr
	
	# print user define error info
	if {[info exist errorinfo_value]} {
		set startStr "@@@@@user define error info:"
		puts $startStr
		uWriteDbgLog -fileid $::dbgLogId -cmdname "" -loginfo $startStr
		
		puts $errorinfo_value
		uWriteDbgLog -fileid $::dbgLogId -cmdname "" -loginfo $errorinfo_value
	}
	
	# print error information
	set startStr "@@@@@error information:"
	puts $startStr
	uWriteDbgLog -fileid $::dbgLogId -cmdname "" -loginfo $startStr
	puts $::errorInfo
	uWriteDbgLog -fileid $::dbgLogId -cmdname "" -loginfo $::errorInfo

	
	# print invoking information
	set startStr "@@@@@invoking information"
	puts $startStr
	uWriteDbgLog -fileid $::dbgLogId -cmdname "" -loginfo $startStr
	set tracer ""
	while {1} {
		if [catch {info level $i} ] {
			break
		} else {
			set level$i [info level -$i]
			set tracer [linsert $tracer 0 -> \n "[set level$i]" ] 
		}
		incr i
	}
	puts $tracer
	uWriteDbgLog -fileid $::dbgLogId -cmdname "" -loginfo $tracer
	
	# print trace end flag
	set traceEndStr "*************** DVT Auto Test Tcl Trace End ***************"
	puts $traceEndStr
	uWriteDbgLog -fileid $::dbgLogId -cmdname "" -loginfo $traceEndStr
	
	
	
	# # print errorInfo
	# set startStr "the following information are errorInfo:"
	# puts $startStr
	# uWriteDbgLog -fileid $::dbgLogId -cmdname $cmdname_value -loginfo $startStr
	# puts $::errorInfo
	# uWriteDbgLog -fileid $::dbgLogId -cmdname $cmdname_value -loginfo $::errorInfo
	# set errorInfo ""
	
	# # print invoking information
	# set startStr: "the following inforamtion are invoking process:"
	# puts $startStr
	# uWriteDbgLog -fileid $::dbgLogId -cmdname $cmdname_value -loginfo $startStr
	# while {1} {
		# if [catch {info level $i} ] {
			# break
		# } else {
			# set level$i [info level -$i]
			# set tracer [linsert $tracer 0 -> \n "[set level$i]" ] 
		# }
		# incr i
	# }
	# puts $tracer
	# uWriteDbgLog -fileid $::dbgLogId -cmdname $cmdname_value -loginfo $tracer
	
	# # print trace end flag
	# set traceEndStr "*************** DVT Auto Test Tcl Trace End ***************"
	# puts $traceEndStr
	# uWriteDbgLog -fileid $::dbgLogId -cmdname $cmdname_value -loginfo $traceEndStr
	
	if $stopFlag {
		exit
	}
}

# -dir:		c:/test/abc/
# -logname	testlog.log
# -fileid 	dbgLogId|tcLogId
# return fileid
# uCreateFile -dir ./ -logname test.log -fileid abc
proc uCreateFile {args} {
	# get command and handle/parameters
	foreach {handle para} $args {
		if {[regexp {^-(.*)$} $handle all handleval]} {
			lappend handlelist $handleval
			lappend paralist $para
		}
	}
	foreach item1 $handlelist item2 $paralist {
		set $item1\_value $item2
	}
	
	# check the directory, create a new one of it not existed
	if {![file exist $dir_value]} {
		file mkdir $dir_value
	}
	
	# generate datatime stamp and log directory
	set dtStamp [clock format [clock seconds] -format "%Y%m%d_%H%M%S"]
	set logDir "${dir_value}${dtStamp}_$logname_value"
	
	# create a file
	if {[catch {
		set fileId [open $logDir a+]
		fconfigure $fileId -buffering line
	} err]} {
		puts "uCreateFile, create file failed: args: $args, errorInfo: $err"
		exit
	}
	
	eval [subst {uplevel #0 {set $fileid_value $fileId}}]
	return $fileId
}

# only used for write debug log
# -fileid
# -cmdname
# -loginfo
# uWriteLog -fileid $abc -cmdname "this is a test log" -loginfo "this is log info"
proc uWriteDbgLog {args} {
	# get command and handle/parameters
	foreach {handle para} $args {
		if {[regexp {^-(.*)$} $handle all handleval]} {
			lappend handlelist $handleval
			lappend paralist $para
		}
	}
	foreach item1 $handlelist item2 $paralist {
		set $item1\_value $item2
	}
	
	set dtStamp [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]
	set writeLogStr "$dtStamp: "
	if {[info exist cmdname_value] && [string length $cmdname_value] > 0} {
		set pNameStr "cmd: $cmdname_value, "
		append writeLogStr $pNameStr
	}
	if {![info exist loginfo_value]} {
		puts "uWriteDbgLog: loginfo is a mandatory parameter but missing"
		exit
	} else {
		append writeLogStr $loginfo_value
	}
	
	if {[catch {puts $fileid_value $writeLogStr; flush $fileid_value} err]} {
		puts "uWriteLog, write debug log failed: args: $args, errorInfo: $err"
		exit
	}

}

# -fileid
# closefile -fileid $abc
proc uCloseFile {args} {
	# get command and handle/parameters
	foreach {handle para} $args {
		if {[regexp {^-(.*)$} $handle all handleval]} {
			lappend handlelist $handleval
			lappend paralist $para
		}
	}
	foreach item1 $handlelist item2 $paralist {
		set $item1\_value $item2
	}
	
	if {![info exist fileid_value]} {
		puts "uCloseFile: fileid is a mandatory parameter but missing"
	}
	
	if {[catch {close $fileid_value} err]} {
		puts "uCloseFile, close file failed, args: $args, errorInfo: $err"
	}
}


# move the old log files to archive folder 
# -project
# -tester
proc uSaveOldLogs {args} {
	# get command and handle/parameters
	foreach {handle para} $args {
		if {[regexp {^-(.*)$} $handle all handleval]} {
			lappend handlelist $handleval
			lappend paralist $para
		}
	}
	foreach item1 $handlelist item2 $paralist {
		set $item1\_value $item2
	}
	
	set logDir "./testout/${project_value}/${tester_value}"
	set archiveDir "./testout/${project_value}/${tester_value}/archive"
	file mkdir $archiveDir
	set logFileList [glob -nocomplain $logDir/*.txt]
	lappend logFileList [glob -nocomplain $logDir/*.log]
	
	if {[llength $logFileList] >= 2} {
		for {set i 0} {$i<[llength $logFileList]} {incr i} {
			set logFile [lindex $logFileList $i]
			file rename -force  $logFile $archiveDir
		}
	}
}

# input: show vlan-db config -vid 100 -port1 unTag
# output: show vlan-db config
proc uGetCmdStr {fullcmd {prefix ""}} {
	set idx [string first " -" $fullcmd]
	if {$idx <= 0} {
		set cmdStr $fullcmd
	} else {
		set cmdStr [string trim [string range $fullcmd 0 $idx]]
	}
	
	if {[string length $prefix] > 0} {
		set cmdStr1 [append prefix " " $cmdStr]
	}
	return $cmdStr1
}

# input: show vlan-db config -vid 100 -port1 unTag
# output: -vid 100 -port1 unTag
proc uGetCmdPara {fullcmd} {
	set idx [string first " -" $fullcmd]
	if {$idx <= 0} {
		set cmdPara ""
	} else {
		set cmdPara [string trim [string range $fullcmd $idx end]]
	}
	return $cmdPara
}


# -actRes pass
# uCheckResult -actRes pass
proc uCheckResult {args} {
	global g_expres

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

	# expres 	actres		retres
	# pass		pass		pass
	# pass		fail		fail
	# fail		pass		fail
	# fail		fail		pass
	if {[info exist actRes_value]} {
		if {[string equal -nocase $g_expres $actRes_value]} {
			set res pass
		} else {
			set res fail
		}
		return $res
	}
}

# set the expected result value and whether print log
# -printlog
# -expres
# uController -printlog yes -expres pass
proc uController {args} {
	
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
	
	if {[info exist printlog_value]} {
		if {[string equal -nocase $printlog_value yes]} {
			set ::g_printlog yes
		} elseif {[string equal -nocase $printlog_value no]} {
			set ::g_printlog no
		}
	}
	
	if {[info exist expres_value]} {
		if {[string equal -nocase $expres_value pass]} {
			set ::g_expres pass
		} elseif {[string equal -nocase $expres_value fail]} {
			set ::g_expres fail
		}
	}
}

