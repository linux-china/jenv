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

# jenv repository operation
# @param $1 repo command
function __jenvtool_repo {
	repo_cmd="$1"
	if [[ -z "${repo_cmd}" ]]; then # list repositories
	   BASE_DIR="${JENV_DIR}/repo"
	   for repo_name in $(ls -1 "${BASE_DIR}" 2> /dev/null) ; do
	     repo_url=""
	     if [[ -f "${JENV_DIR}/repo/${repo_name}/url.txt" ]] ; then
	        repo_url=$(cat "${JENV_DIR}/repo/${repo_name}/url.txt")
	     fi
	     echo "${repo_name}: ${repo_url}"
	   done
	elif [[ "${repo_cmd}" == "add" ]] ; then # add repository
	   repo_name="$2"
	   repo_url="$3"
	   if [[ ! -d "${JENV_DIR}/repo/${repo_name}" ]] ; then
	      echo "Begin to install ${repo_name} from ${repo_url}"
          __jenvtool_add_repo "${repo_name}" "${repo_url}"
          echo "${repo_name} installed"
       else
          echo "${repo_name} has been installed!"
       fi
       __jenvtool_candidate_reload_all
	elif [[ "${repo_cmd}" == "update" ]] ; then # update all repositories
	   echo "Updating all repositories"
	   __jenvtool_update_repositories
	   __jenvtool_candidate_reload_all
	   __jenvtool_utils_echo_green "Repositories upgraded!"
	fi
}

# add repository
# @param $1 repo name
# @param $2 repo url
function __jenvtool_add_repo {
  if [[ "$1" != "local" ]]; then
     __jenv_update_repository "$1" "$2"
  fi
}

# update all repositories
function __jenvtool_update_repositories {
    BASE_DIR="${JENV_DIR}/repo"
	for repo_name in $(ls -1 "${BASE_DIR}" 2> /dev/null) ; do
	   repo_url=""
	   if [[ -f "${JENV_DIR}/repo/${repo_name}/url.txt" ]] ; then
	        repo_url=$(cat "${JENV_DIR}/repo/${repo_name}/url.txt")
	   fi
	   if [ ! -z "${repo_url}" ] ; then
	     echo "Begin to update ${repo_name}"
	     __jenv_update_repository "${repo_name}" "${repo_url}"
	     echo "${repo_name} updated!"
	   fi
	done
}

# update jenv repository
# @param $1 repository name
# @param $2 repository url
function __jenv_update_repository {
  repo_name="${1}"
  repo_url="${2}"
  jenv_tmp_zip="${JENV_DIR}/tmp/repo-${repo_name}.zip"
  mkdir -p "${JENV_DIR}/tmp"
  curl -L -s "${repo_url}/info.zip?osName=${JENV_OS_NAME}&platform=${JENV_MACHINE_PLATFORM}" > "${jenv_tmp_zip}"
  mkdir -p "${JENV_DIR}/repo"
  if [[ -d "${JENV_DIR}/repo/${repo_name}"  ]] ; then
      rm -rf "${JENV_DIR}/repo/${repo_name}"
  fi
  if [[ "${JENV_OS_NAME}" == 'Cygwin' ]]; then
  	unzip -qo $(cygpath -w "${jenv_tmp_zip}") -d "${JENV_DIR}/repo/${repo_name}"
  else
  	unzip -qo "${jenv_tmp_zip}" -d "${JENV_DIR}/repo/${repo_name}"
  fi
  rm -rf "${jenv_tmp_zip}"
}