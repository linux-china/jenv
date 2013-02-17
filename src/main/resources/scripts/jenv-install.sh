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

function __jenvtool_install {
	CANDIDATE="$1"
	LOCAL_FOLDER="$3"
	__jenvtool_check_candidate_present "${CANDIDATE}" || return 1
	__jenvtool_determine_version "$2" "$3" || return 1

	if [[ -d "${JENV_DIR}/${CANDIDATE}/${VERSION}" || -h "${JENV_DIR}/${CANDIDATE}/${VERSION}" ]]; then
		echo ""
		echo "Stop! ${CANDIDATE} ${VERSION} is already installed."
		return 1
	fi

	if [[ ${VERSION_VALID} == 'valid' ]]; then
		__jenvtool_install_candidate_version "${CANDIDATE}" "${VERSION}" || return 1

		if [[ "${jenv_auto_answer}" != 'true' ]]; then
			echo -n "Do you want ${CANDIDATE} ${VERSION} to be set as default? (Y/n): "
			read USE
		fi
		if [[ -z "${USE}" || "${USE}" == "y" || "${USE}" == "Y" ]]; then
			echo ""
			echo "Setting ${CANDIDATE} ${VERSION} as default."
			__jenvtool_link_candidate_version "${CANDIDATE}" "${VERSION}"
		fi
		return 1

	elif [[ "${VERSION_VALID}" == 'invalid' && -n "${LOCAL_FOLDER}" ]]; then
		__jenvtool_install_local_version "${CANDIDATE}" "${VERSION}" "${LOCAL_FOLDER}" || return 1

    else
        echo ""
		echo "Stop! $1 is not a valid ${CANDIDATE} version."
		return 1
	fi
}

function __jenvtool_install_local_version {
	CANDIDATE="$1"
	VERSION="$2"
	LOCAL_FOLDER="$3"
	mkdir -p "${JENV_DIR}/${CANDIDATE}"

	echo "Linking ${CANDIDATE} ${VERSION} to ${LOCAL_FOLDER}"
	ln -s "${LOCAL_FOLDER}" "${JENV_DIR}/${CANDIDATE}/${VERSION}"
	echo "Done installing!"
	echo ""
}

function __jenvtool_install_candidate_version {
	CANDIDATE="$1"
	VERSION="$2"
	__jenvtool_download "${CANDIDATE}" "${VERSION}" || return 1
	echo "Installing: ${CANDIDATE} ${VERSION}"

	mkdir -p "${JENV_DIR}/${CANDIDATE}"

	unzip -oq "${JENV_DIR}/archives/${CANDIDATE}-${VERSION}.zip" -d "${JENV_DIR}/tmp/"
	mv ${JENV_DIR}/tmp/*-${VERSION} "${JENV_DIR}/${CANDIDATE}/${VERSION}"
	echo "Done installing!"
	echo ""
}
