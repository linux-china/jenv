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

# execute under candidate
# @param $1 candidate name
# @param $2 candidate version
# @param $3 command
function __jenvtool_execute {
	CANDIDATE=`echo "$1" | tr '[:upper:]' '[:lower:]'`
	VERSION="$2"
	SCRIPT_NAME="$3"
	SCRIPT_ARGS="$4 $5 $6 $7 $8 $9"
	#deal with version is absent
    if [[ ! -d "${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}" ]]; then
       VERSION="current"
       SCRIPT_NAME="$2"
       SCRIPT_ARGS="$3 $4 $5 $6 $7 $8 $9"
    fi
    #validat exits
    if [ -f "${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}/${SCRIPT_NAME}" ]; then
      SCRIPT_PATH="${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}/${SCRIPT_NAME}"
    elif [ -f "${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}/bin/${SCRIPT_NAME}" ]; then
      SCRIPT_PATH="${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}/bin/${SCRIPT_NAME}"
    elif [ -f "${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}/tools/${SCRIPT_NAME}" ]; then
      SCRIPT_PATH="${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}/tools/${SCRIPT_NAME}"
    else
       __jenvtool_utils_echo_red "${SCRIPT_NAME} not found under ${CANDIDATE}"
    fi
    #execute
    if [[ ! -z "${SCRIPT_PATH}" ]]; then
        (${SCRIPT_PATH} ${SCRIPT_ARGS})
        unset SCRIPT_PATH
    fi
    unset SCRIPT_NAME
    unset SCRIPT_ARGS
}
