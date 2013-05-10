# load all of the scripts before execute testing

# 1. startrun			the user interface to start automated testing
# 2. loader				load all scripts
# 3. config				the default value of all parameters
# 4. api				include all kinds of API
	# 4.1 driver		the expect and utility library
	# 4.2 database		the database(mysql) library
	# 4.3 analyzer		the analyzer(ixia) library
	# 4.4 console		the console port library
	# 4.5 testlink		the testlink library
	# 4.6 products		the product library
# 5. testsuits (it will be loaded in runTestSuit)
	# 5.1 testpara		the test cases' parameters
	# 5.2 testsuit		the testcase library
# 6. navigator			how to run scripts
	
package require Expect	

# load source scripts to memory
proc loader {args} {
	foreach dir $args {
		if {[catch {source $dir} err]} {
			puts "load $dir failed!\nerrorInfo: $err"
			exit
		}
	}
}

set configDir 	./config/config.tcl
set expectDir 	./api/driver/expect.tcl
set utilityDir 	./api/driver/utility.tcl
set ixiaDir		./api/analyzer/ixia/ixia.tcl
set consoleDir	./api/console/console.tcl
set productDir	./api/products/ion/sutapi.tcl
set nvgtrDir	./api/loader/navigator.tcl

loader $configDir $expectDir $utilityDir $ixiaDir $consoleDir $productDir $nvgtrDir
set ::errorInfo ""



