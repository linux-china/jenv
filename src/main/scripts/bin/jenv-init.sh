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

# jenv version
export JENV_VERSION="@JENV_VERSION@"
# platform, such as Linux, Unix, Darwin or CYGWIN etc
export JENV_OS_NAME=$(uname)
# matchine platform, such as x86_64, i686, i386
export JENV_MACHINE_PLATFORM=$(uname -m)
# jenv commands
export JENV_COMMANDS="all ls candidates list update install reinstall uninstall clean pause execute exec use init config which cd version default add repo selfupdate help requirements load broadcast"
# auto confirm without prompt
if [ -z "${JENV_AUTO}" ]; then
   export JENV_AUTO="false"
fi

JENV_SHELL="bash"
if [ -n "${ZSH_NAME}" ]; then
   JENV_SHELL="zsh"
else
   shopt -s expand_aliases
fi
alias jenv_regex_sed="sed -r"
alias jenv_ls="\ls -1 --color=never"

export JENV_SHELL

export JENV_PATH_ORIGINAL="${PATH}"

# remove candidate from path
alias jenv_regex_sed="sed -r"

# remove candidate from path
# @param $1 candidate name
# @param $2 candidate version
__jenvtool_path_remove_candidate ()  {
     CANDIDATE="$1"
     VERSION="$2"
     if __jenvtool_utils_string_contains "$PATH" "${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}"; then
        if [ -e "${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}/bin" ]; then
           candidatePath="${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}/bin"
        elif [ -d "${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}/tools" ]; then
           candidatePath="${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}/tools"
        else
           candidatePath="${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}"
        fi
        newPATH="${PATH}:"
        newPATH="${newPATH//${candidatePath}:/}"
        export PATH="${newPATH%:}"
        unset newPATH
        unset candidatePath
     fi
     return 0;
}

# add candidate into path
# @param $1 candidate name
# @param $2 candidate version
__jenvtool_path_add_candidate() {
   CANDIDATE="$1"
   VERSION="$2"
   if [[ -d "${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}/bin" ]]; then
      PATH="${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}/bin:$PATH"
   elif [[ -d "${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}/tools" ]]; then
      PATH="${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}/tools:$PATH"
   else
      PATH="${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}:$PATH"
   fi
   export PATH
}

# jenv init function
# @return JENV_DIR jenv dir
# @return JENV_SERVICE jenv service url
# @return JENV_CANDIDATES jenv candidate array
__jenvtool_initialize() {

    # OS specific support (must be 'true' or 'false').
    cygwin=false;
    darwin=false;
    case "`uname`" in
        CYGWIN*)
            cygwin=true
            ;;
        Darwin*)
            darwin=true
            alias jenv_regex_sed="sed -E"
            alias jenv_ls="\ls -1"
            ;;
    esac

    JENV_SERVICE_DEFAULT="@JENV_SERVICE@"
    JENV_CANDIDATES_DEFAULT=("groovy" "grails" "griffon" "gradle" "vertx")

    if [[ -z "${JENV_DIR}" ]]; then
        JENV_DIR="$HOME/.jenv"
        if [[ "${cygwin}" == 'true' ]]; then
           JENV_DIR="/cygdrive/c/jenv"
           export JENV_OS_NAME="Cygwin"
        fi
        export JENV_DIR
    fi
    mkdir -p $JENV_DIR/candidates

    JENV_SERVICE="${JENV_SERVICE_DEFAULT}"
    export JENV_SERVICE

    # load utils functions
    source "${JENV_DIR}/commands/jenv-utils.sh"

    #download central repository
    if [[ ! -d "${JENV_DIR}/repo/central" ]] ; then
        jenv_central_repo_file="${JENV_DIR}/tmp/repo-central.zip"
        mkdir -p "${JENV_DIR}/repo"
        curl -s "${JENV_SERVICE}/central-repo.zip?osName=${JENV_OS_NAME}&platform=${JENV_MACHINE_PLATFORM}" > "${jenv_central_repo_file}"
        if [[ "${cygwin}" == 'true' ]]; then
            unzip -qo $(cygpath -w "${jenv_central_repo_file}") -d "${JENV_DIR}/repo/central"
        else
            unzip -qo "${jenv_central_repo_file}" -d "${JENV_DIR}/repo/central"
        fi
        rm -rf "${jenv_central_repo_file}"
    fi
    # check cached candidates first
    JENV_CANDIDATES=(${JENV_CANDIDATES_DEFAULT[@]})
    # repository candidates
    for repo in $(jenv_ls -1 "${JENV_DIR}/repo" 2> /dev/null); do
       if [[ -f "${JENV_DIR}/repo/${repo}/candidates" ]]; then
         for candidate_name in $(cat "${JENV_DIR}/repo/${repo}/candidates"); do
           if ! __jenvtool_utils_array_contains "JENV_CANDIDATES[@]" "${candidate_name}"; then
              JENV_CANDIDATES=("${JENV_CANDIDATES[@]}" "${candidate_name}")
           fi
         done
       fi
    done
    export JENV_CANDIDATES
    # update PATH env
    export PATH="${JENV_PATH_ORIGINAL}"
    for CANDIDATE in "${JENV_CANDIDATES[@]}" ; do
        if ! __jenvtool_utils_string_contains "$PATH" "candidates/${CANDIDATE}/current" && [ -e "${JENV_DIR}/candidates/${CANDIDATE}/current" ]; then
           UPPER_CANDIDATE=`echo "${CANDIDATE}" | tr '[:lower:]' '[:upper:]'`
           export "${UPPER_CANDIDATE}_HOME"="${JENV_DIR}/candidates/${CANDIDATE}/current"
           if [[ "${UPPER_CANDIDATE}" == 'MAVEN' ]]; then
              export "M2_HOME"="${JENV_DIR}/candidates/${CANDIDATE}/current"
           fi
           __jenvtool_path_add_candidate "${CANDIDATE}" "current"
        fi
    done
    # autorun support
    for CANDIDATE in "${JENV_CANDIDATES[@]}" ; do
        __jenvtool_autorun "${JENV_DIR}/candidates/${CANDIDATE}/current"
    done

    if ! __jenvtool_utils_string_contains "$PATH" "JENV_DIR"; then
        PATH="${JENV_DIR}/bin:$PATH"
    fi

    # Source jenv module scripts
    for f in $(find "${JENV_DIR}/commands" -type f -name 'jenv-*'); do
         source "${f}"
    done

    # Source extension files prefixed with 'jenv-' and found in the ext/ folder
    # Use this if extensions are written with the functional approach and want
    # to use functions in the main jenv script.
     if [[ -d "${JENV_DIR}/ext" ]]; then
        for f in $(find "${JENV_DIR}/ext" -type f -name 'jenv-*'); do
            if [ -r "${f}" ]; then
                source "${f}"
            fi
        done
        unset f
    fi
}

#jenv tool init
__jenvtool_initialize

# change directory with jenvrc support
jcd () {
  builtin cd "$@"
  if [[ -f "${PWD}/jenvrc" ]]; then
     while read entry
     do
       if ! __jenvtool_utils_string_contains "$entry", "#" ; then
            candidate1=`echo ${entry} | sed 's/=.*//g'`
            version1=`echo ${entry} | sed 's/.*=//g'`
            if [ -d "${JENV_DIR}/candidates/${candidate1}/${version1}" ]; then
                __jenvtool_use "${candidate1}" "${version1}"
            else
                __jenvtool_install "${candidate1}" "${version1}"
            fi
            unset candidate1
            unset version1
       fi
     done < "${PWD}/jenvrc"
  fi
}
