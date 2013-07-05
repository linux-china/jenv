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

# use candidate with the version
# @param $1 candidate name
# @param $2 candidate version
function __jenvtool_use {
	CANDIDATE=`echo "$1" | tr '[:upper:]' '[:lower:]'`
	__jenvtool_candidate_is_present "${CANDIDATE}" || return 1
	__jenvtool_version_determine "$2" || return 1

	if [[ ! -d "${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}" ]]; then
		__jenvtool_utils_echo_red "Stop! ${CANDIDATE} ${VERSION} is not installed."
		echo -n "Do you want to install it now? (Y/n): "
		read INSTALL
		if [[ -z "${INSTALL}" || "${INSTALL}" == "y" || "${INSTALL}" == "Y" ]]; then
			__jenvtool_install "${CANDIDATE}" "${VERSION}"
		else
			return 1
		fi
	fi
    # validate current version and used version
    CURRENT=$(__jenvtool_candidate_current_version "${CANDIDATE}")
    if [[  "${CURRENT}" != "$2" ]]; then
        # Just update the *_HOME and PATH for this shell.
       	UPPER_CANDIDATE=`echo "${CANDIDATE}" | tr '[:lower:]' '[:upper:]'`
       	export "${UPPER_CANDIDATE}_HOME"="${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}"
       	if ! __jenvtool_utils_string_contains "$PATH" "${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}"; then
       	    __jenvtool_path_add_candidate "${CANDIDATE}" "${VERSION}"
       	fi
       	if [ -f "${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}/autorun.sh" ]; then
       	   source "${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}/autorun.sh"
       	fi
	fi
	__jenvtool_utils_echo_green "Using ${CANDIDATE} version ${VERSION} in this shell."
}
