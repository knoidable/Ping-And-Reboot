#!/usr/bin/perl
# ping-and-reboot
# Copyright (c) 2009 Sam Powis
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see https://www.gnu.org/licenses/gpl-3.0.html
#
# @name ping-and-reboot.sh
# @version 2009-03-17
# @summary Ping a server; reboot it if no response

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
	open LOG, "+>>", "pnr_$LogTime.log" or die $!;
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
