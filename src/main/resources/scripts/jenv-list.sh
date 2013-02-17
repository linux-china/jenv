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

function __jenvtool_list {
	CANDIDATE="$1"
	__jenvtool_check_candidate_present "${CANDIDATE}" || return 1
	__jenvtool_build_version_csv "${CANDIDATE}"
	__jenvtool_determine_current_version "${CANDIDATE}"
	if [[ "${JENV_ONLINE}" == "false" ]]; then
		__jenvtool_offline_list
	else
		FRAGMENT=$(curl -s "${JENV_SERVICE}/candidates/${CANDIDATE}/list?platform=${JENV_PLATFORM}&current=${CURRENT}&installed=${CSV}")
		echo "${FRAGMENT}"
		unset FRAGMENT
	fi
}
