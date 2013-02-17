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
		echo -e "\nNo candidate provided."
		__jenvtool_help
		return 1
	fi
}

# check candidate version present.
# @param $1 candidate version
function __jenvtool_check_version_present {
	if [ -z "$1" ]; then
		echo -e "\nNo candidate version provided."
		__jenvtool_help
		return 1
	fi
}

# determine candidate version.
# @param $1 candidate version
# @return VERSION candidate version
# @return VERSION_VALID version valid text, valid or invalid
function __jenvtool_determine_version {
	if [[ "${JENV_ONLINE}" == "false" && -n "$1" && -d "${JENV_DIR}/${CANDIDATE}/$1" ]]; then
		VERSION="$1"

	elif [[ "${JENV_ONLINE}" == "false" && -z "$1" && -L "${JENV_DIR}/${CANDIDATE}/current" ]]; then
		VERSION=$(readlink "${JENV_DIR}/${CANDIDATE}/current" | sed -e "s!${JENV_DIR}/${CANDIDATE}/!!g")

	elif [[ "${JENV_ONLINE}" == "false" && -n "$1" ]]; then
		echo "Stop! ${CANDIDATE} ${1} is not available in aeroplane mode."
		return 1

	elif [[ "${JENV_ONLINE}" == "false" && -z "$1" ]]; then
        echo "${OFFLINE_MESSAGE}"
        return 1

	elif [[ "${JENV_ONLINE}" == "true" && -z "$1" ]]; then
		VERSION_VALID='valid'
		VERSION=$(curl -s "${JENV_SERVICE}/candidates/${CANDIDATE}/default")

	else
		VERSION_VALID=$(curl -s "${JENV_SERVICE}/candidates/${CANDIDATE}/$1")
		if [[ "${VERSION_VALID}" == 'valid' || ( "${VERSION_VALID}" == 'invalid' && -n "$2" ) ]]; then
			VERSION="$1"

		elif [[ "${VERSION_VALID}" == 'invalid' && -h "${JENV_DIR}/${CANDIDATE}/$1" ]]; then
			VERSION="$1"

		else
			echo ""
			echo "Stop! $1 is not a valid ${CANDIDATE} version."
			return 1
		fi
	fi
}

# build candidate all version to csv
# @param $1 candidate name
# @return CSV candidate version csv
function __jenvtool_build_version_csv {
	CANDIDATE="$1"
	CSV=""
	for version in $(ls -1 "${JENV_DIR}/${CANDIDATE}" 2> /dev/null); do
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
	CURRENT=$(echo $PATH | sed -E "s|.jenv/${CANDIDATE}/([^/]+)/bin|!!\1!!|1" | sed -E "s|^.*!!(.+)!!.*$|\1|g")
	if [[ "${CURRENT}" == "current" ]]; then
	    unset CURRENT
	fi

	if [[ -z ${CURRENT} ]]; then
		CURRENT=$(readlink "${JENV_DIR}/${CANDIDATE}/current" | sed -e "s!${JENV_DIR}/${CANDIDATE}/!!g")
	fi
}

# download candidate with version
# @param $1 candidate name
# @param $2 candidate version
function __jenvtool_download {
	CANDIDATE="$1"
	VERSION="$2"
	mkdir -p "${JENV_DIR}/archives"
	if [ ! -f "${JENV_DIR}/archives/${CANDIDATE}-${VERSION}.zip" ]; then
		echo ""
		echo "Downloading: ${CANDIDATE} ${VERSION}"
		echo ""
		DOWNLOAD_URL="${JENV_SERVICE}/download/${CANDIDATE}/${VERSION}?platform=${JENV_PLATFORM}"
		ZIP_ARCHIVE="${JENV_DIR}/archives/${CANDIDATE}-${VERSION}.zip"
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
		echo "Stop! The archive was corrupt and has been removed! Please try installing again."
		return 1
	fi
}

# jenv default enviroment
# @return JENV_SERVICE jenv service url
# @return JENV_DIR jenv directory
function __jenvtool_default_environment_variables {
	if [ ! "${JENV_SERVICE}" ]; then
		JENV_SERVICE="http://localhost:8080"
	fi

	if [ ! "${JENV_DIR}" ]; then
		JENV_DIR="$HOME/.jenv"
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
	if [ -L "${JENV_DIR}/${CANDIDATE}/current" ]; then
		unlink "${JENV_DIR}/${CANDIDATE}/current"
	fi
	ln -s "${JENV_DIR}/${CANDIDATE}/${VERSION}" "${JENV_DIR}/${CANDIDATE}/current"
    if ! __jenvtool_contains "$PATH" "$CANDIDATE/current"; then
        PATH="${JENV_DIR}/${CANDIDATE}/current/bin:$PATH"
    fi
}

# offline candidate version list
function __jenvtool_offline_list {
	echo "------------------------------------------------------------"
	echo "Aeroplane Mode:  only showing installed ${CANDIDATE} versions"
	echo "------------------------------------------------------------"
	echo "                                                            "

	jenv_versions=($(echo ${CSV//,}))
	for (( i=0 ; i <= ${#jenv_versions} ; i++ )); do
		if [[ -n "${jenv_versions[${i}]}" ]]; then
			if [[ "${jenv_versions[${i}]}" == "${CURRENT}" ]]; then
				echo -e " > ${jenv_versions[${i}]}"
			else
				echo -e " * ${jenv_versions[${i}]}"
			fi
		fi
	done

	if [[ -z "${jenv_versions[@]}" ]]; then
		echo "   None installed!"
	fi

	echo "------------------------------------------------------------"
	echo "* - installed                                               "
	echo "> - currently in use                                        "
	echo "------------------------------------------------------------"

	unset CSV jenv_versions
}
