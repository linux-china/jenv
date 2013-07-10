#!/bin/bash

#
#   Copyright 2013 Jacky Chan
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#

# jenv command, get command script and execute with candidate and version params
# @param $1 command
# @param $2 candidate name
# @param $3 candidate version
# @param $4 other param
function jenv {
	# Various sanity checks and default settings
	__jenvtool_app_default_environment_variables
	mkdir -p "${JENV_DIR}"

   COMMAND="$1"

   # alias
   if [[ "${COMMAND}" == "ls" ]]; then
    	COMMAND="list"
   elif [[ "${COMMAND}" == "all" ]]; then
       	COMMAND="candidates"
   elif [[ "${COMMAND}" == "exec" || "${COMMAND}" == "exe" ]]; then
         	COMMAND="execute"
   fi

	# Check whether the command exists as an internal function...
	#
	# NOTE Internal commands use underscores rather than hyphens,
	# hence the name conversion as the first step here.
	CONVERTED_CMD_NAME=`echo "${COMMAND}" | tr '-' '_'`

 	# no command provided
	if [[ -z "${COMMAND}" ]]; then
		__jenvtool_help
		return 1
	fi

	# Check if it is a valid command
	CMD_FOUND=""
	CMD_TARGET="${JENV_DIR}/commands/jenv-${COMMAND}.sh"
	if [[ -f "${CMD_TARGET}" ]]; then
		CMD_FOUND="${CMD_TARGET}"
	fi

	# Check if it is a sourced function
	CMD_TARGET="${JENV_DIR}/ext/jenv-${COMMAND}.sh"
	if [[ -f "${CMD_TARGET}" ]]; then
		CMD_FOUND="${CMD_TARGET}"
	fi

	# couldn't find the command
	if [[ -z "${CMD_FOUND}" ]]; then
		__jenvtool_utils_echo_red "Invalid command: $1"
		__jenvtool_help
	fi

	# Check whether the candidate exists
	candidate_ops=(cd default execute install list pause show uninstall use which)
	if __jenvtool_utils_array_contains "candidate_ops[@]" "${COMMAND}" ; then
        if [[ -n "$2" ]]; then
            CANDIDATE=`echo "$2" | tr '[:upper:]' '[:lower:]'`
            if [[ -z $(echo ${JENV_CANDIDATES[@]} | grep -w "${CANDIDATE}") ]]; then
                __jenvtool_utils_echo_red "Stop! ${CANDIDATE} is not a valid candidate."
                return 1
            fi
        fi
	fi
	unset candidate_ops

	# Execute the requested command
	if [ -n "${CMD_FOUND}" ]; then
		# It's available as a shell function
		__jenvtool_"${CONVERTED_CMD_NAME}" "$2" "$3" "$4"
	fi
}
