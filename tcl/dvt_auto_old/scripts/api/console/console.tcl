proc captureconsole {args} {
	global spawn_id g_comConsoleID
	foreach checked_obj $args {
		if {[regexp {^-(.+)$} $checked_obj all used_option]} {
			lappend element_list $used_option
		}
	}
	foreach element $element_list {
		if {[regexp -- [subst {\-$element (.*?)( -|$)}] $args all detailvalue]} {
			set $element\_value $detailvalue
		} else {
			return fail
		}
	}
	if {[info exist baudrate_value]} {
		set baudrate $baudrate_value
	} else {
		set baudrate 115200
	}
	if {[info exist comport_value]} {
		set com_port $comport_value
		set newcomport "\\\\.\\com$comport_value"
		set f [open $newcomport w+]
		fconfigure $f -blocking 1 -buffering line -translation {auto binary} -mode $baudrate,n,8,1
		spawn -open $f
		set g_comConsoleID($com_port) $spawn_id
		set timeout 120
    send -i $g_comConsoleID($com_port) " \r"
    expect -i $g_comConsoleID($com_port) "*$"
	}
	if {[info exist filename_value]} {
		set fileid [open $filename_value w]
		set filename $filename_value
	}
	if {[info exist captureinterp_value]} {
		set timeout $captureinterp_value
	} else {
		set timeout 120
	}
	if {[info exist capturetime_value]} {
		set capture_time $capturetime_value
	} else {
		set capture_time 180
	}
	if {[info exist loguser_value]} {
		set logvalue $loguser_value
	} else {
		set logvalue 1
	}
	puts "\nstart to capture on console...\n"
	set start_time [clock seconds]		
	send -i $g_comConsoleID($com_port) " \r" 
	match_max 10000
	expect {
	     -re {([^ ]+)\n} {	     	      
	     	      set buf $expect_out(buffer)	
            	if {[string trim $buf] !="" } {
            			puts $fileid $buf	
              }
              set end_time [clock seconds]
              if {$capture_time != "" } {
            		if {$capture_time < [expr $end_time -$start_time]}  {
            			log_user $loguser_value
            			return
            		}
            	}
              exp_continue
            } 
        timeout {
            set end_time [clock seconds]
            	if {$capture_time != "" } {
            		if {$capture_time < [expr $end_time -$start_time]}  {
            			log_user $loguser_value
            			return
            		}
            	}
              exp_continue
            } eof {
              exp_continue
            }
  }
  log_user $logvalue
}

proc closecomport {args} {
   global spawn_id g_ConsoleID  
   if {[info exist channelid_value]} {
    	set channel_id $channelid_value
   } else {
    	set channel_id ""
   }
   if {$channel_id ==""} {
      close $g_ConsoleID
      unset g_ConsoleID
      unset spawn_id
   } else {
    	close $channel_id
   }
   after 3000
   puts "Disconnect from com port...\n" 
} 	
#package req Expect
#set fileid [open C:/project/TNAP/testout/ion2011april/markw/console.txt w]
#puts $fileid
#captureconsole -comport 7 -filename C:/project/TNAP/testout/ion2011april/markw/console.txt
#opencomport -comport 7
#startcapturecomport -comport 7 -filename C:/project/TNAP/testout/ion2011april/markw/console.txt -loguser 1
#closecomPort 


