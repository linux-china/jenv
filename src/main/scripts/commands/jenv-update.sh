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

# update command
# @param $1 candidate name
# @param $2 candidate version
function __jenvtool_update {
	CANDIDATE=`echo "$1" | tr '[:upper:]' '[:lower:]'`
    VERSION="$2"
    if [[ -z "${VERSION}" ]]; then
       VERSION="current"
    fi
	if [ -d "${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}/.git" ]; then
	  echo "Updating..."
      (cd "${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}/" && git pull)
      __jenvtool_echo_green "${CANDIDATE}'s ${VERSION} has been updated!"
     else
      __jenvtool_echo_red "${CANDIDATE}'s ${VERSION} is not git repository!"
	fi
}
