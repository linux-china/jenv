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

# default command
# @param $1 candidate name
# @param $2 candidate version
function __jenvtool_default {
	CANDIDATE=`echo "$1" | tr '[:upper:]' '[:lower:]'`
	__jenvtool_candidate_is_present "${CANDIDATE}" || return 1
	__jenvtool_version_determine "$2" || return 1

	if [ ! -d "${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}" ]; then
		__jenvtool_utils_echo_red "Stop! ${CANDIDATE} ${VERSION} is not installed."
		return 1
	fi

	__jenvtool_candidate_link_version "${CANDIDATE}" "${VERSION}"

	__jenvtool_utils_echo_green "Default ${CANDIDATE} version set to ${VERSION}"
}
