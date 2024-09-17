#!/bin/bash

WLAN_MODE=$(sudo iw dev | grep type)
WLAN_INTERFACE=$(sudo iw dev | grep Interface | awk '{print $2}')
RED='\033[0:31m'
GREEN='\033[0:32m'
YELLOW='\033[0:33m'
RESET='\033[0:0m'


checkKill() {
    sudo airmon-ng check kill
}

setMode() {
    mode="start"
    if [ "$2" == "managed" ]; then
        mode="stop"
    fi
    checkKill
    printf "Setting mode to $2\n"
    sudo airmon-ng $mode $1
    printf "${GREEN}Done\n"
}

checkMode() {
    if [[ $WLAN_MODE =~ "monitor" ]]
    then
        printf "${GREEN}${WLAN_INTERFACE} in monitor mode\n${RESET}"
        printf "${RESET}"
    else
        printf "${RED}${WLAN_INTERFACE} in managed mode\n${RESET}"
        setMode wlan0 monitor
    fi
}

TEMP_FILE=$(mktemp /tmp/airodump_temp_XXXXXX.csv)
sudo timeout 10s sudo airodump-ng $WLAN_INTERFACE -w "${TEMP_FILE%.*}" --output-format csv
OUTPUT_FILE="${TEMP_FILE%.*}-01.csv"
networks=$(cat ${OUTPUT_FILE})
printf "${networks}\n"