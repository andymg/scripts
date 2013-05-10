#!/usr/bin/tclsh

package provide netsnmp 1.0
namespace eval netsnmp {
    namespace export *
}

proc snmpset {} {
    puts "test snmpset"
}
proc snmpget {} {
    puts "test snmpget"
}
