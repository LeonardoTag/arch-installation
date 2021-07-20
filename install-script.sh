#!/bin/bash

# Setting Keyboard Layout
echo
echo "> Setting Keyboard Layout"

while [ 1 ]
do
	read -p "Keyboard layout: [Default: br-abnt2] " LAYOUT
	[ $LAYOUT = "" ] && LAYOUT="br-abnt2"
	loadkeys $LAYOUT &> /dev/null || ( echo "Invalid layout. Please try again." && continue )

# Identifying Boot Mode
echo
echo "> Identifying Boot Mode"

ls /sys/firmware/efi/efivars &> /dev/null && UEFI=1 || UEFI=0
[ $UEFI = "1" ] && echo "-> UEFI" || echo "-> Legacy BIOS"

# Setting Internet Connection
echo
echo "> Setting Internet Connection"

while [ 1 ]
do
	ping -c 1 archlinux.org &> /dev/null && echo "Internet connection found." && break
	echo "Internet connection not found."
	echo "[1] Try again"
	echo "[2] Setup wireless connection"
	read -p ": " DECISION
	[ $DECISION = "1" ] && continue
	if [ $DECISION = "2" ]; then
		STATIONS=$(iwctl device list | grep ' on ' | grep -o -P '^ +\S+' | tr -d ' ')
		[ "$(echo $STATIONS | wc -l)" = "0" ] && echo "No wifi device found." && continue
		if [ "$(echo $STATIONS | wc -l)" = "1" ]; then
			echo "Wireless device found."
			STATION=$STATIONS
		else
			echo "Multiple wifi devices found. Please choose one."
			echo $STATIONS
			read -p "Device to be used: " STATION
		fi
		iwctl station $STATION scan || ( echo "Invalid device." && continue )
		iwctl station $STATION get-networks
		#NETWORKS="$(iwctl station $STATION get-networks | grep '*')"
		#NETWORKS=${NETWORKS:4}
		#echo $NETWORKS
		read -p "Network to be connected to: " NETWORK
		read -s -p "Passphrase: " PASSPHRASE
		iwctl --passphrase=$PASSPHRASE station $STATION connect "$NETWORK" || ( echo "Connection failed. Please try again." && continue )
		sleep 1
		continue
	else
		echo "Invalid option."
		continue
	fi
done

# Updating System Clock
echo
echo "> Updating System Clock"
timedatectl set-ntp true

# Preparing For LUKS Encryption
modprobe dm-crypt
modprobe dm-mod

# Preparing Disks
echo
echo "> Preparing Disks"
echo "$ lsblk"
lsblk

while [ 1 ]
do
	read -p "Disk to partition :" DISK
	read -p "Are you sure you want to overwrite whatever is in $DISK? [y/N]" DECISION
	( [ ${DECISION^^} = "Y" ] || [ ${DECISION^^} = "YES" ] ) || continue
done

echo
echo "INSTRUCTIONS:"
echo
if [ $UEFI = "0" ]; then
	echo "Boot mode: Legacy BIOS"
	echo "Label type: DOS"
else
	echo "Boot mode: UEFI"
	echo "Label type: GPT"


cfdisk /dev/sda

