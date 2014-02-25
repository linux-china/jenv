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

# uninstall candidate with the version
# @param $1 candidate name
# @param $2 candidate version
function __jenvtool_uninstall {
	CANDIDATE=`echo "$1" | tr '[:upper:]' '[:lower:]'`
	VERSION="$2"
	__jenvtool_candidate_is_present "${CANDIDATE}" || return 1
	__jenvtool_version_is_present "${VERSION}" || return 1
    # unlink current
	CURRENT=$(readlink "${JENV_DIR}/candidates/${CANDIDATE}/current" | jenv_regex_sed "s|${JENV_DIR}/candidates/${CANDIDATE}/||g")
	if [[ -h "${JENV_DIR}/candidates/${CANDIDATE}/current" && ( "${VERSION}" == "${CURRENT}" ) ]]; then
		echo ""
		echo "Unselecting ${CANDIDATE} ${VERSION}"
		unlink "${JENV_DIR}/candidates/${CANDIDATE}/current"
	fi
	# delete candidate version directory
	if [ -d "${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}" ]; then
		echo "Uninstalling ${CANDIDATE} ${VERSION}"
		rm -rf "${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}"
		rm -rf "${JENV_DIR}/archives/${CANDIDATE}-${VERSION}.zip"
		__jenvtool_utils_echo_green "Uninstall done!"
    elif [[ -L "${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}" ]]; then
        echo "Uninstalling ${CANDIDATE} ${VERSION}"
        unlink "${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}"
        __jenvtool_utils_echo_green "Uninstall done!"
	else
		__jenvtool_utils_echo_red "${CANDIDATE} ${VERSION} is not installed."
	fi
}
