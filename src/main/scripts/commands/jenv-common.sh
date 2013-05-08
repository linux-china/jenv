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


#
# common internal function definitions
#

# check candidate present.
# @param $1 candidate name
function __jenvtool_check_candidate_present {
	if [ -z "$1" ]; then
		__jenvtool_echo_red "No candidate provided."
		__jenvtool_help
		return 1
	fi
}

# check candidate version present.
# @param $1 candidate version
function __jenvtool_check_version_present {
	if [ -z "$1" ]; then
		__jenvtool_echo_red "No candidate version provided."
		__jenvtool_help
		return 1
	fi
}

# determine candidate version.
# @param $1 candidate name
# @param $2 candidate version
# @return VERSION candidate version
function __jenvtool_determine_version {
    #check local installed version
    if [[ -d "${JENV_DIR}/candidates/${CANDIDATE}/$1" ]]; then
       VERSION="$1"
       return 0
    fi
    # candidate versions
    for candidate_version in $(__jenvtool_fetch_versions "${CANDIDATE}") ; do
       if [[ "${candidate_version}" == "$1" ]]; then
           VERSION="$1"
           return 0
       fi
    done
    echo ""
    __jenvtool_echo_red "Stop! $1 is not a valid ${CANDIDATE} version."
    return 1
}

# fetch versions
# @param $1 candidate names
function __jenvtool_fetch_versions {
     CANDIDATE="$1"
     CANDIDATE_VERSIONS=()
     for repo in $(ls -1 "${JENV_DIR}/repo" 2> /dev/null); do
       if [ -f "${JENV_DIR}/repo/${repo}/version/${CANDIDATE}.txt" ]; then
          for candidate_version in $(cat "${JENV_DIR}/repo/${repo}/version/${CANDIDATE}.txt"); do
             CANDIDATE_VERSIONS=("${CANDIDATE_VERSIONS[@]}" "${candidate_version}")
          done
       fi
    done
    echo "${CANDIDATE_VERSIONS[@]}"
}

# build candidate all version to csv
# @param $1 candidate name
# @return CSV candidate version csv
function __jenvtool_build_version_csv {
	CANDIDATE="$1"
	CSV=""
	for version in $(ls -1 "${JENV_DIR}/candidates/${CANDIDATE}" 2> /dev/null); do
		if [ ${version} != 'current' ]; then
			CSV="${version},${CSV}"
		fi
	done
	CSV=${CSV%?}
}

# determine candidate current version
# @param $1 candidate name
# @return CURRENT candidate current version number
function __jenvtool_determine_current_version {
	CANDIDATE="$1"
	CURRENT=$(echo $PATH | sed -E "s|.jenv/candidates/${CANDIDATE}/([^/]+)/bin|!!\1!!|1" | sed -E "s|^.*!!(.+)!!.*$|\1|g")
	if [[ "${CURRENT}" == "current" || "${CURRENT}" == "$PATH" ]]; then
	    unset CURRENT
	fi

	if [[ -z ${CURRENT} ]]; then
		CURRENT=$(readlink "${JENV_DIR}/candidates/${CANDIDATE}/current" | sed -e "s!${JENV_DIR}/candidates/${CANDIDATE}/!!g")
	fi
}

# download candidate with version
# @param $1 candidate name
# @param $2 candidate version
function __jenvtool_download {
	CANDIDATE="$1"
	VERSION="$2"
	DOWNLOAD_URL="$3"
	mkdir -p "${JENV_DIR}/archives"
	if [ ! -f "${JENV_DIR}/archives/${CANDIDATE}-${VERSION}.zip" ]; then
		echo ""
		echo "Downloading: ${CANDIDATE} ${VERSION}"
		echo ""
		ZIP_ARCHIVE="${JENV_DIR}/archives/${CANDIDATE}-${VERSION}.zip"
		echo "Downloading ${DOWNLOAD_URL}"
		curl -L "${DOWNLOAD_URL}" > "${ZIP_ARCHIVE}"
		__jenvtool_validate_zip "${ZIP_ARCHIVE}" || return 1
	else
		echo ""
		echo "Found a previously downloaded ${CANDIDATE} ${VERSION} archive. Not downloading it again..."
		__jenvtool_validate_zip "${JENV_DIR}/archives/${CANDIDATE}-${VERSION}.zip" || return 1
	fi
	echo ""
}

# validate zip file
# @param $1 zip file
function __jenvtool_validate_zip {
	ZIP_ARCHIVE="$1"
	ZIP_OK=$(unzip -t "${ZIP_ARCHIVE}" | grep 'No errors detected in compressed data')
	if [ -z "${ZIP_OK}" ]; then
		rm "${ZIP_ARCHIVE}"
		echo ""
		__jenvtool_echo_red "Stop! The archive was corrupt and has been removed! Please try installing again."
		return 1
	fi
}

# jenv default enviroment
# @return JENV_SERVICE jenv service url
# @return JENV_DIR jenv directory
function __jenvtool_default_environment_variables {
	if [ ! "${JENV_SERVICE}" ]; then
		JENV_SERVICE="http://get.jvmtool.mvnsearch.org"
	fi
}

# check upgrade available
# @param $1 command name
# @return UPGRADE_AVAILABLE upgrade available mark, "true" or empty
function __jenvtool_check_upgrade_available {
    COMMAND="$1"
	UPGRADE_AVAILABLE=""
	UPGRADE_NOTICE=$(echo "${BROADCAST_LIVE}" | grep 'Your version of JENV is out of date!')
	if [[ -n "${UPGRADE_NOTICE}" && ( "${COMMAND}" != 'selfupdate' ) ]]; then
		UPGRADE_AVAILABLE="true"
	fi
}

# link candidate with version to current
# @param $1 candidate name
# @param $2 candidate version
function __jenvtool_link_candidate_version {
	CANDIDATE="$1"
	VERSION="$2"

	# Change the 'current' symlink for the candidate, hence affecting all shells.
	if [ -L "${JENV_DIR}/candidates/${CANDIDATE}/current" ]; then
		unlink "${JENV_DIR}/candidates/${CANDIDATE}/current"
	fi
	ln -s "${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}" "${JENV_DIR}/candidates/${CANDIDATE}/current"
    if ! __jenvtool_contains "$PATH" "candidates/$CANDIDATE/current"; then
         __jenvtool_path_add_candidate "${CANDIDATE}" "current"
    fi
}
