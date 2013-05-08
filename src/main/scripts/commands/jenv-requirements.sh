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

# display jenv version
function __jenvtool_requirements {
	echo "Following commands are required for jenv:"
	echo "====================================================="
	for cmdName in sed tar git svn curl grep unzip complete
	do
	   type $cmdName >/dev/null 2>&1
	   if [ "$?" -eq "0" ] ; then
	      printf "\e[32m%12s %15s\e[00m\n" "${cmdName}" "Available"
	   else
	      printf "\e[31m%12s %15s\e[00m\n" "${cmdName}" "Unavailable"
	   fi
	done
}
