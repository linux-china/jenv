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

# help display
# @Globals JENV_CANDIDATES JENV_CANDIDATES_DEFAULT
function __jenvtool_help {
	echo ""
	echo "Usage: jenv <command> <candidate> [version]"
	echo ""
	echo "   command    :  install, uninstall, list, use, pause, current, cd, version, default, update, selfupdate or help"
	echo "   candidate  :  $(echo "${JENV_CANDIDATES[@]:-${JENV_CANDIDATES_DEFAULT[@]}}" | sed -E 's/ /, /g')"
	echo "   version    :  optional, defaults to latest stable if not provided"
	echo ""
	echo "eg: jenv candidates"
	echo "eg: jenv install maven 3.0.4"
	echo "Author: linux_china, @linux_china on weibo and twitter"
}
