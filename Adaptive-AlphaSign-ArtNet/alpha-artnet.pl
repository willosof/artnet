#!/usr/bin/perl -w
# William Viker (c) 2015 - A script that receives artnet packages and converts it to Alpha Sign control packets.
#
# INSTALL:
# $ sudo su -
# $ curl -L https://cpanmin.us | perl - --sudo App::cpanminus
# $ cpanm Time::HiRes Data::Dumper POSIX IO::Socket::INET Socket
# $ perl alpha-artnet.pl
#
# Should work fine on any linux or osx. (or maybe even windows with cygwin/perl) 
#
# Remember to modify the configuration below to match your setup.

use warnings;
use strict;
use Time::HiRes qw/time usleep/;
use Socket qw(:all);
use Data::Dumper;
use IO::Socket::INET;
use POSIX ":sys_wait_h";


### CONFIGURATION

my $sign_ip     = "192.168.1.50";   # The Ethernet-Serial board IP
my $sign_port   = "3001";           # ..and port
my $artnet_univ = 0;      # ArtNet universe. Maybe 1? Maybe 2?
my $artnet_chan = 1;      # Offset Channel.

# Create the fixture file like this:
# Channel (offset)+0: 0-255: String index to show on led display
# Channel (offset)+1: 0-50-150-200-255: Different colors
# Channel (offset)+1: 0-50-150-200-255: Different font sizes/styles

### STRINGS AVAILABLE FOR DISPLAY
### Remember to leave the first one blank. It's value 0 default / blackout.

my $strings = [
  '', # blackout er nummer 0
	'HEIA LYSLIGAN',
	'Tekst 2',
	'Tekst 3',
	'Tekst 4',
	'Tekst 5',
	'Tekst 6',
	'Tekst 7',
	'Tekst 8',
	'Tekst 9',
	'Tekst 10',
	'Tekst 11',
	'Tekst 12',
	'Tekst 13',
	'Tekst 14',
	'Tekst 15',
	'Tekst 16',
	'Tekst 17',
	'Tekst 18',
	'Tekst 19',
	'Tekst 20',
	'Tekst 21',
	'Tekst 22',
	'Tekst 23',
	'Tekst 24',
	'Tekst 25',
	'Tekst 26',
	'Tekst 27',
	'Tekst 28',
	'Tekst 29',
	'Tekst 30',
	'Tekst 31',
	'Tekst 32',
	'Tekst 33',
	'Tekst 34',
	'Tekst 35',
	'Tekst 36',
	'Tekst 37',
	'Tekst 38',
	'Tekst 39',
	'Tekst 40',
	'Tekst 41',
	'Tekst 42',
	'Tekst 43',
	'Tekst 44',
	'Tekst 45',
	'Tekst 46',
	'Tekst 47',
	'Tekst 48',
	'Tekst 49',
	'Tekst 50',
	'Tekst 51',
	'Tekst 52',
	'Tekst 53',
	'Tekst 54',
	'Tekst 55',
	'Tekst 56',
	'Tekst 57',
	'Tekst 58',
	'Tekst 59',
	'Tekst 60',
	'Tekst 61',
	'Tekst 62',
	'Tekst 63',
	'Tekst 64'
];


## DONT CHANGE ANYTHING BELOW THIS LINE ##

my $lasttime = "ha";
my $checksum = 0;

my $socket = new IO::Socket::INET (
    'PeerHost' => $sign_ip,
    'PeerPort' => $sign_port,
    'Proto'    => 'tcp',
);

die "cannot connect to the server $!\n" unless $socket;
print "connected to the led sign\n";


socket( UDPSOCK, PF_INET, SOCK_DGRAM, getprotobyname('udp') ) or die "
+socket: $!";

select( ( select(UDPSOCK), $|=1 )[0] ); # no suffering from buffering

setsockopt( UDPSOCK, SOL_SOCKET, SO_REUSEADDR, 1 )
    or die "setsockopt SO_REUSEADDR: $!";

