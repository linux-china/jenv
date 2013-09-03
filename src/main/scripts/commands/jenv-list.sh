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
	__jenvtool_candidate_is_present "${CANDIDATE}" || return 1
	CURRENT=$(__jenvtool_candidate_current_version "${CANDIDATE}")
	CANDIDATE_VERSIONS=($(__jenvtool_candidate_versions "${CANDIDATE}"))
    INSTALLED_VERSIONS=()
    # add local unversioned in repository
    for version in $(ls -1 "${JENV_DIR}/candidates/${CANDIDATE}" 2> /dev/null); do
    	if [ "${version}" != 'current' ]; then
    	     INSTALLED_VERSIONS=("${INSTALLED_VERSIONS[@]}" "${version}")
             if ! __jenvtool_utils_array_contains "CANDIDATE_VERSIONS[@]" "${version}"; then
                 CANDIDATE_VERSIONS=("${CANDIDATE_VERSIONS[@]}" "${version}")
             fi
        fi
    done
    echo "Available ${CANDIDATE} Versions"
    echo "========================="
    CANDIDATE_VERSIONS=($(for a in "${CANDIDATE_VERSIONS[@]}"; do echo "$a"; done | sort -r))
    for candidate_version in "${CANDIDATE_VERSIONS[@]}" ; do
     if [[ "${candidate_version}" == "${CURRENT}" ]]; then
          echo ">* ${candidate_version}"
     elif __jenvtool_utils_array_contains "INSTALLED_VERSIONS[@]" "${candidate_version}"; then
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
 CANDIDATE_COUNT=0
 BASE_DIR="${JENV_DIR}/candidates"
 for CANDIDATE in $(ls -1 "${BASE_DIR}" 2> /dev/null) ; do
       echo "${CANDIDATE}";
       CANDIDATE_COUNT=$(( ${CANDIDATE_COUNT} +1 ))
       CURRENT=$(__jenvtool_candidate_current_version "${CANDIDATE}")
       for VERSION in $(__jenvtool_candidate_installed_versions "${CANDIDATE}") ; do
          if [[ "${VERSION}" == "${CURRENT}" ]]; then
              echo "* ${VERSION}"
          else
              echo "  ${VERSION}"
          fi
       done
 done
 __jenvtool_utils_echo_green "${CANDIDATE_COUNT} candidates installed."
}
