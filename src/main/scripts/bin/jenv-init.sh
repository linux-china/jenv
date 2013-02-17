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

# contains function
# @param $1 text
# @param $2 word
# @return contained test condition
function __jenvtool_contains {
    replaced=$(echo "$1" | sed -e s,"$2",,g)
    [ "$replaced" != "$1" ]
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
        export JENV_DIR="$HOME/.jenv"
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
    export JENV_CANDIDATES
    # update PATH env
    for CANDIDATE in "${JENV_CANDIDATES[@]}" ; do
        if ! __jenvtool_contains "$PATH" "candidates/${CANDIDATE}/current" && [ -e "${JENV_DIR}/${CANDIDATE}/current" ]; then
            PATH="${JENV_DIR}/${CANDIDATE}/current/bin:$PATH"
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

__jenvtool_init

