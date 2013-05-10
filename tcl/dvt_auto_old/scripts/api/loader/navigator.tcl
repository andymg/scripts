# dispatcher center, all of the process about load scripts, 
# execute testing, and do some actions after finish a testing

# -tester		str				mandatory		default: null
# -prjname		str				mandatory		default: null
# -tsname		str				mandatory		default: null
# -uploadres	yes|no			optional		default: no
# -errorstop	yes|no			optional		default: no			?????????????
# -tclist		list			optional		default: all
# runTs -tester markw -prjname ion2011april -tsname testsuit_vlan2.tcl
proc runTestSuit {args} {
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
	
	# check all parameters value
	if {![info exist tester_value]} {
		uWriteExp -cmdname runTs -errorinfo "tester is a mandatory parameter but missing"
	}
	if {![info exist prjname_value]} {
		uWriteExp -cmdname runTs -errorinfo "prjname is a mandatory parameter but missing"
	}
	if {![info exist tsname_value]} {
		uWriteExp -cmdname runTs -errorinfo "tsname is a mandatory parameter but missing"
	}
	if {![info exist uploadres_value]} {
		set uploadres_value no
	}
	if {![info exist errorstop_value]} {
		set errorstop_value no
	}
	if {![info exist tclist_value]} {
		set tclist_value all
	}
	
	# generate the directory
	set tsParaDir	./testsuits/$prjname_value/$tsname_value/
	set tsDir		./testsuits/$prjname_value/$tsname_value/
	set logDir 		"./testout/${prjname_value}/${tester_value}/"
	#set dtStamp 	[clock format [clock seconds] -format "%Y%m%d_%H%M%S"]
	set dbgLogName 	${tsname_value}_debug.log
	set tsLogName 	${tsname_value}_caselog.txt
	
	# load test suits and test para
	loader $tsParaDir${tsname_value}_para.tcl $tsDir${tsname_value}.tcl
	
	# archive the old logs to archive folder
	uSaveOldLogs -project $prjname_value -tester $tester_value
	
	# create debug log file, case log file and case run status file
	uCreateFile -dir $logDir -logname $dbgLogName -fileid dbgLogId
	uCreateFile -dir $logDir -logname $tsLogName -fileid tcLogId 
	
	# print test suit headline
	printTsInfo2CaseLog -fileid $::tcLogId -project $prjname_value -tsname $tsname_value -tester $tester_value
	
	# get test case name list according tclist_value
	if {![string equal $tclist_value all]} {
		set tclistval [split $tclist_value ,]
		foreach range $tclistval {
			if {[regexp {(\d+)-(\d+)} $range all firstnum secondnum]} {
				for {set i $firstnum} {$i<=$secondnum} {incr i} {
					lappend actTcList $i
				}
			} else {
				lappend actTcList $range
			}
		}
	}
	
	# get all procedure from test suits file
	set allTcListInFile [getTcList -filedir $tsDir -filename ${tsname_value}.tcl]
	
	# run test case one by one
	if {[info exist actTcList]} {
		# run test cases according actTcList
		foreach tcNum $actTcList {
			if {[regexp [subst {\\w+_$tcNum}] $allTcListInFile tc]} {
				set tcName $tc
				set t_errorInfo $::errorInfo
				catch {eval [append tc _para]}
				set ::errorInfo $t_errorInfo
				runTc -casename $tcName
			}
		}
	} else {
		# run all test cases
		foreach tc $allTcListInFile {
			set tcName $tc
			set t_errorInfo $::errorInfo
			catch {eval [append tc _para]}
			set ::errorInfo $t_errorInfo
			runTc -casename $tcName
		}
	}
}

# -casename		casename	default: null
# -beginflag	yes|no		default: yes
# -endflag		yes|no		default: yes
# runtestcase -casename vlan1 -beginflag yes -endflag no
proc runTc {args} {
	global dbgLogId tcLogId
	
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
	
	# check all parameters value
	if {![info exist casename_value]} {
		uWriteExp -cmdname runTc -errorinfo "casename is a mandatory parameter but missing"
	}
	if {![info exist beginflag_value]} {
		set beginflag_value yes
	}	
	if {![info exist endflag_value]} {
		set endflag_value yes
	}
	
	#print start flag
	if {[string equal -nocase $beginflag_value yes]} {
		printCaseFlag -fileid $tcLogId -type start -casename $casename_value
	}
	# execute test case
	eval $casename_value
	# print end flag
	if {[string equal -nocase $endflag_value yes]} {
		printCaseFlag -fileid $tcLogId -type end -casename $casename_value
	}
}

