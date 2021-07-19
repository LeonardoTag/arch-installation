#!/bin/bash

# Setting Keyboard Layout
loadkeys br-abnt2

# Setting Internet Connection

while [ 1 ]
do
	ping -c 1 archlinux.org > /dev/null 2> /dev/null && echo "Internet connection found." && break
	echo "Internet connection not found."
	read -p "Try again [1] or setup Wifi [2]? " DECISION
	[ $DECISION = "1" ] && continue
	if [ $DECISION = "2" ]; then
		STATIONS=$(iwctl device list | grep ' on ' | grep -o -P '^ +\S+' | tr -d ' ')
		[ "$(echo $STATIONS | wc -l)" = "0" ] && echo "No wifi device found." && continue
		if [ "$(echo $STATIONS | wc -l)" = "1" ]; then
			echo "Wifi device $STATIONS found."
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
		echo "Option unknown."
		continue
	fi
done
