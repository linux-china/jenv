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
	CANDIDATE="$1"
	__jenvtool_check_candidate_present "${CANDIDATE}" || return 1
	__jenvtool_build_version_csv "${CANDIDATE}"
	__jenvtool_determine_current_version "${CANDIDATE}"
    CANDIDATE_VERSIONS=($(cat "${JENV_DIR}/db/${CANDIDATE}.txt"))
    echo "Available ${CANDIDATE} Versions"
    echo "========================="
    for candidate_version in "${CANDIDATE_VERSIONS[@]}" ; do
     if [[ "${candidate_version}" == "${CURRENT}" ]]; then
          echo ">* ${candidate_version}"
     elif __jenvtool_contains "${CSV}" "${candidate_version}"; then
          echo "*  ${candidate_version}"
     else
          echo "   ${candidate_version}"
     fi
    done
    unset candidate_version
	unset CANDIDATE_VERSIONS
}
