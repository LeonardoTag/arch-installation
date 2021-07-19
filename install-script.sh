#!/bin/bash

# Setting Keyboard Layout
loadkeys br-abnt2

# Setting Internet Connection

while [true]
do
	ping -c 1 archlinux.org > /dev/null && echo "Internet connection found." && break
	read -p "Internet connection not found. Try again [1] or setup Wifi [2]?" DECISION
	[ $DECISION = "1" ] && continue
	if [ $DECISION = "2" ] do
		STATIONS=$("iwctl device list | grep ' on ' | grep -o -P '^ +\S+' | tr -d ' ' done")
		[ wc -l $STATIONS = "0" ] && echo "No wifi device found." && continue
		if [ wc -l $STATIONS = "1" ] do
			echo "Wifi device $STATIONS found."
			STATION=$STATIONS
		else
			echo "Multiple wifi devices found. Please choose one."
			echo $STATIONS
			read -p "Device to be used: " STATION
		iwctl station $STATION scan || echo "Invalid device." && continue
		iwctl station $STATION get-networks
		NETWORKS=$("iwctl station $STATION get-networks | grep '*' | grep -o -P '^ +\S+' | tr -d ' ' done")
		read -p "Network to be connected to: "
	else
		echo "Option unknown."
		continue
		
