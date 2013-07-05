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

# display or set config
# @param $1 name
# @param $2 value
function __jenvtool_config {
    conf_name="$1"
    conf_value="$2"
    if [[ -n "${conf_name}" ]]; then
       if [ -e "${JENV_DIR}/conf/settings" ] ; then
          echo -n "" > "${JENV_DIR}/conf/settings_new"
          tmp_exits="false"
          for entry in $(cat "${JENV_DIR}/conf/settings") ; do
            name=${entry%=*}
            value=${entry#*=}
            if [[ "${name}" == "${conf_name}" ]]; then
               value="${conf_value}"
               tmp_exits="true"
            fi
            if [[ -n "${value}" ]] ; then
               echo "${name}=${value}" >> "${JENV_DIR}/conf/settings_new"
            fi
          done
          if [[ "${tmp_exits}" == "false" ]]; then
            echo "${conf_name}=${conf_value}" >> "${JENV_DIR}/conf/settings_new"
          fi
          mv -f "${JENV_DIR}/conf/settings_new" "${JENV_DIR}/conf/settings"
       else
         mkdir -p "${JENV_DIR}/conf"
         echo "${conf_name}=${conf_value}" > "${JENV_DIR}/conf/settings"
       fi
       __jenvtool_utils_echo_green "Config updated successfully!"
    else
       if [ -e "${JENV_DIR}/conf/settings" ] ; then
         cat "${JENV_DIR}/conf/settings"
       else
         echo "auto=false"
       fi
    fi
}
