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

export JENV_VERSION="@JENV_VERSION@"
export JENV_PLATFORM=$(uname)

# contains function
function __jenvtool_contains {
    replaced=$(echo "$1" | sed -e s,"$2",,g)
    [ "$replaced" != "$1" ]
}

# jenv init function
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
    mkdir -p $JENV_DIR/var/candidates

    if [ -z "${JENV_SERVICE}" ]; then
        if [ -f "${JENV_DIR}/var/service" ]; then
            JENV_SERVICE=$(cat "${JENV_DIR}/var/service")
        else
            JENV_SERVICE=${JENV_SERVICE_DEFAULT}
        fi
    fi
    export JENV_SERVICE
    echo -n ${JENV_SERVICE} > "${JENV_DIR}/var/service"

    # check cached candidates first
    candidate_cache="${JENV_DIR}/var/candidates/$(echo ${JENV_SERVICE} | tr ':/' '_')"
    #if [[ -f "${candidate_cache}" && "${*/--flush/}" == "${*}" ]]; then
    if [[ -f "${candidate_cache}" ]]; then
        JENV_CANDIDATES=($(cat "${candidate_cache}"))
    else
        JENV_CANDIDATES=($(curl -s "${JENV_SERVICE}/candidates" | sed -e 's/,//g'))
        if [[ "${#JENV_CANDIDATES[@]}" == "0" ]]; then
            JENV_CANDIDATES=(${JENV_CANDIDATES_DEFAULT[@]})
        else
            # only cache the candidates if derived from online service
            echo -n ${JENV_CANDIDATES[@]} > "${candidate_cache}"
        fi
    fi
    export JENV_CANDIDATES
    for CANDIDATE in $JENV_CANDIDATES; do
        if ! __jenvtool_contains "$PATH" "$CANDIDATE/current" && [ -e ${JENV_DIR}/${CANDIDATE}/current ]; then
            PATH="${JENV_DIR}/${CANDIDATE}/current/bin:$PATH"
        fi
    done

    OFFLINE_BROADCAST=$( cat << EOF
==== BROADCAST =============================================

AEROPLANE MODE ENABLED! Some functionality is now disabled.

============================================================
EOF
    )

    ONLINE_BROADCAST=$( cat << EOF
==== BROADCAST =============================================

ONLINE MODE RE-ENABLED! All functionality now restored.

============================================================
EOF
    )

    OFFLINE_MESSAGE="This command is not available in aeroplane mode."
    if ! __jenvtool_contains "$PATH" "JENV_DIR"; then
        PATH="${JENV_DIR}/bin:${JENV_DIR}/ext:$PATH"
    fi

    # Source jenv module scripts (except this one).
    for f in $(find "${JENV_DIR}/src" -type f -name 'jenv-*'); do
        if [ "${f##*/}" != "jenv-init.sh" ]; then source "${f}"; fi
    done

    # Source extension files prefixed with 'jenv-' and found in the ext/ folder
    # Use this if extensions are written with the functional approach and want
    # to use functions in the main jenv script.
    for f in $(find "${JENV_DIR}/ext" -type f -name 'jenv-*'); do
        if [ -r "${f}" ]; then
            source "${f}"
        fi
    done
    unset f
}

__jenvtool_init

