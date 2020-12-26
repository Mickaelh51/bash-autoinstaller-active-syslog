#Installer for patch bash 4.3.30 with syslog

#!/bin/bash

# Version to install
version="5.1"
nodotversion="51"
firstpatch="1"
lastpatch="30"

#detect bash version
MAJVER=${BASH_VERSINFO[0]}
MINVER=${BASH_VERSINFO[1]}
platform='unknown'
download='wget --no-check-certificate'
unamestr=`uname`



#CHANGE FOR YOURS INFORMATIONS
IPSYSLOG='127.0.0.1'
BASHPRINT='MIKA' #GNU bash (MIKA), version 4.3.42(1)-release (i686-pc-linux-gnu)
#####################

if [[ "$unamestr" == 'Linux' ]]; then
   platform='linux'
   download='wget --no-check-certificate'
   syslogconf='/etc/rsyslog.d'
   printrestart='/etc/init.d/rsyslog restart'
   logrotateconf="/etc/logrotate.d"
   bashpath="/bin"
   echo "PS1='\[\033[0;31m\]\u\[\033[0m\]@\[\033[0;32m\]\h\[\033[0m\] :\w\$ '" >> "/root/.bashrc"
elif [[ "$unamestr" == 'FreeBSD' ]]; then
   platform='freebsd'
   download='fetch'
   syslogconf='/usr/local/etc/rsyslog.d'
   printrestart='/usr/local/etc/rc.d/rsyslogd restart'
   logrotateconf="/usr/local/etc/logrotate.d"
   bashpath="/usr/local/bin"
fi

printf "System: $platform / Your bash version: $MAJVER.$MINVER\n"

if [[ "$unamestr" == 'Linux' ]]
then
  printf "Do you execute update and install 'patch make gcc' ? Y/N\n"
  read answer1

  if [[ "$answer1" == "Y" ]]
    then
		  apt-get update -qq
		  apt-get install -y patch make gcc curl
  fi
fi

printf "Do you want upgrade and patch bash in your $platform ? Y/N\n"
read answer
if [[ "$answer" == "N" ]]
then
	printf "Bye\n"
	exit 1
else
	printf "Download bash version ${version} from ftp.gnu.org\n"
	TARFILE=bash-${version}.tar.gz
	$download "https://ftp.gnu.org/gnu/bash/$TARFILE"
	tar -xzvf $TARFILE

  cd bash-$version/
  printf "Download all patchs bash version ${version} from ftp.gnu.org\n"
  #source: http://www.stevejenkins.com/blog/2014/09/how-to-manually-update-bash-to-patch-shellshock-bug-on-older-fedora-based-systems/
  for i in `seq $firstpatch $lastpatch`;
  do
    number=$(printf %02d $i)
    file="https://ftp.gnu.org/pub/gnu/bash/bash-${version}-patches/bash${nodotversion}-0$number"
    echo $file
    curl -k $file | patch -N -p0
  done

  cd ..
	printf "Patch new bash version\n"
	patch bash-${version}/config-top.h config-top_syslog.patch
  if [[ "$version" =~ 5.* ]]
  then
    printf "Patch for bash version 5.X\n"
    patch bash-${version}/bashhist.c bashhist_syslog_v5.x.patch
  else
    printf "Patch for bash version < 5\n"
	  patch bash-${version}/bashhist.c bashhist_syslog.patch
  fi

	printf "Compile new bash version\n"
	cd "bash-${version}"
	sed -i -e "s/GNU bash,/GNU bash ($BASHPRINT),/" version.c
	sed -i -e "s/GNU bash,/GNU bash ($BASHPRINT),/" shell.c
	./configure
	make
	#make install

	NEWVERNAME="bash-${version}"
	OLDVERNAME="bash-$MAJVER.$MINVER"

	mv bash $NEWVERNAME-NEW
	mv $NEWVERNAME-NEW $bashpath/
	cd $bashpath
	cp bash $OLDVERNAME-OLD

  echo "user.*  -/var/log/tracecommands.log
	user.*   @$IPSYSLOG:514;GRAYLOGRFC5424" > "$syslogconf/tracecommands.conf"

  echo "/var/log/tracecommands.log {
        daily
        rotate 7
        copytruncate
        compress
        delaycompress
        missingok
        notifempty
}
" > "$logrotateconf/tracecommands"

	printf "###################################\n"
	printf "Please execute this commands\n"
	printf "cd $bashpath\n"
	printf "$NEWVERNAME-NEW\n"
	printf "mv $NEWVERNAME-NEW bash\n"
	printf "bash\n"
  	printf "$printrestart\n"
	printf "###################################\n"
fi
