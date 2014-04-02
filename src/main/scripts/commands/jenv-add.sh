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

# add candidate into local repository
# @param $1 candidate name
# @param $2 candidate version
function __jenvtool_add {
	CANDIDATE=`echo "$1" | tr '[:upper:]' '[:lower:]'`
	mkdir -p "${JENV_DIR}/repo/local"
	# update candidates file to add candidate
	candidates_file="${JENV_DIR}/repo/local/candidates"
	if [ -f "${candidates_file}" ]; then
	   CANDIDATES=($(cat "${candidates_file}"))
	   if [[ ${#CANDIDATES[@]} == 0 ]]; then  # empty file
	       echo -n "${CANDIDATE}" > "${candidates_file}"
	       JENV_CANDIDATES=("${JENV_CANDIDATES[@]}" "${CANDIDATE}")
	       export JENV_CANDIDATES
	   else
	      if ! __jenvtool_utils_array_contains "CANDIDATES[@]" "${CANDIDATE}"; then
	      	  echo -n " ${CANDIDATE}" >> "${candidates_file}"
	      	  JENV_CANDIDATES=("${JENV_CANDIDATES[@]}" "${CANDIDATE}")
	      	  export JENV_CANDIDATES
	      fi
	   fi
	   unset CANDIDATES
	else
	   echo -n "${CANDIDATE}" > "${candidates_file}"
	   echo "Local Candidate List" > "${JENV_DIR}/repo/local/candidates.txt"
	   echo "==================================" >> "${JENV_DIR}/repo/local/candidates.txt"
	fi
	unset candidates_file
	# add version
	if [[ ! -z "$2" ]] ; then
        mkdir -p "${JENV_DIR}/repo/local/version"
        version_file="${JENV_DIR}/repo/local/version/${CANDIDATE}.txt"
        if [ -f "${version_file}" ]; then
           VERSIONS=($(cat "${version_file}"))
           if [[ ${#VERSIONS[@]} == 0 ]]; then  # empty file
              echo -n "$2" > "${version_file}"
           else
              # append version
              if ! __jenvtool_utils_array_contains "VERSIONS[@]" "$2"; then
                 echo -n " $2" >> "${version_file}"
              fi
           fi
           unset VERSIONS
        else
          echo -n "$2" > "${version_file}"
        fi
        unset version_file
	fi
	echo "${CANDIDATE} with $2 added!"
}
