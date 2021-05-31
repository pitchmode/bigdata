#!/bin/bash

APP_NAME="StreamingApp"
MONITORING_APP=`yarn app -list | grep "$APP_NAME" | awk '{print $2}' | cut -d '.' -f4`
MONITORING_APP_STATUS=`yarn app -list | grep PIStreaming3 | awk '{print $6}'`
OK_STATUS="RUNNING"
ACCEPTED_STATUS="ACCEPTED"

timestamp() {
        date +"%y/%m/%d %T" # current date and time
}

printf "Logs:\n%s %s%s%s\n" "$(timestamp)" "$MONITORING_APP" ": OK. Status: " "$MONITORING_APP_STATUS" | tee output.log

while true
do
        sleep 10
        MONITORING_APP_STATUS=`yarn app -list | grep "$APP_NAME" | awk '{print $6}'`
#       printf "%s [!] Debug: Application current status - %s\n" "$(timestamp)" "$MONITORING_APP_STATUS"
        if [ "$MONITORING_APP_STATUS" = "$OK_STATUS" ] || [ "$MONITORING_APP_STATUS" = "$ACCEPTED_STATUS" ]; then
                printf "%s [+] Healthcheck: OK.\n" "$(timestamp)"
                sleep 150
        else
                printf "%s [-] Failed.\n" "$(timestamp)" | tee output.log
                printf "Trying to restart...\n"
                source /home/smotr/pi3-1.4.2.sh
                sleep 150
        fi
done
