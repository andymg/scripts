#Owner: King Lan

proc ratelimit_copper_0_para {} {
	set ::sutIp 	192.168.0.62
	set ::sutSlot1 	18
	set ::sutSlot2 	19
	set ::sutSlot3 	16
	set ::ixiaIP 	192.168.0.21
	set ::ixiaP1 	4,1
	set ::ixiaP2 	4,2
	set ::ixiaP3 	2,2
	set ::ixiaP4 	2,3
	set ::diff		0.2
	set ::slot1P1   1
	set ::slot1P2   2
	set ::slot2P1   1
	set ::slot2P2   2
	set ::slot3P2   2
	set ::slot3P3   3
}

proc ratelimit_copper_1_para {} {
	set ::irate "rate900M rate800M rate700M rate600M rate500M rate400M rate300M rate200M rate100M \
	                rate90M rate80M rate70M rate60M rate50M rate40M rate30M rate20M rate10M \
					rate9M rate8M rate7M rate6M rate5M rate4M rate3M rate2M rate1M"
}

proc ratelimit_copper_2_para {} {
	set ::erate "rate900M rate800M rate700M rate600M rate500M rate400M rate300M rate200M rate100M \
	                rate90M rate80M rate70M rate60M rate50M rate40M rate30M rate20M rate10M \
					rate9M rate8M rate7M rate6M rate5M rate4M rate3M rate2M rate1M"
}
proc ratelimit_copper_3_para {} {
	set ::irate "rate90M rate80M rate70M rate60M rate50M rate40M rate30M rate20M rate10M \
					rate9M rate8M rate7M rate6M rate5M rate4M rate3M rate2M rate1M"
}
proc ratelimit_copper_4_para {} {
	set ::erate "rate90M rate80M rate70M rate60M rate50M rate40M rate30M rate20M rate10M \
					rate9M rate8M rate7M rate6M rate5M rate4M rate3M rate2M rate1M"
}
proc ratelimit_copper_5_para {} {
	set ::irate "rate9M rate8M rate7M rate6M rate5M rate4M rate3M rate2M rate1M"
}
proc ratelimit_copper_6_para {} {
	set ::erate "rate9M rate8M rate7M rate6M rate5M rate4M rate3M rate2M rate1M"
}
proc ratelimit_copper_7_para {} {
}
proc ratelimit_copper_8_para {} {
}
proc ratelimit_fiber_21_para {} {
	set ::irate "rate900M rate800M rate700M rate600M rate500M rate400M rate300M rate200M rate100M \
	                rate90M rate80M rate70M rate60M rate50M rate40M rate30M rate20M rate10M \
					rate9M rate8M rate7M rate6M rate5M rate4M rate3M rate2M rate1M"
}
proc ratelimit_fiber_22_para {} {
	set ::erate "rate900M rate800M rate700M rate600M rate500M rate400M rate300M rate200M rate100M \
	                rate90M rate80M rate70M rate60M rate50M rate40M rate30M rate20M rate10M \
					rate9M rate8M rate7M rate6M rate5M rate4M rate3M rate2M rate1M"
}
proc ratelimit_fiber_23_para {} {
	set ::irate "rate90M rate80M rate70M rate60M rate50M rate40M rate30M rate20M rate10M \
					rate9M rate8M rate7M rate6M rate5M rate4M rate3M rate2M rate1M"
}
proc ratelimit_fiber_24_para {} {
	set ::erate "rate90M rate80M rate70M rate60M rate50M rate40M rate30M rate20M rate10M \
					rate9M rate8M rate7M rate6M rate5M rate4M rate3M rate2M rate1M"
}
proc ratelimit_fiber_25_para {} {
	set ::irate "rate9M rate8M rate7M rate6M rate5M rate4M rate3M rate2M rate1M"
}
proc ratelimit_fiber_26_para {} {
	set ::erate "rate9M rate8M rate7M rate6M rate5M rate4M rate3M rate2M rate1M"
}