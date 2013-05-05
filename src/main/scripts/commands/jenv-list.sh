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

# list candidate versions
# @param $1 candidate name
function __jenvtool_list {
    #list installed candidates
    if [[ -z "$1" ]]; then
      __jenvtool_list_installed_candidates
      return 0;
    fi
    # list candidate versions
	CANDIDATE=`echo "$1" | tr '[:upper:]' '[:lower:]'`
	__jenvtool_check_candidate_present "${CANDIDATE}" || return 1
	__jenvtool_determine_current_version "${CANDIDATE}"
	CANDIDATE_VERSIONS=()
	# default versions
	if [[ -f "${JENV_DIR}/db/${CANDIDATE}.txt" ]] ; then
	   CANDIDATE_VERSIONS=($(cat "${JENV_DIR}/db/${CANDIDATE}.txt"))
	fi
	# repository versions
	for repo in $(ls -1 "${JENV_DIR}/repo" 2> /dev/null); do
       if [ -f "${JENV_DIR}/repo/${repo}/version/${CANDIDATE}.txt" ]; then
         for candidate_version in $(cat "${JENV_DIR}/repo/${repo}/version/${CANDIDATE}.txt"); do
           if ! __jenvtool_array_contains CANDIDATE_VERSIONS[@] "${candidate_version}"; then
              CANDIDATE_VERSIONS=("${CANDIDATE_VERSIONS[@]}" "${candidate_version}")
           fi
         done
       fi
    done
    INSTALLED_VERSIONS=()
    # add local unversioned in repository
    for version in $(ls -1 "${JENV_DIR}/candidates/${CANDIDATE}" 2> /dev/null); do
    	if [ "${version}" != 'current' ]; then
    	     INSTALLED_VERSIONS=("${INSTALLED_VERSIONS[@]}" "${version}")
             if ! __jenvtool_array_contains CANDIDATE_VERSIONS[@] "${version}"; then
                 CANDIDATE_VERSIONS=("${CANDIDATE_VERSIONS[@]}" "${version}")
             fi
        fi
    done
    echo "Available ${CANDIDATE} Versions"
    echo "========================="
    for candidate_version in "${CANDIDATE_VERSIONS[@]}" ; do
     if [[ "${candidate_version}" == "${CURRENT}" ]]; then
          echo ">* ${candidate_version}"
     elif __jenvtool_array_contains INSTALLED_VERSIONS[@] "${candidate_version}"; then
          echo " * ${candidate_version}"
     else
          echo "   ${candidate_version}"
     fi
    done
    unset candidate_version
	unset CANDIDATE_VERSIONS
}

# list installed candidates
__jenvtool_list_installed_candidates() {
 echo "Installed candidates"
 echo "========================================================="
 CANDIDATE_COUNT=1
 BASE_DIR="${JENV_DIR}/candidates"
 BASE_DIR2="${BASE_DIR}/"
 for i in "${BASE_DIR}"/*;do
    if [ -d "$i" ];then
       CANDIDATE=${i/"${BASE_DIR2}"/''}
       echo "${CANDIDATE}";
       CANDIDATE_COUNT=$(( ${CANDIDATE_COUNT} +1 ))
       __jenvtool_determine_current_version "${CANDIDATE}"
       for j in "$i"/*;do
         if ! __jenvtool_contains "$j" "current"; then
           BASE_DIR3="${i}/"
           VERSION=${j/"${BASE_DIR3}"/''}
           if [[ "${VERSION}" != "*" ]]; then
               if [[ "${VERSION}" == "${CURRENT}" ]]; then
                   echo "* ${VERSION}"
               else
                   echo "  ${VERSION}"
               fi
           fi
         fi
       done
    fi
 done
 __jenvtool_echo_green "${CANDIDATE_COUNT} candidates installed."
}
