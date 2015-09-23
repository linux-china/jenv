#!/bin/bash

#
#   Copyright 2012 Marco Vermeulen, Jacky Chan
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

# jenv load for jenvrc
# @Globals JENV_CANDIDATES JENV_CANDIDATES_DEFAULT
function __jenvtool_load {
	 if [[ -f "${PWD}/jenvrc" ]]; then
     echo "==============jenv load======================"
     while read entry
     do
       if ! __jenvtool_utils_string_contains "$entry", "#" ; then
            candidate1=`echo ${entry} | sed 's/=.*//g'`
            version1=`echo ${entry} | sed 's/.*=//g'`
            if [ -d "${JENV_DIR}/candidates/${candidate1}/${version1}" ]; then
                __jenvtool_use "${candidate1}" "${version1}"
            else
                __jenvtool_install "${candidate1}" "${version1}"
            fi
            unset candidate1
            unset version1
       fi
     done < "${PWD}/jenvrc"
  fi
}
