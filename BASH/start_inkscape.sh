#!/bin/sh -x

set -e

export INKSCAPE="/Applications/Inkscape.app/Contents/MacOS/Inkscape"
export DEFAULTDISPLAY=":0"

#################################
# Do not change anything below! #
#################################

WINM="$1"

if [ -z $WINM ]; then
	if [ -z "`which Xquartz`" ]; then
		WINM="X11"
	else
		WINM="quartz-wm"
	fi
fi

WINM_NAME="X11"

if [ "$WINM" == "quartz-wm" ]; then
	WINM_NAME="XQuartz"
fi

osascript << EOT
try
tell application "System Events"
if (name of processes) does not contain "$WINM" then
launch application "$WINM_NAME"
end if
end tell
end try
EOT

ITERATOR=0
DISPLAYVAR=""

while [ $ITERATOR -lt 9 -a -z "$DISPLAYVAR" ]; do
RETURN=$(osascript << EOT
try
tell application "System Events"
if (name of processes) contains "$WINM" then
return "1"
end if
end tell
end try
EOT
)
	if [ -z "$DISPLAY" -a -z "$RETURN" ]; then
		sleep 1
	else
		DISPLAYVAR="1"
	fi
	ITERATOR="$((( $ITERATOR + 1 )))"
done

echo `ps ax | grep $WINM_NAME`

if [ -n "$RETURN" ]; then
	if [ -z "$DISPLAY" ]; then
		DISPLAY="$DEFAULTDISPLAY" $INKSCAPE -g &
	else
		$INKSCAPE -g &
	fi	
fi

exit 0
