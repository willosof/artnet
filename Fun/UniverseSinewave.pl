#!/usr/bin/perl -w

use warnings;
use strict;
use Time::HiRes qw/time usleep/;
use Socket qw(:all);
use POSIX ":sys_wait_h";


my $from_uni = 1; # from what universe?
my $to_uni = 10;  # to what universe?



socket( SOCKET, PF_INET, SOCK_DGRAM, getprotobyname("udp") )
    or die "Error: can't create an udp socket: $!\n";

select( ( select(SOCKET), $|=1 )[0] ); # no suffering from buffering

my $broadcastAddr = sockaddr_in( 6454, inet_aton("255.255.255.255"));
setsockopt( SOCKET, SOL_SOCKET, SO_BROADCAST, 1 );

while(1) {
	my $tubeindex = 0;
	usleep(500);

	for my $uni ($from_uni..$to_uni) {

		my $payload  = "\x41\x72\x74\x2d\x4e\x65\x74\x00"; #artnet header

		$payload .= "\x00\x50"; #opcode
		$payload .= "\x00\x5e"; #prover
		$payload .= "\x00\x00"; #sec+phys
		$payload .= chr($uni)."\x00"; #uni
		$payload .= "\x02\x00"; #len

		for my $ch (1..512) {
				$b = int(   (( sin( ( (time()*4) + ($ch/1 )  ) * 1  ) + 1 ) / 2) * 254 );
				$payload .= chr($b);
		}

		send( SOCKET, $payload, 0,  $broadcastAddr ) or die "Error at sendding: $!\n";


	}
}

close SOCKET;
