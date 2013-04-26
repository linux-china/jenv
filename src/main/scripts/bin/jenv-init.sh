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
# jenv version
export JENV_VERSION="@JENV_VERSION@"
# platform, such as Linux, Unix, Darwin or CYGWIN etc
export JENV_PLATFORM=$(uname)
# matchine platform, such as x86_64, i686, i386
export JENV_MACHINE_PLATFORM=$(uname -m)
# auto confirm without prompt
if [ -z "${JENV_AUTO}" ]; then
   export JENV_AUTO="false"
fi


# echo as red text
# @param $1 text
function __jenvtool_echo_red {
   echo $'\e[31m'"$1"$'\e[00m'
}

# echo as green text
# @param $1 text
function __jenvtool_echo_green {
   echo $'\e[32m'"$1"$'\e[00m'
}
# contains function
# @param $1 text
# @param $2 word
# @return contained test condition
function __jenvtool_contains {
    replaced=$(echo "$1" | sed -e s,"$2",,g)
    [ "$replaced" != "$1" ]
}

# arrays contains item
# @param $1 array such as array[@]
# @param $2 item value
function __jenvtool_array_contains {
   argAry1=("${!1}")
   for i in ${argAry1[@]}; do
     if [ "$i" = "$2" ]; then
       return 0
     fi
   done
   return 1
}

# remove candidate from path
# @param $1 candidate name
# @param $2 candidate version
__jenvtool_path_remove_candidate ()  {
     CANDIDATE="$1"
     VERSION="$2"
     if __jenvtool_contains "$PATH" "${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}"; then
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
   if [ -d "${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}/bin" ]; then
      PATH="${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}/bin:$PATH"
   elif [ -d "${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}/tools" ]; then
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
function __jenvtool_init {

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

    JENV_SERVICE_DEFAULT="@JENV_SERVICE@"
    JENV_CANDIDATES_DEFAULT=("groovy" "grails" "griffon" "gradle" "vertx")

    if [ -z "${JENV_DIR}" ]; then
        JENV_DIR="$HOME/.jenv"
        if [[ "${cygwin}" == 'true' ]]; then
           JENV_DIR="/cygdrive/c/jenv"
           export JENV_PLATFORM="Cygwin"
        fi
        export JENV_DIR
    fi
    mkdir -p $JENV_DIR/candidates

    JENV_SERVICE="${JENV_SERVICE_DEFAULT}"
    export JENV_SERVICE

    # check cached candidates first
    candidate_cache="${JENV_DIR}/config/candidates"
    if [[ -f "${candidate_cache}" ]]; then
        JENV_CANDIDATES=($(cat "${candidate_cache}"))
    else
        JENV_CANDIDATES=(${JENV_CANDIDATES_DEFAULT[@]})
    fi
    # custom candidates
    if [[ -f "${JENV_DIR}/config/candidates_local" ]]; then
        for candidate_name in $(cat "${JENV_DIR}/config/candidates_local"); do
            JENV_CANDIDATES=("${JENV_CANDIDATES[@]}" "${candidate_name}")
        done
    fi
    export JENV_CANDIDATES
    # update PATH env
    for CANDIDATE in "${JENV_CANDIDATES[@]}" ; do
        if ! __jenvtool_contains "$PATH" "candidates/${CANDIDATE}/current" && [ -e "${JENV_DIR}/candidates/${CANDIDATE}/current" ]; then
           UPPER_CANDIDATE=`echo "${CANDIDATE}" | tr '[:lower:]' '[:upper:]'`
           export "${UPPER_CANDIDATE}_HOME"="${JENV_DIR}/candidates/${CANDIDATE}/current"
           __jenvtool_path_add_candidate "${CANDIDATE}" "current"
        fi
    done

    if ! __jenvtool_contains "$PATH" "JENV_DIR"; then
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
__jenvtool_init

# change directory with jenvrc support
cd () {
  builtin cd "$@"
  if [[ -f "${PWD}/jenvrc" ]]; then
     echo "jenv setup"
     for entry in $(cat "${PWD}/jenvrc")
     do
        candidate1=${entry%=*}
        version1=${entry#*=}
        __jenvtool_use "${candidate1}" "${version1}"
     done
  fi
}
