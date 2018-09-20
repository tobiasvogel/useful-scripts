#!/bin/bash

BOLDTEXT='\e[1m'
REGULARTEXT='\e[0m'

DISABLEWIFI=1
DISABLEBT=1
SUPPORTEDHW=0

# checking if we are running as root
if [ "`id -u`" != "0" ]; then
	echo -e "$BOLDTEXT" "Please re-run this script as root user!"
	echo -e "$REGULARTEXT" "Aborting."
	exit 1
fi

# check whether we are running on supported board (from https://elinux.org/RPi_HardwareHistory)
if [ "x`grep Revision /proc/cpuinfo | awk '{print $3}'`" == "xa02082" ]; then
	# Raspberry Pi 3 B Rev 1.2 (Sony)
	SUPPORTEDHW=1
elif [ "x`grep Revision /proc/cpuinfo | awk '{print $3}'`" == "xa22082" ]; then
	# Raspberry Pi 3 B Rev 1.2 (Embest)
	SUPPORTEDHW=1
elif [ "x`grep Revision /proc/cpuinfo | awk '{print $3}'`" == "xa32082" ]; then
	# Raspberry Pi 3 B Rev 1.2 (Sony Japan)
	SUPPORTEDHW=1
elif [ "x`grep Revision /proc/cpuinfo | awk '{print $3}'`" == "xa020d3" ]; then
	# Raspberry Pi 3+ B Rev 1.3 (Sony)
	SUPPORTEDHW=1
elif [ "x`grep Revision /proc/cpuinfo | awk '{print $3}'`" == "x9000c1" ]; then
	# Raspberry Pi Zero W Rev 1.1 (Sony)
	SUPPORTEDHW=1
else
	SUPPORTEDHW=0
	echo "This script is only compatible with Raspberry Pi 3 and Zero W boards."
	echo "Either the underlying board is not one of the above types or the"
	echo "board didn't get recognized properly."
	echo "Exiting."
	exit 1	
fi

# checking whether wifi has already been disabled before
if [ "x`grep -e '^dtoverlay=.*$' /boot/config.txt | grep -o 'pi3-disable-wifi'`" == "xpi3-disable-wifi" ]; then
	echo "WiFi already disabled, skipping on WiFi"
	DISABLEWIFI=0
fi

# checking whether bt has already been disabled before
if [ "x`grep -e '^dtoverlay=.*$' /boot/config.txt | grep -o 'pi3-disable-bt'`" == "xpi3-disable-bt" ]; then
	echo "BT already disabled, skipping on BT"
	DISABLEBT=0
fi

# checking whether wifi AND bt have already been disabled before
if [ $DISABLEWIFI -eq 0 -a $DISABLEBT -eq 0 ]; then
	echo "Either you or someone else already disabled WiFi and BT"
	echo "or you are running this script repeatedly."
	echo "Exiting."
	exit 127
fi

# checking whether there are other active dtoverlays in place
if [ "x`grep -e '^dtoverlay=.*$' /boot/config.txt`" == "x" ]; then
	# no currently active dtoverlay, simply add a line to /boot/config.txt
	echo "" >> /boot/config.txt
	echo "dtoverlay=pi3-disable-wifi,pi3-disable-bt" >> /boot/config.txt
else
	# there seems to already exist an active dtoverlay line in
	# /boot/config.txt, so let's append to that one
	DATETIME=`date '+%Y%m%d_%H%M'`
	if [ $DISABLEWIFI -eq 0 ]; then
		sed -i".bak-${DATETIME}" 's/^\(dtoverlay=\)\(.*\)\(,\)\?$/\1\2,pi3-disable-bt/' /boot/config.txt
	elif [ $DISABLEBT -eq 0 ]; then
		sed -i".bak-${DATETIME}" 's/^\(dtoverlay=\)\(.*\)\(,\)\?$/\1\2,pi3-disable-wifi/' /boot/config.txt
	else
		sed -i".bak-${DATETIME}" 's/^\(dtoverlay=\)\(.*\)\(,\)\?$/\1\2,pi3-disable-wifi,pi3-disable-bt/' /boot/config.txt
	fi
fi


# echo-ing success message according with reboot reminder
echo "******************************************************"
echo "* BT and Wifi disabled succesfully.                  *"
echo -en "*"
echo -en "$BOLDTEXT" "Please note:"
echo -e "$REGULARTEXT" "For the new configuration to become   *"
echo -en "* active, you will need to"
echo -en "$BOLDTEXT" "reboot"
echo -e "$REGULARTEXT" "your Raspberry Pi! *"
echo "******************************************************"
