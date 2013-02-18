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

# use candidate with the version
# @param $1 candidate name
# @param $2 candidate version
function __jenvtool_use {
	CANDIDATE=`echo "$1" | tr '[:upper:]' '[:lower:]'`
	__jenvtool_check_candidate_present "${CANDIDATE}" || return 1
	__jenvtool_determine_version "$2" || return 1

	if [[ ! -d "${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}" ]]; then
		echo ""
		echo "Stop! ${CANDIDATE} ${VERSION} is not installed."
		if [[ "${jenv_auto_answer}" != 'true' ]]; then
			echo -n "Do you want to install it now? (Y/n): "
			read INSTALL
		fi
		if [[ -z "${INSTALL}" || "${INSTALL}" == "y" || "${INSTALL}" == "Y" ]]; then
			__jenvtool_install_candidate_version "${CANDIDATE}" "${VERSION}"
		else
			return 1
		fi
	fi
    # validate current version and used version
    __jenvtool_determine_current_version "${CANDIDATE}"
    if [[  "${CURRENT}" != "$2" ]]; then
        # Just update the *_HOME and PATH for this shell.
       	UPPER_CANDIDATE=`echo "${CANDIDATE}" | tr '[:lower:]' '[:upper:]'`
       	export "${UPPER_CANDIDATE}_HOME"="${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}"
       	if ! __jenvtool_contains "$PATH" "${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}"; then
       	if [ -e "${JENV_DIR}/candidates/${CANDIDATE}/current/bin" ]; then
       	        export PATH="${JENV_DIR}/candidates/${CANDIDATE}/current/bin:$PATH"
       	    else
       	        export PATH="${JENV_DIR}/candidates/${CANDIDATE}/current:$PATH"
       	    fi
       	fi
	fi
	echo ""
	echo "Using ${CANDIDATE} version ${VERSION} in this shell."
}
