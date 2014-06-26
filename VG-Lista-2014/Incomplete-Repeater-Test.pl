#!/usr/bin/perl -w

use warnings;
use strict;
use Time::HiRes qw/time usleep/;
use Socket qw(:all);
use POSIX ":sys_wait_h";
my $lasttime = "ha"; 

sub send_artnet {
	my ($uni, $payload) = $_;

#	my $payload  = "\x41\x72\x74\x2d\x4e\x65\x74\x00"; #artnet header
#	   $payload .= "\x00\x50"; #opcode
#	   $payload .= "\x00\x5e"; #prover
#	   $payload .= "\x00\x00"; #sec+phys
#	   $payload .= chr($uni)."\x00"; #uni
#	   $payload .= "\x02\x00"; #len	   

		socket( SOCKET, PF_INET, SOCK_DGRAM, getprotobyname("udp") )
		    or die "Error: can't create an udp socket: $!\n";
		
		select( ( select(SOCKET), $|=1 )[0] ); # no suffering from buffering
		
		my $broadcastAddr = sockaddr_in( 6454, inet_aton("255.255.255.255"));
		setsockopt( SOCKET, SOL_SOCKET, SO_BROADCAST, 1 );


	   send( SOCKET, $payload, 0,  $broadcastAddr ) or die "Error at sendding: $!\n";

	   close SOCKET;

}
	

socket( UDPSOCK, PF_INET, SOCK_DGRAM, getprotobyname('udp') ) or die "
+socket: $!";

select( ( select(UDPSOCK), $|=1 )[0] ); # no suffering from buffering

setsockopt( UDPSOCK, SOL_SOCKET, SO_REUSEADDR, 1 )
    or die "setsockopt SO_REUSEADDR: $!";
setsockopt( UDPSOCK, SOL_SOCKET, SO_BROADCAST, 1 )
    or die "setsockopt SO_BROADCAST: $!";

my $broadcastAddrH = sockaddr_in( 6454, INADDR_ANY );
bind( UDPSOCK, $broadcastAddrH ) or die "bind failed: $!\n";

my $input;
my $uni = {};

while( my $addr = recv( UDPSOCK, $input, 4096, 0 ) ) {
	my ($port, $hisiaddr) = sockaddr_in($addr);
	my $host = gethostbyaddr($hisiaddr, AF_INET);

	if ($host eq "catalyst") {

		$uni->{ord(substr($input, 14, 1))} = $input;

		send_artnet(ord(substr($input, 14, 1)), $input);			
		send_artnet(ord(substr($input, 14, 1)), $input);			
		send_artnet(ord(substr($input, 14, 1)), $input);			
		send_artnet(ord(substr($input, 14, 1)), $input);			
	}

}









