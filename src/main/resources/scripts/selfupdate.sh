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

echo ""
echo "Updating jenv..."

JENV_VERSION="@JENV_VERSION@"
if [ -z "${JENV_DIR}" ]; then
	JENV_DIR="$HOME/.jenv"
fi

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

jenv_platform=$(uname -o)
jenv_tmp_zip="${JENV_DIR}/tmp/res-${JENV_VERSION}.zip"
jenv_stage_folder="${JENV_DIR}/tmp/stage"
jenv_src_folder="${JENV_DIR}/src"
jenv_bin_folder="${JENV_DIR}/bin"

echo "Purge existing scripts..."
rm -rf "${jenv_bin_folder}"
rm -rf "${jenv_src_folder}"

echo "Refresh directory structure..."
mkdir -p "${JENV_DIR}/ext"
mkdir -p "${JENV_DIR}/etc"
mkdir -p "${JENV_DIR}/src"
mkdir -p "${JENV_DIR}/var"
mkdir -p "${JENV_DIR}/tmp"

mkdir -p "${JENV_DIR}/groovy"
mkdir -p "${JENV_DIR}/gradle"
mkdir -p "${JENV_DIR}/griffon"
mkdir -p "${JENV_DIR}/grails"

if [[ -d "${JENV_DIR}/vert.x" ]]; then
	mv "${JENV_DIR}/vert.x" "${JENV_DIR}/vertx"
else
	mkdir -p "${JENV_DIR}/vertx"
fi

if [[ -f "${JENV_DIR}/ext/config" ]]; then
	echo "Removing config from ext folder..."
	rm -v "${JENV_DIR}/ext/config"
fi

echo "Prime the config file..."
jenv_config_file="${JENV_DIR}/etc/config"
touch "${jenv_config_file}"
if [[ -z $(cat ${jenv_config_file} | grep 'jenv_auto_answer') ]]; then
	echo "jenv_auto_answer=false" >> "${jenv_config_file}"
fi

echo "Download new scripts to: ${jenv_tmp_zip}"
curl -s "${JENV_SERVICE}/res?platform=${jenv_platform}&purpose=selfupdate" > "${jenv_tmp_zip}"

echo "Extract script archive..."
echo "Unziping scripts to: ${jenv_stage_folder}"
if [[ "${cygwin}" == 'true' ]]; then
	echo "Cygwin detected - normalizing paths for unzip..."
	unzip -qo $(cygpath -w "${jenv_tmp_zip}") -d $(cygpath -w "${jenv_stage_folder}")
else
	unzip -qo "${jenv_tmp_zip}" -d "${jenv_stage_folder}"
fi

echo "Move module scripts to src folder: ${jenv_src_folder}"
mv -v "${jenv_stage_folder}"/jenv-* "${jenv_src_folder}"

echo "Clean up staging folder..."
rm -rf "${jenv_stage_folder}"

echo ""
echo ""
echo "Successfully upgraded JENV."
echo ""
echo "VERY IMPORTANT!!!"
echo ""
echo "JENV will stop working in the current shell when upgrading from 0.0.1 to 0.0.x"
echo ""
echo "Please open a new terminal, or run the following in the existing one:"
echo ""
echo "    source \"${JENV_DIR}/src/jenv-init.sh\""
echo ""
echo ""
