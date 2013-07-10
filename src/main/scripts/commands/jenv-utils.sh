#!/bin/sh

# echo as red text
# @param $1 text
function __jenvtool_utils_echo_red {
   echo $'\e[31m'"$1"$'\e[00m'
}

# echo as green text
# @param $1 text
function __jenvtool_utils_echo_green {
   echo $'\e[32m'"$1"$'\e[00m'
}

# contains function
# @param $1 text
# @param $2 word
# @return contained test condition
function __jenvtool_utils_string_contains {
    replaced=$(echo "$1" | sed -e s,"$2",,g)
    [ "$replaced" != "$1" ]
}

# arrays contains item
# @param $1 array such as array[@]
# @param $2 item value
function __jenvtool_utils_array_contains {
   argAry1=("${!1}")
   for i in ${argAry1[@]}; do
     if [[ "$i" == "$2" ]]; then
       return 0
     fi
   done
   return 1
}

# validate zip file
# @param $1 zip file
function __jenvtool_utils_zip_validate {
	ZIP_ARCHIVE="$1"
	ZIP_OK=$(unzip -t "${ZIP_ARCHIVE}" | grep 'No errors detected in compressed data')
	if [ -z "${ZIP_OK}" ]; then
		rm "${ZIP_ARCHIVE}"
		echo ""
		__jenvtool_utils_echo_red "Stop! The archive was corrupt and has been removed! Please try installing again."
		return 1
	fi
}
