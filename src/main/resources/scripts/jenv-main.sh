#!/bin/bash

#
#   Copyright 2012 Jacky Chan
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

function jenv {
	#
	# Various sanity checks and default settings
	#
	__jenvtool_default_environment_variables
	mkdir -p "${JENV_DIR}"

	BROADCAST_LIVE=$(curl -s "${JENV_SERVICE}/broadcast/${JENV_VERSION}")
	if [[ -z "${BROADCAST_LIVE}" && "${JENV_ONLINE}" == "true" ]]; then
		echo "${OFFLINE_BROADCAST}"
	fi

	if [[ -n "${BROADCAST_LIVE}" && "${JENV_ONLINE}" == "false" ]]; then
		echo "${ONLINE_BROADCAST}"
	fi

	if [[ -z "${BROADCAST_LIVE}" ]]; then
		JENV_ONLINE="false"
	else
		JENV_ONLINE="true"
	fi

   COMMAND="$1"

	__jenvtool_check_upgrade_available "${COMMAND}"
	if [[ -n "${UPGRADE_AVAILABLE}" && ( "$1" != "broadcast" ) ]]; then
		echo "${BROADCAST_LIVE}"
		echo ""
	else
		__jenvtool_update_broadcast "${COMMAND}"
	fi

	# Load the jenv config if it exists.
	if [ -f "${JENV_DIR}/etc/config" ]; then
		source "${JENV_DIR}/etc/config"
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
	CMD_TARGET="${JENV_DIR}/src/jenv-${COMMAND}.sh"
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
		echo "Invalid command: $1"
		__jenvtool_help
	fi

	# Check whether the candidate exists
	if [[ -n "$2" && -z $(echo ${JENV_CANDIDATES[@]} | grep -w "$2") ]]; then
		echo -e "\nStop! $2 is not a valid candidate."
		return 1
	fi

	# Execute the requested command
	if [ -n "${CMD_FOUND}" ]; then
		# It's available as a shell function
		__jenvtool_"${CONVERTED_CMD_NAME}" "$2" "$3" "$4"
	fi
}
