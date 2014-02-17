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

# display candidate current version
# @param $1 candidate name
function __jenvtool_which {
	if [ -n "$1" ]; then
		CANDIDATE=`echo "$1" | tr '[:upper:]' '[:lower:]'`
		CURRENT=$(__jenvtool_candidate_current_version "${CANDIDATE}")
		if [ -n "${CURRENT}" ]; then
			echo "Using ${CANDIDATE} with ${CURRENT} under ${JENV_DIR}/candidates/${CANDIDATE}/${CURRENT}"
		else
			echo "Not using any version of ${CANDIDATE}"
		fi
	else
		__jenvtool_utils_echo_red "Please supply a candidate name!"
	fi
}
