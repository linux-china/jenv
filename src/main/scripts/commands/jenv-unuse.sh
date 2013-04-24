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

# unuse candidate with the version
# @param $1 candidate name
# @param $2 candidate version
function __jenvtool_unuse {
	CANDIDATE=`echo "$1" | tr '[:upper:]' '[:lower:]'`
	VERSION="$2"
    if [[ -z "$2" ]]; then
       VERSION="current"
    fi
    if ! __jenvtool_contains "$PATH" "${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}"; then
         if [ -e "${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}/bin" ]; then
          	__jenvtool_path_remove "${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}/bin"
         elif [ -d "${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}/tools" ]; then
          	__jenvtool_path_remove "${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}/tools"
         else
          	__jenvtool_path_remove "${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}"
         fi
    fi
}
