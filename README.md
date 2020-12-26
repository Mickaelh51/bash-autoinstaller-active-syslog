# README #

Installer for patch bash 5.X (or older bash versions) with syslog module and be able to **show the real username**

### What is this repository for? ###
Active syslog module in bash.
Patch for show "logname" variable instead of UID in logs.

Ex: Login you on SSH with your user (mickael), You must switch to root for work (sudo -s).

With no patch you can see in log: (with sudo -s ==> root):

```
Sep 20 20:12:49 -bash: HISTORY: PID=1722 UID=0 cat /var/log/syslog
```


With these patches, you can see:(with sudo -s ==> root):

```
Sep 20 20:12:49 -bash: HISTORY: PID=1822 LOGIN=mickael COMMAND=cat /var/log/syslog
```

### Tested versions ###
* Debian jessie 64bits
* Debian wheezy 32bits
* Debian wheezy 64bits
* FreeBSD 7
* FreeBSD 9
* CentOS EL6
