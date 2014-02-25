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


#
# common internal function definitions
#

################## jenv system ####################

# jenv default enviroment
# @return JENV_SERVICE jenv service url
# @return JENV_DIR jenv directory
function __jenvtool_app_default_environment_variables {
	if [ ! "${JENV_SERVICE}" ]; then
		JENV_SERVICE="http://get.jenv.mvnsearch.org/"
	fi
}

########## repo #############

# fetch repo list, sequence as central, third, local
function __jenvtool_repo_all {
  repo_list=()
  if [ -d "${JENV_DIR}/repo/central" ] ; then
      repo_list=("${repo_list[@]}" "central")
  fi
  for repo in $(ls -1 "${JENV_DIR}/repo" 2> /dev/null); do
     if [[ "${repo}" != "central" && "${repo}" != "local" ]] ; then
          repo_list=("${repo_list[@]}" "${repo}")
     fi
  done
  if [ -d "${JENV_DIR}/repo/local" ] ; then
    repo_list=("${repo_list[@]}" "local")
  fi
  echo -n "${repo_list[@]}"
}

# locate repo for candidate and version
# @param $1 candidate name
# @param $2 candidate version
function __jenvtool_repo_locate {
    CANDIDATE="$1"
    VERSION="$2"

    for repo in $( __jenvtool_repo_all ); do
       if [ -f "${JENV_DIR}/repo/${repo}/candidates" ]; then
            CANDIDATES=($(cat "${JENV_DIR}/repo/${repo}/candidates"))
            if __jenvtool_utils_array_contains "CANDIDATES[@]" "${CANDIDATE}"; then
               if [ -f "${JENV_DIR}/repo/${repo}/version/${CANDIDATE}.txt" ] ; then
                 VERSIONS=($(cat "${JENV_DIR}/repo/${repo}/version/${CANDIDATE}.txt"))
                 if __jenvtool_utils_array_contains "VERSIONS[@]" "${VERSION}"; then
                    echo -n "${repo}"
                    return 0
                 fi
               fi
            fi
       fi
    done
    echo -n ""
}

########## candidate ################

# reload candidates and export into env
function __jenvtool_candidate_reload_all {
	JENV_CANDIDATES=()
	# repository candidates
	for repo in $(ls -1 "${JENV_DIR}/repo" 2> /dev/null); do
	   if [ -f "${JENV_DIR}/repo/${repo}/candidates" ]; then
	     for candidate_name in $(cat "${JENV_DIR}/repo/${repo}/candidates"); do
	        if ! __jenvtool_utils_array_contains "JENV_CANDIDATES[@]" "${candidate_name}"; then
	           JENV_CANDIDATES=("${JENV_CANDIDATES[@]}" "${candidate_name}")
	        fi
	     done
	   fi
	done
	export JENV_CANDIDATES
}

# check candidate present.
# @param $1 candidate name
function __jenvtool_candidate_is_present {
	if [ -z "$1" ]; then
		__jenvtool_utils_echo_red "No candidate provided."
		__jenvtool_help
		return 1
	fi
}

# fetch candidate versions
# @param $1 candidate name
function __jenvtool_candidate_versions {
    CANDIDATE="$1"
    CANDIDATE_VERSIONS=()
    for repo in $( __jenvtool_repo_all ); do
       if [ -f "${JENV_DIR}/repo/${repo}/version/${CANDIDATE}.txt" ]; then
          for candidate_version in $(cat "${JENV_DIR}/repo/${repo}/version/${CANDIDATE}.txt"); do
             if ! __jenvtool_utils_array_contains "CANDIDATE_VERSIONS[@]" "${candidate_version}"; then
                CANDIDATE_VERSIONS=("${CANDIDATE_VERSIONS[@]}" "${candidate_version}")
             fi
          done
       fi
    done
    # add local unversioned in repository
    for version in $(ls -1 "${JENV_DIR}/candidates/${CANDIDATE}" 2> /dev/null); do
    	if [ "${version}" != 'current' ]; then
             if ! __jenvtool_utils_array_contains "CANDIDATE_VERSIONS[@]" "${version}"; then
                 CANDIDATE_VERSIONS=("${CANDIDATE_VERSIONS[@]}" "${version}")
             fi
        fi
    done
    echo -n "${CANDIDATE_VERSIONS[@]}"
}

# fetch candidate installed versions
# @param $1 candidate name
function __jenvtool_candidate_installed_versions {
    CANDIDATE="$1"
    CANDIDATE_VERSIONS=()
    for version in $(ls -1 "${JENV_DIR}/candidates/${CANDIDATE}") ; do
       if [[ "${version}" != "current" && "${VERSION}" != "*" ]] ; then
         CANDIDATE_VERSIONS=("${CANDIDATE_VERSIONS[@]}" "${version}")
       fi
    done
    echo -n "${CANDIDATE_VERSIONS[@]}"
}