setsockopt( UDPSOCK, SOL_SOCKET, SO_BROADCAST, 1 )
    or die "setsockopt SO_BROADCAST: $!";

my $broadcastAddrH = sockaddr_in( 6454, INADDR_ANY );
bind( UDPSOCK, $broadcastAddrH ) or die "IP Bind failed: $!\n";

my $input;

my $uni = {}; # primary universe
my $ext = {}; # external universe

print "Listening for ArtNet packages..\n";

update_sign("7","6","");

my $packetnum = 0;

while( my $addr = recv( UDPSOCK, $input, 4096, 0 ) ) {

	my ($port, $hisiaddr) = sockaddr_in($addr);
	my $host              = gethostbyaddr($hisiaddr, AF_INET);

	my $payload  = "\x41\x72\x74\x2d\x4e\x65\x74\x00\x00\x50\x00\x5e\x00\x00"; #luls. only from catalyst ...

	if (length($input) == 530) { #lets check if we got the entire 512 channel frame... aka sanity

		$ext->{ord(substr($input, 14, 1))} = $input;

		for my $u (keys %{$ext}) {

			my $val = $ext->{$u};

			#print "   " . time(). ": Uni $u ".length(   substr($val,18,512)   )."\n";

			my @bytes = split //, substr($val,18,512);
			my @const = ();

			for my $byte (@bytes) {
				push @const, ord($byte);
			}

			if (not defined $uni->{$u}) {
				print " * Discovered new ArtNet universe: ".$u."\n";
			}

			$uni->{$u} = \@const;

		}

	}

	else {
		print STDERR "Invalid or incomplete artnet packet. We only support full frames!\n";
	}

	## Begin magic.

	if (defined $strings->[$uni->{$artnet_univ}->[$artnet_chan-1]]) {

		my $ch = $uni->{$artnet_univ}->[$artnet_chan];
		my $color = 1;

		if ($ch > 50 && $ch <= 100) {
			$color = 2;
		}

		if ($ch > 100 && $ch <= 150) {
			$color = 3;
		}

		if ($ch > 150 && $ch <= 200) {
			$color = 8;
		}

		if ($ch > 200 && $ch <= 255) {
			$color = 9;
		}

		$ch = $uni->{$artnet_univ}->[$artnet_chan+1];
		my $style = 9;

		if ($ch > 50 && $ch <= 100) {
			$style = "2";
		}

		if ($ch > 100 && $ch <= 150) {
			$style = "4";
		}

		if ($ch > 150 && $ch <= 200) {
			$style = "5";
		}

		if ($ch > 200 && $ch <= 255) {
			$style = ">";
		}


		update_sign($color, $style, $strings->[$uni->{$artnet_univ}->[$artnet_chan-1]]);

		#print join(" ", @{$uni->{$artnet_univ}})."\n";

	}

	else {
		update_sign("1", "9", "Undefined string: ".$uni->{$artnet_univ}->[$artnet_chan-1])
	}







}

sub update_sign {

	my ($color, $style, $text) = @_;

	# Lets do a simple "checksum". The LED display wont
	# Handle the artnet update frequency, so we'll just update
	# the panel when things change.

	my $new_checksum = $color.$style.$text; #lol

	unless ($new_checksum ne $checksum) {
			return;
	}

	$checksum = $new_checksum;

	# Generate the payload

	my $req = "\x00\x00\x00\x00\x00"; # Baud rate detection
	$req .= "\x01"; ## Begin!
	$req .= "Z"; ## all signs
	$req .= "00"; # all addresses
	$req .= "\x02"; # start trans
	$req .= "A"; # Write STRING file
	$req .= "0"; # file label
	$req .= "\x1B"; # mode field
	$req .= "\x20"; # center line
	$req .= "b"; #hold
	$req .= "\x1A";
	$req .= $style;
	$req .= "\x1C".$color.$text;
	$req .= "\x04"; # stop trans

	my $size = $socket->send($req);
	#print "sent data of length $size\n";

}


# We'll never get here ;)
shutdown($socket, 1);
$socket->close();