# -filedir
# -filename
# return a list of all test case's name
# getcasename -filedir ./testsuits/ion2011april/ -filename testsuit_vlan2.tcl 
proc getTcList {args} {
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

	# check all parameters value
	if {![info exist filedir_value]} {
		uWriteExp -cmdname getTcList -errorinfo "filedir is a mandatory parameter but missing"
	}
	if {![info exist filename_value]} {
		uWriteExp -cmdname getTcList -errorinfo "filename is a mandatory parameter but missing"
	}
	
	# read file and get line which start with proc
	if {[catch {set channel [open $filedir_value$filename_value r]} err]} {
		uWriteExp -cmdname getTcList -errorinfo "open file: $filedir_value$filename_value failed, \nerrorInfo: $err"
	} else {
		while {![eof $channel]} {
		  set lineval [gets $channel]
		  if {[regexp {^\s*proc\s+(\S+)\s+\{} $lineval all casename]} {
		  lappend caselistval $casename
		  }
		}
		close $channel
	}
	return $caselistval
}

# -fileid		str				mandatory
# -type			begin|end		mandatory
# -casename		str				mandatory
# printcaseflag -fileid fileid -type start -casename casename
proc printCaseFlag {args} {
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

	# check all parameters value
	if {![info exist fileid_value]} {
		uWriteExp -cmdname printCaseFlag -errorinfo "fileid is a mandatory parameter but missing"
	}
	if {![info exist type_value]} {
		uWriteExp -cmdname printCaseFlag -errorinfo "type is a mandatory parameter but missing"
	}
	if {![info exist casename_value]} {
		uWriteExp -cmdname printCaseFlag -errorinfo "casename is a mandatory parameter but missing"
	}
	
	#set keystr [string toupper "#@@:: $casename_value $type_value"]
	set keystr "#@@:: $casename_value $type_value"
	
	if {[string equal $type_value end]} {
		append keystr \n
	}
	
	puts $keystr
	if {[catch {puts $fileid_value $keystr; flush $fileid_value} err]} {
		uWriteExp -cmdname printCaseFlag -errorinfo "write file failed: args: $args, errorInfo: $err"
	}
}

# print test case name to file
# ts_1: xxx			0
# 	tc_1_1: xxx		0
#	tc_1_2: xxx		0
# ts_2: xxx			0
# 	tc_2_1: xxx		0
#	tc_2_2: xxx		0
proc printTcList2File {args} {
	
}

# update test case result to result file
# 0: not run
# 1: running
# 2: pass
# 3: fail
# 4: abnormal stoped
proc updateTcRes {args} {
	
}

# print basic test case information to test case log
# -fileid
# -project
# -tsname
# -tester
# ******************************************
# DVT Automated Testing Detail Report
# Project:   ion2011April
# Test Suit: vlan
# tester:    markw
# date:      2011-7-21
# ******************************************
# printTsInfo2CaseLog -fileid x -project x -tsname x -tester x -date x
proc printTsInfo2CaseLog {args} {
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
	
	set dStamp [clock format [clock seconds] -format "%Y-%m-%d"]
	
	set l1 "# ******************************************"
	set l2 "# DVT Automated Testing Detail Report"
	set l3 "# Project:   $project_value"
	set l4 "# Test Suit: $tsname_value"
	set l5 "# Tester:    $tester_value"
	set l6 "# Date:      $dStamp"
	set l7 "# ******************************************"
	set l8 "\n"
	
	set printList [list $l1 $l2 $l3 $l4 $l5 $l6 $l7 $l8]
	
	foreach item $printList {
		if {[catch {puts $fileid_value $item; flush $fileid_value; puts $item} err]} {
			uWriteExp -cmdname printTsInfo2CaseLog -errorinfo "write file failed: args: $args, errorInfo: $err"
		}
		after 30
	}
}

# start a TCL command line interface, the input command will be save to a designate file
# -tester
# -logdir
# -codedir
proc runCLI {args} {
	
}