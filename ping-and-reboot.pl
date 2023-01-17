#!/usr/bin/perl
# Copyright 2009 Sam Powis
#.....................

use strict;
use Net::Telnet; 
use Net::Ping::External qw(ping);

our $theTime;
our $LogTime;
our $telnet;
our @status;
our @servers;
our @ups;
our @logins;
our @passwords;


sub Init {
	my @months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
	my @weekDays = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
	@servers = qw(server1 server2 server3);
	@ups = qw(IPSwitch1 IPSwitch2 IPSwitch3);
	@logins = qw(username1 username2 username3);
	@passwords = qw(password1 password2 password3);
	my ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
	$theTime = sprintf '%02d:%02d',$hour,$minute;
	$LogTime = sprintf '%02d%02d',$month+1,$dayOfMonth;
}

sub Reboot{
	my ($ups_no) = @_;
	$telnet = new Net::Telnet ( Timeout=>10, Errmode=>'return'); 
	$telnet->open(@ups[$ups_no]);
	$telnet->prompt('/:?$/i');
	$telnet->waitfor('/Name : ?$/i');
	print $telnet->cmd(@logins[$ups_no]); 
	$telnet->waitfor('/word  : ?$/i');
	$telnet->prompt('/>/i');
	print $telnet->cmd(@passwords[$ups_no]); 
	$telnet->waitfor('/<ENTER>/i');
	print $telnet->cmd('1');
	$telnet->waitfor('/<ENTER>/i');
	print $telnet->cmd('1');
	$telnet->waitfor('/<ENTER>/i');
	print $telnet->cmd('3');
	$telnet->prompt('//');
	$telnet->waitfor('/cancel :?/i');
	print $telnet->cmd('YES');
	$telnet->waitfor('/continue.../i');
	print $telnet->cmd('');
	$telnet->prompt('/>/i');
	$telnet->waitfor('/<ENTER>/i');
	print $telnet->cmd('\e');
	$telnet->waitfor('/<ENTER>/i');
	print $telnet->cmd('\e');
	$telnet->close;
}

sub Log(\@){
	my($status) = @_;
	open LOG, "+>>", "j2mon_$LogTime.log" or die $!;
	my $i=0;
	foreach my $server (@servers) {
		print LOG "| $theTime | $server | @{$status}[$i] |\n";
		$i++;
	}
	close(LOG);	
}

sub PingServer(\@){
	my ($servers) = @_;
	my @status;
	my $i=0;
	foreach my $server (@{$servers}) {
		my $alive = ping(hostname => $server, count => 6, size => 64, timeout => 100);
		if ($alive eq "1") {
			@status[$i]="UP";
		}
		else {
			@status[$i]="DOWN";
			Reboot($i);
		}
		$i++;
	}
	return @{status};
}

Init();
@status = PingServer(@servers);
Log(@status);