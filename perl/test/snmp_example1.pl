#!/usr/bin/perl

#Whew! That's a lot of code just for a couple of simple queries!
#There are a lot of comments, and the code demonstrates the two most common ways of getting SNMP data from an agent
#(single query or loop through some unknown number of instances). Your coding style may be more succint, 
#and you may not need some of the error checking. Proceed without it at your own peril, though. 

use warnings;
use strict;
use SNMP;
use Socket;

# VARIABLES YOU SHOULD EDIT.
my $comm = 'public';    # EDIT ME!
my $dest = 'localhost'; # EDIT ME!
my $mib  = 'sysDescr';  # Toy with this to get different
                        # results.
my $sver = '2';         # EDIT ME!

# VARIABLES YOU SHOULD LEAVE ALONE.
my $sess; # The SNMP::Session object that does the work.
my $var;  # Used to hold the individual responses.
my $vb;   # The Varbind object used for the 'real' query.

# Initialize the MIB (else you can't do queries).
&SNMP::initMib();

my %snmpparms;
$snmpparms{Community} = $comm;
$snmpparms{DestHost} = inet_ntoa(inet_aton($dest));
$snmpparms{Version} = $sver;
$snmpparms{UseSprintValue} = '1';
$sess = new SNMP::Session(%snmpparms);

# Turn the MIB object into something we can actually use.
$vb = new SNMP::Varbind([$mib,'0']); # '0' is the instance.

$var = $sess->get($vb); # Get exactly what we asked for.
if ($sess->{ErrorNum}) {
  die "Got $sess->{ErrorStr} querying $dest for $mib.\n";
  #Done as a block since you may not always want to die in here.You could set up another query,just go on,
  # or whatever...
}
print $vb->tag, ".", $vb->iid, " : $var\n";

# Now let's show a MIB that might return multiple instances.
$mib = 'ipNetToMediaPhysAddress'; # The ARP table!
$vb = new SNMP::Varbind([$mib]);  # No instance this time.

# I prefer this loop method.  YMMV.
for ( $var = $sess->getnext($vb);
      ($vb->tag eq $mib) and not ($sess->{ErrorNum});
      $var = $sess->getnext($vb)
    ) {
  print $vb->tag, ".", $vb->iid, " : ", $var, "\n";
}
if ($sess->{ErrorNum}) {
  die "Got $sess->{ErrorStr} querying $dest for $mib.\n";
}

exit;
