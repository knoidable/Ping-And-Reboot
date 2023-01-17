# Ping-And-Reboot
### Automatically monitor and reboot remote servers

I wrote this in early 2009. The gaming community I was involved with at that time had a Windows server that would randomly hang every few weeks. We did all the troubleshooting we could, but it just kept dying on us - so we eventually gave up and just accepted that the box was going to occasionally stop responding. It was being provided at no cost, else we'd have taken it up with the host.

The server had an APC networked power outlet that we could control via telnet to cycle power. Easy enough to do, but if any of the admins were unavailable to bounce the box it could stay offline for hours. 

This situation being less than optimal, I exercised my Google-Fu and put together this script in Perl to ping the box and reboot it if necessary. Why Perl? I have no earthly clue. Everything else we did was in PHP, so perhaps I was feeling particularly masochistic that day. I do remember feeling that Perl was a completely bewildering language, but in spite of that that the end result is sufficiently readable.

I don't remember which APC model it was, but the interface was menu-based rather than command based. While trying to find the model today I did learn that you can enter a command based interface by adding a -c flag when you telnet into the unit. Had I known that at the time, there would've been much less trial-and-error involved in putting this together.

This is a one-shot script, intended to be launched by cron at your desired monitoring interval. I found every 5 minutes was more than sufficient. The script makes a logfile each time it's run, and those add up fairly quickly. Were I to need this again, proper logging would definitely be a priority.

## Dependencies
Just two libraries needed, Net::Telnet and Net::Ping::External.

## Installation
Download the script and put it in it's own directory (because SO MANY LOGFILES).

## Configuration
Open the script with your text editor of choice, and enter your server information into lines 39-42: 

| Line | Purpose | Example |
|----|----|----|
| 39 | Servers to ping | ``` @servers = qw(192.168.10.50 mybox.mydomain.com); ``` |
| 40 | IP power switch for each server | ``` @ups = qw(192.168.10.51 myups.mydomain.com); ``` |
| 41 | username for each IP power switch | ``` @logins = qw(iamarobot iamstillarobot); ``` |
| 42 | password for each IP power switch | ``` @passwords = qw(nore4lly it5true);  ``` |

You can add as many servers as needed - the script will loop through until all have been pinged, rebooted if necessary, and logged.

## Automation
Open crontab (``` crontab -e ```), choose your preferred text editor (I like nano) and add a line to the bottom, altering the run interval (*/5) as needed:

``` */5 * * * * perl /path/to/ping-and-reboot.pl ```

If you are running this for a large number of servers, you'll need to increase the run interval as the script will take longer to complete (each ping timeout adds 30 seconds or so I think). */15 will run it every 15 mins, */30 every 30 etc. 

If you chose nano as your text editor, then Ctrl-O to save the updated crontab and Ctrl-X to exit. If you chose another option, go and look up the equivalents.
