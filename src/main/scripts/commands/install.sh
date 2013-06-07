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

# echo as green text
# @param $1 text
function __jenvtool_utils_echo_green {
   echo $'\e[32m'"$1"$'\e[00m'
}

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

# Global variables
JENV_SERVICE="@JENV_SERVICE@"
JENV_VERSION="@JENV_VERSION@"
JENV_DIR="$HOME/.jenv"
if [[ "${cygwin}" == 'true' ]]; then
   JENV_DIR="/cygdrive/c/jenv"
fi

# Local variables
jenv_tmp_folder="${JENV_DIR}/tmp"
jenv_zip_file="${jenv_tmp_folder}/jenv-${JENV_VERSION}.zip"
jenv_central_repo_file="${jenv_tmp_folder}/repo-central.zip"
jenv_ext_folder="${JENV_DIR}/ext"
jenv_bash_profile="${HOME}/.bash_profile"
jenv_profile="${HOME}/.profile"
jenv_bashrc="${HOME}/.bashrc"
jenv_os_name=$(uname)
jenv_machine_platform=$(uname -m)

jenv_init_snippet=$( cat << EOF
#THIS MUST BE AT THE END OF THE FILE FOR JENV TO WORK!!!
[[ -s "${JENV_DIR}/bin/jenv-init.sh" ]] && source "${JENV_DIR}/bin/jenv-init.sh" && source "${JENV_DIR}/commands/completion.sh"
EOF
)

echo '                                                                     '
echo 'Thanks for using                                                     '
echo '                                                                     '
echo '        ___   _______  _____  ___  ___      ___                      '
echo '       |"  | /"     "|(\"   \|"  \|"  \    /"  |                     '
echo '       ||  |(: ______)|.\\   \    |\   \  //  /                      '
echo '       |:  | \/    |  |: \.   \\  | \\  \/. ./                       '
echo '    ___|  /  // ___)_ |.  \    \. |  \.    //                        '
echo '   /  :|_/ )(:      "||    \    \ |   \\   /                         '
echo '  (_______/  \_______) \___|\____\)    \__/                          '
echo '                                                                     '
echo '                                       Will now attempt installing...'
echo '                                                                     '


# Sanity checks

echo "Looking for a previous installation of JENV..."
if [ -d "${JENV_DIR}" ]; then
	echo "JENV found."
	echo ""
	echo "======================================================================================================"
	echo " You already have JENV installed."
	echo " JENV was found at:"
	echo ""
	echo "    ${JENV_DIR}"
	echo ""
	echo " Please consider running the following if you need to upgrade."
	echo ""
	echo "    $ jenv selfupdate"
	echo ""
	echo "======================================================================================================"
	echo ""
	exit 0
fi

echo "Looking for unzip..."
if [ -z $(which unzip) ]; then
	echo "Not found."
	echo "======================================================================================================"
	echo " Please install unzip on your system using your favourite package manager."
	echo ""
	echo " Restart after installing unzip."
	echo "======================================================================================================"
	echo ""
	exit 0
fi

echo "Looking for curl..."
if [ -z $(which curl) ]; then
	echo "Not found."
	echo ""
	echo "======================================================================================================"
	echo " Please install curl on your system using your favourite package manager."
	echo ""
	echo " JENV uses curl for crucial interactions with it's backend server."
	echo ""
	echo " Restart after installing curl."
	echo "======================================================================================================"
	echo ""
	exit 0
fi

echo "Installing jenv scripts..."

mkdir -p "${jenv_tmp_folder}"
echo "Download script archive..."
curl -L -s "${JENV_SERVICE}/jenv-last.zip?osName=${jenv_os_name}&platform=${jenv_machine_platform}&purpose=install" > "${jenv_zip_file}"

echo "Extract script archive..."
if [[ "${cygwin}" == 'true' ]]; then
	echo "Cygwin detected - normalizing paths for unzip..."
	unzip -qo $(cygpath -w "${jenv_zip_file}") -d "${JENV_DIR}"
else
	unzip -qo "${jenv_zip_file}" -d "${JENV_DIR}"
fi

#download central repository
echo "Download Central repository..."
mkdir -p "${JENV_DIR}/repo"
curl -L -s "${JENV_SERVICE}/central-repo.zip?osName=${jenv_os_name}&platform=${jenv_machine_platform}" > "${jenv_central_repo_file}"
if [[ "${cygwin}" == 'true' ]]; then
	echo "Cygwin detected - normalizing paths for unzip..."
	unzip -qo $(cygpath -w "${jenv_central_repo_file}") -d "${JENV_DIR}/repo/central"
else
	unzip -qo "${jenv_central_repo_file}" -d "${JENV_DIR}/repo/central"
fi
rm -rf "${jenv_central_repo_file}"

echo "Attempt update of bash profiles..."
if [ ! -f "${jenv_bash_profile}" -a ! -f "${jenv_profile}" ]; then
	echo "#!/bin/bash" > "${jenv_bash_profile}"
	echo "${jenv_init_snippet}" >> "${jenv_bash_profile}"
	echo "Created and initialised ${jenv_bash_profile}"
else
	if [ -f "${jenv_bash_profile}" ]; then
		if [[ -z `grep 'jenv-init.sh' "${jenv_bash_profile}"` ]]; then
			echo -e "\n${jenv_init_snippet}" >> "${jenv_bash_profile}"
			echo "Updated existing ${jenv_bash_profile}"
		fi
	fi

	if [ -f "${jenv_profile}" ]; then
		if [[ -z `grep 'jenv-init.sh' "${jenv_profile}"` ]]; then
			echo -e "\n${jenv_init_snippet}" >> "${jenv_profile}"
			echo "Updated existing ${jenv_profile}"
		fi
	fi
fi

if [ ! -f "${jenv_bashrc}" ]; then
	echo "#!/bin/bash" > "${jenv_bashrc}"
	echo "${jenv_init_snippet}" >> "${jenv_bashrc}"
	echo "Created and initialised ${jenv_bashrc}"
else
	if [[ -z `grep 'jenv-init.sh' "${jenv_bashrc}"` ]]; then
		echo -e "\n${jenv_init_snippet}" >> "${jenv_bashrc}"
		echo "Updated existing ${jenv_bashrc}"
	fi
fi

echo -e "\n\n\nAll done!\n\n"

__jenvtool_utils_echo_green "Please open a new terminal, or run the following in the existing one:"
echo ""
__jenvtool_utils_echo_green "    source ${JENV_DIR}/bin/jenv-init.sh "
echo ""
__jenvtool_utils_echo_green "Then issue the following command:"
echo ""
__jenvtool_utils_echo_green "    jenv help"
echo ""
__jenvtool_utils_echo_green "Enjoy!!!"
