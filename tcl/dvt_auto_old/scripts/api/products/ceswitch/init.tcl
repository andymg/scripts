#!/bin/tcl
# filename :init.tcl
# purpose  cllect all ceswitch source file together

if {[catch [source ./util.tcl]]} {
	puts "Error:util.tcl is not find in ceswitch folder"
}
if {[catch [source ./vcl.tcl]]} {
	puts "Error:vcl.tcl is not found in ceswitch folder df"
}
if {[catch [source ./ipmc.tcl]]} {
	puts "Error:ipmc.tcl is not found in ceswitch folder"
}

global ::session ""
set dut 192.168.4.16
set community private
set ::session "-v2c -c $community $dut"
set ::portNo [getPortNo $dut]
