#!/bin/sh

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

jenv_bash_profile="${HOME}/.bash_profile"
jenv_profile="${HOME}/.profile"
jenv_bashrc="${HOME}/.bashrc"
jenv_zshrc="${HOME}/.zshrc"

JENV_DIR="$HOME/.jenv"
JENV_SHELL="bash"
if [ ! -z "${ZSH_NAME}" ]; then
   JENV_SHELL="zsh"
fi

jenv_init_snippet=$( cat << EOF
#THIS MUST BE AT THE END OF THE FILE FOR JENV TO WORK!!!
[[ -s "${JENV_DIR}/bin/jenv-init.sh" ]] && source "${JENV_DIR}/bin/jenv-init.sh" && source "${JENV_DIR}/commands/completion.sh"
EOF
)

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

if [ ! -f "${jenv_zshrc}" ]; then
  echo "Attempt update of zsh profiles..."
  echo "${jenv_init_snippet}" >> "${jenv_zshrc}"
else
  if [[ -z `grep 'jenv-init.sh' "${jenv_zshrc}"` ]]; then
     echo -e "\n${jenv_init_snippet}" >> "${jenv_zshrc}"
     echo "Updated existing ${jenv_zshrc}"
  fi
fi
