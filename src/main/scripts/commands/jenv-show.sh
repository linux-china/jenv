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

# show candidate information
# @param $1 candidate name
function __jenvtool_show {
	CANDIDATE=`echo "$1" | tr '[:upper:]' '[:lower:]'`
	CANIDATE_INFO=$(curl -L -s "http://jenv.mvnsearch.org/candidate/${CANDIDATE}?format=txt")
	echo "${CANIDATE_INFO}"
}
