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

# jenv env clone between hosts
# $1 destination
function __jenvtool_clone {
	if __jenvtool_utils_string_contains "$1" "@"; then
	   dest_host="$1"
	   ## clone jenv to another host
	   if [[ -z "$2" ]]; then
	      __jenvtool_sync_jenv_to_dest "$1"
	      __jenvtool_utils_echo_green "jenv has been cloned to ${dest_host}"
	   ### copy candidate from another host
	   elif [[ -n "$3" ]]; then
          candidate="$2"
          version="$3"
          echo "Begin to clone from ${dest_host}..."
          rm -rf "${JENV_DIR}/candidates/${candidate}/${version}"
          mkdir -p "${JENV_DIR}/candidates/${candidate}"
          scp -q -r "${dest_host}:~/.jenv/candidates/${candidate}/${version}" "${JENV_DIR}/candidates/${candidate}/${version}"
          if (( $? != 0 )); then
              __jenvtool_utils_echo_red "${candidate}(${version}) was found on ${dest_host}"
              return 0;
          fi
          echo "Clone successfully!"
          # confirm by prompt
          echo -n "Do you want ${candidate} ${version} to be set as default? (Y/n): "
          read USE
          if [[ -z "${USE}" || "${USE}" == "y" || "${USE}" == "Y" ]]; then
          	  __jenvtool_utils_echo_green "Setting ${candidate} ${version} as default."
          	  __jenvtool_candidate_link_version "${candidate}" "${version}"
          fi
          # done message
          __jenvtool_utils_echo_green "Done! ${candidate}(${version}) has been cloned into local jenv."
       else
         __jenvtool_utils_echo_red "Sorry, I can't understand command."
	   fi
	else
	   if [[ -n "$3" ]]; then ##copy candidate into dest host
	      candidate="$1"
          version="$2"
	      dest_host="$3"
	      if __jenvtool_utils_string_contains "${dest_host}" "@"; then
	         if [[ -d "${JENV_DIR}/candidates/${candidate}/${version}" ]]; then
                 echo "Begin to clone..."
                 ssh "$dest_host" "rm -rf ~/.jenv/candidates/${candidate}/${version}"
                 ssh "$dest_host" "mkdir -p ~/.jenv/candidates/${candidate}"
                 scp -q -r  "${JENV_DIR}/candidates/${candidate}/${version}" "${dest_host}:~/.jenv/candidates/${candidate}/${version}"
                 ## make default on dest host
                 current_version=$(__jenvtool_candidate_current_version "${candidate}")
                 if [[ "${current_version}" == "${version}" ]]; then
                   link_command="ln -s ~/.jenv/candidates/${candidate}/${version}  ~/.jenv/candidates/${candidate}/current"
                   ssh "$dest_host" "rm -rf ~/.jenv/candidates/${candidate}/current"
                   ssh "$dest_host" "${link_command}"
                 fi
                 __jenvtool_utils_echo_green "Done! ${candidate}(${version}) has been cloned into ${dest_host}"
	         else
	             __jenvtool_utils_echo_red "${candidate}(${version}) not found on local jenv"
	         fi
	      fi
	   fi
	fi
}

# clone jenv to another host
# $1 dest host
function __jenvtool_sync_jenv_to_dest {
    dest_host="$1"
    cd
   	tar cf jenv.tar .jenv
   	scp -q jenv.tar "${dest_host}:~/"
   	rm -f jenv.tar
   	ssh "$dest_host" "tar xpf ~/jenv.tar"
   	ssh "$dest_host" "rm -f ~/jenv.tar"
   	# .bash_profile check
   	ssh "$dest_host" "source ~/.jenv/commands/add-hook.sh"
   	cd -
}