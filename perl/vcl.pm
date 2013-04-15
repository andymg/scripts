#!/usr/bin/perl -w
package vcl;

use SNMP;
use util;
my @tnVclMacBasedVlanId=('.1.3.6.1.4.1.868.2.5.4.1.8.1.1.1.2','VlanIndex','read-create');
my @tnVclMacBasedPortMember=('.1.3.6.1.4.1.868.2.5.4.1.8.1.1.1.3','PortList','read-create');
my @tnVclMacBasedUser=('.1.3.6.1.4.1.868.2.5.4.1.8.1.1.1.4','INTEGER','read-only');
my @tnVclMacBasedRowStatus=('.1.3.6.1.4.1.868.2.5.4.1.8.1.1.1.5','RowStatus','read-create');
my @tnVclProtoBasedGroupMapProtocol=('.1.3.6.1.4.1.868.2.5.4.1.8.2.1.1.2','INTEGER','read-create');
my @tnVclProtoBasedGroupMapEtherTypeVal=('.1.3.6.1.4.1.868.2.5.4.1.8.2.1.1.3','INTEGER','read-create');
my @tnVclProtoBasedGroupMapSnapOui=('.1.3.6.1.4.1.868.2.5.4.1.8.2.1.1.4','EightOTwoOui','read-create');
my @tnVclProtoBasedGroupMapSnapPid=('.1.3.6.1.4.1.868.2.5.4.1.8.2.1.1.5','INTEGER','read-create');
my @tnVclProtoBasedGroupMapLlcDsap=('.1.3.6.1.4.1.868.2.5.4.1.8.2.1.1.6','INTEGER','read-create');
my @tnVclProtoBasedGroupMapLlcSsap=('.1.3.6.1.4.1.868.2.5.4.1.8.2.1.1.7','INTEGER','read-create');
my @tnVclProtoBasedGroupMapRowStatus=('.1.3.6.1.4.1.868.2.5.4.1.8.2.1.1.8','RowStatus','read-create');
my @tnVclProtoBasedVlanMapPortMember=('.1.3.6.1.4.1.868.2.5.4.1.8.2.2.1.2','PortList','read-create');
my @tnVclProtoBasedVlanMapRowStatus=('.1.3.6.1.4.1.868.2.5.4.1.8.2.2.1.3','RowStatus','read-create');
my @tnVclIpSubnetBasedIpAddr=('.1.3.6.1.4.1.868.2.5.4.1.8.3.1.1.2','IpAddress','read-create');
my @tnVclIpSubnetBasedMaskLen=('.1.3.6.1.4.1.868.2.5.4.1.8.3.1.1.3','INTEGER','read-create');
my @tnVclIpSubnetBasedVlanId=('.1.3.6.1.4.1.868.2.5.4.1.8.3.1.1.4','VlanIndex','read-create');
my @tnVclIpSubnetBasedPortMember=('.1.3.6.1.4.1.868.2.5.4.1.8.3.1.1.5','PortList','read-create');
my @tnVclIpSubnetBasedRowStatus=('.1.3.6.1.4.1.868.2.5.4.1.8.3.1.1.6','RowStatus','');
my $ip = '127.0.0.1' #the default ip address

sub new {
    #init function for vcl module,DUT ip address is required.
    $ip = $_[0];
    my $ret = util::ispingable($ip);
    if ($ret) {
        print "Vcl is inited in : $ip\n";
    } else {
        print "Vcal init failed in :$ip\n";
    }


}
