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
          rm -rf "~/.jenv/canidates/${candidate}/${version}"
          scp -r "${dest_host}:~/.jenv/canidates/${candidate}/${version}" "~/.jenv/canidates/${candidate}/${version}"
          # confirm by prompt
          echo -n "Do you want ${CANDIDATE} ${VERSION} to be set as default? (Y/n): "
          read USE
          if [[ -z "${USE}" || "${USE}" == "y" || "${USE}" == "Y" ]]; then
          	  __jenvtool_utils_echo_green "Setting ${CANDIDATE} ${VERSION} as default."
          	  __jenvtool_candidate_link_version "${CANDIDATE}" "${VERSION}"
          fi
          # done message
          __jenvtool_utils_echo_green "${CANDIDATE}(${VERSION}) has been synced into localhost!"
       else
         __jenvtool_utils_echo_red "Sorry, I can't understand."
	   fi
	else
	   if [[ -z "$4" ]]; then ##copy candidate into dest host
	      dest_host="$4"
	      if __jenvtool_utils_string_contains "${dest_host}" "@"; then
	         scp -r  "~/.jenv/canidates/${candidate}/${version}" "${dest_host}:~/.jenv/canidates/${candidate}/${version}"
	         ## make default on dest host
	         __jenvtool_utils_echo_green "${CANDIDATE}(${VERSION}) has been synced into ${dest_host}"
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
   	scp jenv.tar "${dest_host}:~/"
   	rm -f jenv.tar
   	ssh "$dest_host" "tar xpf ~/jenv.tar"
   	ssh "$dest_host" "rm -f ~/jenv.tar"
   	# .bash_profile check
   	ssh "$dest_host" "source ~/.jenv/commands/add-hook.sh"
   	cd -
}