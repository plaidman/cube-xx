#!/bin/sh

. /opt/muos/script/var/func.sh

TEMP_FILE="/sys/class/disp/disp/attr/color_temperature"
DN_PREFIX="`GET_VAR "device" "storage/rom/mount"`/MUOS/task/.daynight/daynight"
INI_FILE="$DN_PREFIX.ini"
LOG_FILE="$DN_PREFIX.log"
MODE_FILE="$DN_PREFIX.mode"

SAVE_TEMP() {
	echo "$CURRENT_TEMP" > "$TEMP_FILE"
	SET_VAR "global" "settings/general/colour" "$CURRENT_TEMP"
	DEBUG "saving temp: $CURRENT_TEMP"
}

SAVE_MODE() {
	echo "$CURRENT_MODE" > "$MODE_FILE"
	DEBUG "saving mode: $CURRENT_MODE"
}

GET_VALS() {
	INTERVAL=`PARSE_INI "$INI_FILE" "global" "interval"`
	INCREMENT=`PARSE_INI "$INI_FILE" "global" "increment"`
	NIGHT_HOUR=`PARSE_INI "$INI_FILE" "night" "hour"`
	NIGHT_TEMP=`PARSE_INI "$INI_FILE" "night" "temp"`
	DAY_HOUR=`PARSE_INI "$INI_FILE" "day" "hour"`
	DAY_TEMP=`PARSE_INI "$INI_FILE" "day" "temp"`
    
	CURRENT_HOUR=`date +%H`
	CURRENT_TEMP=`GET_VAR "global" "settings/general/colour"`

	if [ $CURRENT_HOUR -eq $DAY_HOUR ]; then
		TARGET_MODE="DAY"
		TARGET_TEMP=$DAY_TEMP
	elif [ $CURRENT_HOUR -eq $NIGHT_HOUR ]; then
		TARGET_MODE="NIGHT"
		TARGET_TEMP=$NIGHT_TEMP
	else
		TARGET_MODE="SKIP"
	fi

	if [ $TARGET_TEMP -lt $CURRENT_TEMP ]; then
		TARGET_INCREMENT="-$INCREMENT"
	else
		TARGET_INCREMENT=$INCREMENT
	fi
}

SAVE_VALS() {
	CURRENT_TEMP=$TARGET_TEMP
	SAVE_TEMP
	CURRENT_MODE=$TARGET_MODE
	SAVE_MODE
}

WAIT_FOR_NEXT() {
	if [ $CURRENT_HOUR -eq 23 ]; then
		NEXT_TIME=`date -d "00:00" +%s`
		NEXT_TIME=$(($NEXT_TIME + 86400))
	else
		NEXT_TIME=$(($CURRENT_HOUR + 1))
		NEXT_TIME=`date -d "$NEXT_TIME:00" +%s`
	fi

	CURRENT_TIME=`date +%s`
	DIFF_TIME=$((1 + $NEXT_TIME - $CURRENT_TIME))
	DEBUG "waiting $DIFF_TIME"
	sleep $DIFF_TIME
}

DO_CHANGE() {
	while :; do
		CURRENT_TEMP=$(($CURRENT_TEMP + $TARGET_INCREMENT))
		CURRENT_MODE=`cat $MODE_FILE`

		if [ $TARGET_MODE = $CURRENT_MODE ]; then
			DEBUG "stopped from task"
			break
		elif [ $TARGET_INCREMENT -gt 0 ] && [ $CURRENT_TEMP -ge $TARGET_TEMP ]; then
			DEBUG "ended (increasing)"
			break
		elif [ $TARGET_INCREMENT -lt 0 ] && [ $CURRENT_TEMP -le $TARGET_TEMP ]; then
			DEBUG "ended (decreasing)"
			break
		fi

		SAVE_TEMP
		sleep $INTERVAL
	done
}

DEBUG() {
	if [ "$LOGGING" = "yes" ]; then
		echo "$1" >> "$LOG_FILE"
	fi
}

LOGGING=`PARSE_INI "$INI_FILE" "global" "debugLogs"`
if [ "$LOGGING" = "yes" ]; then
	echo "" > "$LOG_FILE"
fi

AUTOMATIC=`PARSE_INI "$INI_FILE" "global" "automatic"`
if [ "$AUTOMATIC" != "yes" ]; then
	DEBUG "automatic disabled"
	exit
fi

NIGHT_HOUR=`PARSE_INI "$INI_FILE" "night" "hour"`
NIGHT_TEMP=`PARSE_INI "$INI_FILE" "night" "temp"`
DAY_HOUR=`PARSE_INI "$INI_FILE" "day" "hour"`
DAY_TEMP=`PARSE_INI "$INI_FILE" "day" "temp"`
CURRENT_HOUR=`date +%H`

if [ $CURRENT_HOUR -lt $DAY_HOUR ]; then
	TARGET_MODE="NIGHT"
	TARGET_TEMP=$NIGHT_TEMP
elif [ $CURRENT_HOUR -lt $NIGHT_HOUR ]; then
	TARGET_MODE="DAY"
	TARGET_TEMP=$DAY_TEMP
else
	TARGET_MODE="NIGHT"
	TARGET_TEMP=$NIGHT_TEMP
fi

DEBUG "current hour: $CURRENT_HOUR"
DEBUG "day hour: $DAY_HOUR"
DEBUG "night hour: $NIGHT_HOUR"
DEBUG "target mode: $TARGET_MODE"
DEBUG "target temp: $TARGET_TEMP"

SAVE_VALS
WAIT_FOR_NEXT

while :; do
	GET_VALS

	if [ $TARGET_MODE != "SKIP" ]; then
		DEBUG "changing this hour $CURRENT_HOUR to $TARGET_MODE"
		DO_CHANGE
		SAVE_VALS
	else
		DEBUG "skipping this hour $CURRENT_HOUR"
	fi

	WAIT_FOR_NEXT
done
