# README #

Installer for patch bash 4.3.30 with syslog module

### What is this repository for? ###
Active syslog module in bash 4.3.30.
Patch for show "logname" variable instead of UID in logs.

Ex: You login on SSH with your user (toto), You must switch to root to work (sudo -s).

No patch you can see in log:

```
Sep 20 20:12:49 -bash: HISTORY: PID=1722 UID=0 cat /var/log/syslog
```


but with this patch, you can see:

```
Sep 20 20:12:49 -bash: HISTORY: PID=1722 LOGIN=toto COMMAND=cat /var/log/syslog
```


### Tested versions ###
* Debian wheezy 32bits
* Debian wheezy 64bits
* FreeBSD 7
* FreeBSD 9
