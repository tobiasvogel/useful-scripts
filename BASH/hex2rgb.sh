#!/bin/bash
hex=`echo $1 | tr '[:lower:]' '[:upper:]' | tr -d '#'` # make all uppercase, remove hash

if [ -z "${hex}" ]; then # check if color specified
	echo "Usage: `basename ${0}` COLOR"
	echo ""
	exit 127
fi

if [ "${#hex}" == "6" ]; then # check if hex string length is 6
	printf "%d %d %d\n" 0x${hex:0:2} 0x${hex:2:2} 0x${hex:4:2}
elif [ "${#hex}" == "3" ]; then # check if hex string length is 3
	printf "%d %d %d\n" 0x${hex:0:1} 0x${hex:1:1} 0x${hex:2:1}
else # or else die...
	echo "Invalid color specified."
	exit 1
fi

exit 0
