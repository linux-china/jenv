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

# install candidate with the version
# @param $1 candidate name
# @param $2 candidate version
# @param $3 local install folder for candidate with the version. optional
function __jenvtool_install {
	CANDIDATE=`echo "$1" | tr '[:upper:]' '[:lower:]'`
	VERSION="$2"
	LOCAL_FOLDER="$3"
     # install from local or VCS
    if [[ -n "${LOCAL_FOLDER}" ]]; then
         if __jenvtool_utils_string_contains "${LOCAL_FOLDER}" "http://"; then
            __jenvtool_install_remote_candidate "${CANDIDATE}" "${VERSION}" "${LOCAL_FOLDER}" || return 1
        elif  __jenvtool_utils_string_contains "${LOCAL_FOLDER}" "@"; then
            __jenvtool_install_git_repository "${CANDIDATE}" "${VERSION}" "${LOCAL_FOLDER}" || return 1
		else
		    __jenvtool_install_local_version "${CANDIDATE}" "${VERSION}" "${LOCAL_FOLDER}" || return 1
		fi
    else # install from center repository
        __jenvtool_candidate_is_present "${CANDIDATE}" || return 1
    	# check version if not empty
        if [[ -n "$2" ]]; then
    	   __jenvtool_version_determine "$2" "$3" || return 1
    	fi
    	# if version absent, use first one in version list
        if [[ -z "$2" ]]; then
            CANDIDATE_VERSIONS=($(__jenvtool_candidate_versions "${CANDIDATE}"))
            if [[ "${JENV_SHELL}" == "bash" ]]; then
                VERSION="${CANDIDATE_VERSIONS[0]}"
            else
                VERSION="${CANDIDATE_VERSIONS[1]}"
            fi
        fi
        # validate installed?
    	if [[ -d "${JENV_DIR}/${CANDIDATE}/${VERSION}" || -h "${JENV_DIR}/${CANDIDATE}/${VERSION}" ]]; then
    		__jenvtool_utils_echo_red "Stop! ${CANDIDATE} ${VERSION} is already installed."
    		return 1
    	fi

    	__jenvtool_install_remote_candidate "${CANDIDATE}" "${VERSION}" || return 1
    fi

	# confirm by prompt
	if [[ "${JENV_AUTO}" == "false" ]]; then
	   echo -n "Do you want ${CANDIDATE} ${VERSION} to be set as default? (Y/n): "
	   read USE
	fi
	if [[ "${JENV_AUTO}" == "true" ||  -z "${USE}" || "${USE}" == "y" || "${USE}" == "Y" ]]; then
		__jenvtool_utils_echo_green "Setting ${CANDIDATE} ${VERSION} as default."
		__jenvtool_candidate_link_version "${CANDIDATE}" "${VERSION}"
	fi
	# done message
	__jenvtool_utils_echo_green "Done installing!"
}

# install local installed candidate
# @param $1 candidate name
# @param $2 candidate version
# @param $3 local install folder for candidate with the version. optional
function __jenvtool_install_local_version {
	CANDIDATE="$1"
	VERSION="$2"
	LOCAL_FOLDER="$3"
	mkdir -p "${JENV_DIR}/candidates/${CANDIDATE}"
	echo "Copying ${CANDIDATE} ${VERSION} from ${LOCAL_FOLDER}"
	cp -rf "${LOCAL_FOLDER}" "${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}"
}

# install git repository
# @param $1 candidate name
# @param $2 candidate version
# @param $3 git repository url
function __jenvtool_install_git_repository {
	CANDIDATE="$1"
	VERSION="$2"
	GIT_REPO="$3"
	mkdir -p "${JENV_DIR}/candidates/${CANDIDATE}"
	echo "Clone ${CANDIDATE} ${VERSION} from ${GIT_REPO}"
	git clone "${GIT_REPO}" "${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}"
}

# install svn repository
# @param $1 candidate name
# @param $2 candidate version
# @param $3 svn repository url
function __jenvtool_install_svn_repository {
	CANDIDATE="$1"
	VERSION="$2"
	SVN_REPO="$3"
	mkdir -p "${JENV_DIR}/candidates/${CANDIDATE}"
	echo "Checkout ${CANDIDATE} ${VERSION} from ${SVN_REPO}"
	svn checkout "${SVN_REPO}" "${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}"
}

# install candidate from remote repository
# @param $1 candidate name
# @param $2 candidate version
# @param $3 download url
function __jenvtool_install_remote_candidate {
	CANDIDATE="$1"
	VERSION="$2"
	DOWNLOAD_URL="$3"
	# install from archives directory
    echo "Installing: ${CANDIDATE} ${VERSION}"
    # find install url from jenv.mvnsearch.org
    if [[ -z "${DOWNLOAD_URL}" ]]; then
       repo=$(__jenvtool_repo_locate "${CANDIDATE}" "${VERSION}")
       if [ -f "${JENV_DIR}/repo/${repo}/url.txt" ] ; then
          repo_url=$(cat "${JENV_DIR}/repo/${repo}/url.txt")
          echo "Parsing http://jenv.mvnsearch.org/candidate/${CANDIDATE}/download/${VERSION}/${JENV_OS_NAME}/${JENV_MACHINE_PLATFORM}"
          DOWNLOAD_URL=$(curl -L -s "http://jenv.mvnsearch.org/candidate/${CANDIDATE}/download/${VERSION}/${JENV_OS_NAME}/${JENV_MACHINE_PLATFORM}")
       else
          echo "${repo} url is not available"
          return 1
       fi
    fi
    if __jenvtool_utils_string_contains "${DOWNLOAD_URL}" "http://" && __jenvtool_utils_string_contains "${DOWNLOAD_URL}" ".zip" ; then
       __jenvtool_candidate_download "${CANDIDATE}" "${VERSION}" "${DOWNLOAD_URL}"  || return 1
       mkdir -p "${JENV_DIR}/candidates/${CANDIDATE}"
       unzip -oq "${JENV_DIR}/archives/${CANDIDATE}-${VERSION}.zip" -d "${JENV_DIR}/tmp/"
       mv ${JENV_DIR}/tmp/*-${VERSION} "${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}"
    elif __jenvtool_utils_string_contains "${DOWNLOAD_URL}" "git"; then
       __jenvtool_install_git_repository "${CANDIDATE}" "${VERSION}" "${DOWNLOAD_URL}" || return 1
    elif __jenvtool_utils_string_contains "${DOWNLOAD_URL}" "svn"; then
       __jenvtool_install_svn_repository "${CANDIDATE}" "${VERSION}" "${DOWNLOAD_URL}" || return 1
    else
       __jenvtool_utils_echo_red "${DOWNLOAD_URL}"
       return 1
    fi
}
