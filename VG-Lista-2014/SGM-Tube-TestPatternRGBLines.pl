#!/usr/bin/perl -w

use warnings;
use strict;
use Time::HiRes qw/time usleep/;
use Socket qw(:all);
use POSIX ":sys_wait_h";

##### her er vel det eneste man skal trenge å endre

my $pixels = 54; # hver 2meters tube har 54 pixler
my $universe_from = 1; #send fra univers
my $universe_to = 82;  #til univers

##### ...til hit ;)

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
	usleep(5000); # Hvor kjapt skal jævelskapen gå? (dvs, hvor lenge skal den vente per pakkecycle)

	for my $uni ($universe_from..$universe_to) { # Hvor mange univers har du? Vel, jeg hadde 82. Endre som man vil.

		my $payload  = "\x41\x72\x74\x2d\x4e\x65\x74\x00"; #artnet header

		$payload .= "\x00\x50"; #opcode
		$payload .= "\x00\x5e"; #prover
		$payload .= "\x00\x00"; #sec+phys
		$payload .= chr($uni)."\x00"; #uni
		$payload .= "\x02\x00"; #len

		for my $row (0..2) { #tubes (hvor mange tuber per univers? TRE! ..det er jo maks, så.)
			$tubeindex++;

			for my $pixel (1..$pixels) { # 54 er her antall pixler i høyden (2meters tuber)

				my $pixelnow = int(   (( sin( time() * 2  ) + 1 ) / 2) * 47 );
				my $pixelnow2 = int(   (( sin( time() * 3  ) + 1 ) / 2) * 47 );
				my $pixelnow3 = int(   (( sin( time() * 1  ) + 1 ) / 2) * 47 );

				my $col = chr(0).chr(0).chr(0);

				if ($pixelnow eq $pixel || $pixelnow > $pixel) {
					$col = chr(0).chr(255).chr(0);
				}

				if ($pixelnow2 eq $pixel) {
					$col = chr(255).chr(0).chr(0);
					print "Pixelnow $pixelnow \n";
				}

				if ($pixelnow3 eq $pixel || $pixelnow3 < $pixel) {
					$col = chr(0).chr(0).chr(255);
					print "Pixelnow $pixelnow \n";
				}

				$payload .= $col;

			}
		}

		send( SOCKET, $payload, 0,  $broadcastAddr ) or die "Error at sendding: $!\n";


	}
}

close SOCKET;
