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
     if [ "$i" = "$2" ]; then
       return 0
     fi
   done
   return 1
}
