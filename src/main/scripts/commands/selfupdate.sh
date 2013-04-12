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

jenv_platform=$(uname)
jenv_tmp_zip="${JENV_DIR}/tmp/jenv-${JENV_VERSION}.zip"
jenv_bin_folder="${JENV_DIR}/bin"

echo "Purge existing scripts..."

echo "Download new scripts to: ${jenv_tmp_zip}"
curl -s "${JENV_SERVICE}/jenv-${JENV_VERSION}.zip?platform=${jenv_platform}&purpose=selfupdate" > "${jenv_tmp_zip}"

echo "Extract script archive..."
if [[ "${cygwin}" == 'true' ]]; then
	echo "Cygwin detected - normalizing paths for unzip..."
	unzip -qo $(cygpath -w "${jenv_tmp_zip}") -d "${JENV_DIR}"
else
	unzip -qo "${jenv_tmp_zip}" -d "${JENV_DIR}"
fi

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
echo "    source \"${JENV_DIR}/bin/jenv-init.sh\""
echo ""
echo ""
