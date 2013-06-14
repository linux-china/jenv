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

# reinstall candidate with the version
# @param $1 candidate name
# @param $2 candidate version
# @param $3 local install folder for candidate with the version. optional
function __jenvtool_reinstall {
	CANDIDATE=`echo "$1" | tr '[:upper:]' '[:lower:]'`
	VERSION="$2"
	LOCAL_FOLDER="$3"
	if [ -d "${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}" ]; then
		echo "Uninstalling ${CANDIDATE} ${VERSION}"
	    rm -rf "${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}"
    fi
    rm -rf "${JENV_DIR}/archives/${CANDIDATE}-${VERSION}.zip"
    __jenvtool_utils_echo_green "Uninstall done!"
    __jenvtool_install "${CANDIDATE}" "${VERSION}" "${LOCAL_FOLDER}"
}

