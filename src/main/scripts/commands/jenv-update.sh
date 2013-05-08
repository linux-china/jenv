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

# update command
# @param $1 candidate name
# @param $2 candidate version
function __jenvtool_update {
    # update all candidates
    if [[ -z "$1" ]]; then
        for i in "$HOME/.jenv/candidates"/*;do
            if [ -d "$i" ];then
               for j in "$i"/*;do
                 if ! __jenvtool_utils_string_contains "$j" "current"; then
                   if [ -d "$j/.git" ];then
                        echo "Pulling..."
                        (cd "${j}" && git pull)
                        __jenvtool_utils_echo_green "${j} has been updated!"
                   elif [ -d "$j/.svn" ];then
                        echo "Updating..."
                        (cd "${j}" && svn update)
                        __jenvtool_utils_echo_green "${j} has been updated!"
                   fi
                 fi
                done
            fi
         done
         return 0;
    fi
    # update candidate with version
	CANDIDATE=`echo "$1" | tr '[:upper:]' '[:lower:]'`
    VERSION="$2"
    if [[ -z "${VERSION}" ]]; then
       VERSION="current"
    fi
	if [ -d "${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}/.git" ]; then
	    echo "Git pulling ${CANDIDATE}..."
        (cd "${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}/" && git pull)
        __jenvtool_utils_echo_green "${CANDIDATE}'s ${VERSION} has been updated!"
     elif [ -d "${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}/.svn" ]; then
        echo "Subversion updating ${CANDIDATE}..."
        (cd "${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}/" && svn update)
         __jenvtool_utils_echo_green "${CANDIDATE}'s ${VERSION} has been updated!"
     else
      __jenvtool_utils_echo_red "${CANDIDATE}'s ${VERSION} is not a Git or Subversion repository!"
	fi
}