# fetch candidate current version
# @param $1 candidate name
function __jenvtool_candidate_current_version {
   CANDIDATE="$1"
   CURRENT=$(echo $PATH | jenv_regex_sed "s|jenv/candidates/${CANDIDATE}/([^/]+)|!!\1!!|1" | jenv_regex_sed "s|^.*!!(.+)!!.*$|\1|g")
   if [[ "${CURRENT}" == "current" || "${CURRENT}" == "current:" ]]; then
   	   CURRENT=$(readlink "${JENV_DIR}/candidates/${CANDIDATE}/current" | jenv_regex_sed "s!${JENV_DIR}/candidates/${CANDIDATE}/!!g")
   	   echo -n "${CURRENT}"
   elif [[ ! -z "${CURRENT}"  ]] ; then
       echo -n "${CURRENT}"
   else
       echo -n ""
   fi
}

# determine candidate current version
# @param $1 candidate name
# @return CURRENT candidate current version number
function __jenvtool_candidate_determine_current_version {
	CANDIDATE="$1"
	CURRENT=$(echo $PATH | jenv_regex_sed "s|.jenv/candidates/${CANDIDATE}/([^/]+)/bin|!!\1!!|1" | jenv_regex_sed "s|^.*!!(.+)!!.*$|\1|g")
	if [[ "${CURRENT}" == "current" || "${CURRENT}" == "$PATH" ]]; then
	    unset CURRENT
	fi

	if [[ -z ${CURRENT} ]]; then
		CURRENT=$(readlink "${JENV_DIR}/candidates/${CANDIDATE}/current" | jenv_regex_sed "s!${JENV_DIR}/candidates/${CANDIDATE}/!!g")
	fi
}

# download candidate with version
# @param $1 candidate name
# @param $2 candidate version
# @param $3 download url
function __jenvtool_candidate_download {
	CANDIDATE="$1"
	VERSION="$2"
	DOWNLOAD_URL="$3"
	mkdir -p "${JENV_DIR}/archives"
	if [ ! -f "${JENV_DIR}/archives/${CANDIDATE}-${VERSION}.zip" ]; then
		echo ""
		echo "Downloading: ${CANDIDATE} ${VERSION}"
		echo ""
		ZIP_ARCHIVE="${JENV_DIR}/archives/${CANDIDATE}-${VERSION}.zip"
		echo "Downloading ${DOWNLOAD_URL}"
		curl -L "${DOWNLOAD_URL}" > "${ZIP_ARCHIVE}"
		__jenvtool_utils_zip_validate "${ZIP_ARCHIVE}" || return 1
	else
		echo ""
		echo "Found a previously downloaded ${CANDIDATE} ${VERSION} archive. Not downloading it again..."
		__jenvtool_utils_zip_validate "${JENV_DIR}/archives/${CANDIDATE}-${VERSION}.zip" || return 1
	fi
	echo ""
}


# link candidate with version to current
# @param $1 candidate name
# @param $2 candidate version
function __jenvtool_candidate_link_version {
	CANDIDATE="$1"
	VERSION="$2"

	# Change the 'current' symlink for the candidate, hence affecting all shells.
	if [ -L "${JENV_DIR}/candidates/${CANDIDATE}/current" ]; then
		unlink "${JENV_DIR}/candidates/${CANDIDATE}/current"
	fi
	ln -s "${JENV_DIR}/candidates/${CANDIDATE}/${VERSION}" "${JENV_DIR}/candidates/${CANDIDATE}/current"
    if ! __jenvtool_utils_string_contains "$PATH" "candidates/$CANDIDATE/current"; then
         __jenvtool_path_add_candidate "${CANDIDATE}" "current"
    fi
}


############## version  ###############

# check candidate version present.
# @param $1 candidate version
function __jenvtool_version_is_present {
	if [ -z "$1" ]; then
		__jenvtool_utils_echo_red "No candidate version provided."
		__jenvtool_help
		return 1
	fi
}

# determine candidate version.
# @param $1 candidate name
# @param $2 candidate version
# @return VERSION candidate version
function __jenvtool_version_determine {
    #check local installed version
    if [[ -d "${JENV_DIR}/candidates/${CANDIDATE}/$1" ]]; then
       VERSION="$1"
       return 0
    fi
    # candidate versions
    for candidate_version in $(__jenvtool_candidate_versions "${CANDIDATE}") ; do
       if [[ "${candidate_version}" == "$1" ]]; then
           VERSION="$1"
           return 0
       fi
    done
    echo ""
    __jenvtool_utils_echo_red "Stop! $1 is not a valid ${CANDIDATE} version."
    return 1
}

# get conf value
# @param $1 candidate name
function __jenvtool_get_conf_value {
   conf_name="$1"
   if [[ -n "${conf_name}" ]]; then
      if [ -e "${JENV_DIR}/conf/settings" ] ; then
          for entry in $(cat "${JENV_DIR}/conf/settings") ; do
             name=${entry%=*}
             value=${entry#*=}
             if [[ "${name}" == "${conf_name}" ]]; then
               echo -n "${value}"
             fi
          done
      fi
   else
     echo -n ""
   fi
}

