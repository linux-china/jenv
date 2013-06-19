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

# OS specific support (must be 'true' or 'false').
cygwin=false;
darwin=false;
case "`uname`" in
    CYGWIN*)
        cygwin=true
        ;;

    Darwin*)
        darwin=true
        ;;
esac

echo ""
echo "Updating jenv..."

JENV_VERSION="@JENV_VERSION@"
if [ -z "${JENV_DIR}" ]; then
	JENV_DIR="$HOME/.jenv"
	if [[ "${cygwin}" == 'true' ]]; then
	   JENV_DIR="/cygdrive/c/jenv"
	fi
fi

jenv_tmp_zip="${JENV_DIR}/tmp/jenv-${JENV_VERSION}.zip"
jenv_bin_folder="${JENV_DIR}/bin"

echo "Purge existing scripts..."

echo "Download new scripts to: ${jenv_tmp_zip}"
curl -L -s "${JENV_SERVICE}/jenv-last.zip?osName=${JENV_OS_NAME}&platform=${JENV_MACHINE_PLATFORM}&purpose=selfupdate" > "${jenv_tmp_zip}"

echo "Extract script archive..."
if [[ "${cygwin}" == 'true' ]]; then
	echo "Cygwin detected - normalizing paths for unzip..."
	unzip -qo $(cygpath -w "${jenv_tmp_zip}") -d "${JENV_DIR}"
else
	unzip -qo "${jenv_tmp_zip}" -d "${JENV_DIR}"
fi

#download central repository
if [ ! -d "${JENV_DIR}/repo/central" ] ; then
    echo "Download Central repository..."
    jenv_central_repo_file="${JENV_DIR}/tmp/repo-central.zip"
    mkdir -p "${JENV_DIR}/repo"
    curl -L -s "${JENV_SERVICE}/central-repo.zip?osName=${JENV_OS_NAME}&platform=${JENV_MACHINE_PLATFORM}" > "${jenv_central_repo_file}"
    if [[ "${cygwin}" == 'true' ]]; then
        echo "Cygwin detected - normalizing paths for unzip..."
        unzip -qo $(cygpath -w "${jenv_central_repo_file}") -d "${JENV_DIR}/repo/central"
    else
        unzip -qo "${jenv_central_repo_file}" -d "${JENV_DIR}/repo/central"
    fi
    rm -rf "${jenv_central_repo_file}"
fi
# remove old files
if [ -d "${JENV_DIR}/repo/central" ] ; then
   rm -rf "${JENV_DIR}/config"
   rm -rf "${JENV_DIR}/db"
fi

echo ""
__jenvtool_utils_echo_green "jenv upgraded successfully!"
