#!/bin/sh
# HELP: Run Dot and Junk File Cleanup
# ICON: junk

. /opt/muos/script/var/func.sh

pkill -STOP muxtask

TEMP_FILE="/sys/class/disp/disp/attr/color_temperature"
MODE_FILE="$(GET_VAR "device" "storage/rom/mount")/MUOS/task/.daynight/daynight.mode"
INI_FILE="$(GET_VAR "device" "storage/rom/mount")/MUOS/task/.daynight/daynight.ini"

if [ ! -f $MODE_FILE ]; then
	echo "DAY" > $MODE_FILE
fi

MODE=`cat $MODE_FILE`
NIGHT_TEMP=$(PARSE_INI "$INI_FILE" "night" "temp")
DAY_TEMP=$(PARSE_INI "$INI_FILE" "day" "temp")

if [ "$MODE" = "NIGHT" ]; then
	MODE="DAY"
	NEW_TEMP=$DAY_TEMP

	echo "";
	echo "";
	echo "";
	echo "";
	echo "                  ██████╗  █████╗ ██╗   ██╗";
	echo "                  ██╔══██╗██╔══██╗╚██╗ ██╔╝";
	echo "                  ██║  ██║███████║ ╚████╔╝";
	echo "                  ██║  ██║██╔══██║  ╚██╔╝";
	echo "                  ██████╔╝██║  ██║   ██║";
	echo "                  ╚═════╝ ╚═╝  ╚═╝   ╚═╝";
	echo "";
	echo "";
	echo "            ███╗   ███╗ ██████╗ ██████╗ ███████╗";
	echo "            ████╗ ████║██╔═══██╗██╔══██╗██╔════╝";
	echo "            ██╔████╔██║██║   ██║██║  ██║█████╗";
	echo "            ██║╚██╔╝██║██║   ██║██║  ██║██╔══╝";
	echo "            ██║ ╚═╝ ██║╚██████╔╝██████╔╝███████╗";
	echo "            ╚═╝     ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝";
	echo "";
	echo "";
	echo "";

else
	MODE="NIGHT"
	NEW_TEMP=$NIGHT_TEMP

	echo "";
	echo "";
	echo "";
	echo "";
	echo "           ███╗   ██╗██╗ ██████╗ ██╗  ██╗████████╗";
	echo "           ████╗  ██║██║██╔════╝ ██║  ██║╚══██╔══╝";
	echo "           ██╔██╗ ██║██║██║  ███╗███████║   ██║   ";
	echo "           ██║╚██╗██║██║██║   ██║██╔══██║   ██║   ";
	echo "           ██║ ╚████║██║╚██████╔╝██║  ██║   ██║   ";
	echo "           ╚═╝  ╚═══╝╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ";
	echo "";
	echo "";
	echo "            ███╗   ███╗ ██████╗ ██████╗ ███████╗";
	echo "            ████╗ ████║██╔═══██╗██╔══██╗██╔════╝";
	echo "            ██╔████╔██║██║   ██║██║  ██║█████╗";
	echo "            ██║╚██╔╝██║██║   ██║██║  ██║██╔══╝";
	echo "            ██║ ╚═╝ ██║╚██████╔╝██████╔╝███████╗";
	echo "            ╚═╝     ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝";
	echo "";
	echo "";
	echo "";
fi

echo "$MODE" > "$MODE_FILE"
echo "$NEW_TEMP" > "$TEMP_FILE"
SET_VAR "global" "settings/general/colour" "$NEW_TEMP"

sleep 1

pkill -CONT muxtask
exit 0
