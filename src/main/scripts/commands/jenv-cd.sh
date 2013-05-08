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

# change directory to candidate install directory
# @param $1 candidate name
# @param $2 candidate version
function __jenvtool_cd {
	CANDIDATE=`echo "$1" | tr '[:upper:]' '[:lower:]'`
	__jenvtool_candidate_is_present "${CANDIDATE}" || return 1

	VERSION="$2"
    if [[ -z "$2" ]]; then
        VERSION=$(__jenvtool_candidate_current_version "${CANDIDATE}")
    fi

	if [[ -d "${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}" ]]; then
		cd ${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}
	fi
}
