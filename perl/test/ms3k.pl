#!/usr/bin/perl
use Data::Dumper;
use SNMP;

# Hard-coded hostname and community.  This is icky, but I didn't want to 
# muddle the example with parsing command line arguments.  Deal with it. -r
#
sub usage {
    print  "./ms3k.pl ipaddress mib-oid loop-counter\n";
    exit 0;
}
my $hostname= shift || usage();
my $oid = shift || usage();
my $cnt = shift || 1;
my $port='161';
my $community='public';

$sess = new SNMP::Session( 'DestHost'	=> $hostname,
			   'Community'	=> $community,
			   'RemotePort'	=> $port,
			   'Timeout'	=> 300000,
			   'Retries'	=> 3,
			   'Version'	=> '2c',
			   'UseLongNames' => 1,	   # Return full OID tags
			   'UseNumeric' => 1,	   # Return dotted decimal OID
			   'UseEnums'	=> 0,	   # Don't use enumerated vals
			   'UseSprintValue' => 0); # Don't pretty-print values

die "Cannot create session: ${SNMP::ErrorStr}\n" unless defined $sess;

my %hash = ();

sub poller {  
    my ($sess, $index, $vlist) = @_;
    
    if(!defined($vlist)) { die "can not read vlist\n";}
    print "index:$index  var = " . $vlist->[0]->val, "\n";
    delete $hash{$index};
} 

# Initialize the MIB (else you can't do queries).
&SNMP::initMib();
#$ENV{'MIBS'}="ALL";  #Load all available MIBs

foreach (1..$cnt) {
    $sess->get($oid, [\&poller, $sess, $_]);    
    $hash{$_} = $_;
}

my $counter = 0;
foreach (1..20) {
    sleep 1;
    $counter = $_;
    SNMP::MainLoop(-1);
    if(scalar (keys %hash) == 0) {
	last;
    }
}

print "missed " . scalar (keys %hash) .
    " spent $counter seconds.\n";

