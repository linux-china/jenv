#!/bin/sh

if [[ "${JENV_SHELL}" == "zsh" ]]; then
   source "${JENV_DIR}/commands/zsh-completion.sh"
else
   source "${JENV_DIR}/commands/bash-completion.sh"
fi