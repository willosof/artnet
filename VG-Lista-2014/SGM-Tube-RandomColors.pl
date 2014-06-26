#!/usr/bin/perl -w

use warnings;
use strict;
use Time::HiRes qw/time usleep/;
use Socket qw(:all);
use POSIX ":sys_wait_h";

my $colorblack = "";
my $colorwhite = "";

my $lasttime = "ha"; 
socket( SOCKET, PF_INET, SOCK_DGRAM, getprotobyname("udp") )
    or die "Error: can't create an udp socket: $!\n";

select( ( select(SOCKET), $|=1 )[0] ); # no suffering from buffering

my $broadcastAddr = sockaddr_in( 6454, inet_aton("255.255.255.255"));
setsockopt( SOCKET, SOL_SOCKET, SO_BROADCAST, 1 );

my $r = 0;
my $g = 0;
my $b = 0;
my $white = 0;

my @colors = (
	"\xFF\x00\x00", 
	"\x00\xFF\x00", 
	"\x00\x00\xFF", 
	"\xFF\xFF\xFF", 
	"\x00\x00\x00", 
);


while(1) {
	my $tubeindex = 0;

	for my $uni (1..82) {
	#print "UNI: $uni\n";

		my $payload  = "\x41\x72\x74\x2d\x4e\x65\x74\x00"; #artnet header
	
		$payload .= "\x00\x50"; #opcode
		$payload .= "\x00\x5e"; #prover
		$payload .= "\x00\x00"; #sec+phys
		$payload .= chr($uni)."\x00"; #uni
		$payload .= "\x02\x00"; #len

		for my $row (0..2) { #tubes
			my $colorblack = chr(int(rand(255))).chr(int(rand(255))).chr(int(rand(255)));

			for my $pixel (1..54) { #pixels
				$payload .= $colorblack;
			}
		}

		usleep(100000);	
		send( SOCKET, $payload, 0,  $broadcastAddr ) or die "Error at sendding: $!\n";

		$payload = "";	

	}
}

close SOCKET;
