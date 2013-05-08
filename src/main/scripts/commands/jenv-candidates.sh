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

# display candidates
# @Globals JENV_DIR
function __jenvtool_candidates {
     for repo in $(ls -1 "${JENV_DIR}/repo" 2> /dev/null); do
         if [ -f "${JENV_DIR}/repo/${repo}/candidates.txt" ]; then
            echo ""
            cat "${JENV_DIR}/repo/${repo}/candidates.txt"
         fi
     done
}
