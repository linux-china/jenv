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

# pause candidate with the version
# @param $1 candidate name
# @param $2 candidate version
function __jenvtool_pause {
	CANDIDATE=`echo "$1" | tr '[:upper:]' '[:lower:]'`
	VERSION="$2"
    if [[ -z "$2" ]]; then
       VERSION="current"
    fi
    #unlink current
    if [ -L "${JENV_DIR}/candidates/${CANDIDATE}/current" ]; then
    	unlink "${JENV_DIR}/candidates/${CANDIDATE}/current"
    fi
    #remove from path
    __jenvtool_path_remove_candidate "${CANDIDATE}" "${VERSION}"
    #unset home
    UPPER_CANDIDATE=`echo "${CANDIDATE}" | tr '[:lower:]' '[:upper:]'`
    unset "${UPPER_CANDIDATE}_HOME"
    __jenvtool_utils_echo_green "${CANDIDATE} paused!"
}
