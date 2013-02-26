#!/bin/sh

# Bash Maven2 completion
#

_jenv_comp()
{
  typeset cur
  cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=($(compgen -W "$1" -- "$cur"))
}

_jenv_commands()
{
   cmds="install uninstall list use current cd version default selfupdate help cd"
   _jenv_comp "$cmds"
   return 0
}

_jenv_use()
{
   candidates="${JENV_CANDIDATES[@]}"
   _jenv_comp "$candidates"
   return 0
}

_jenv_list()
{
   candidates="${JENV_CANDIDATES[@]}"
   _jenv_comp "$candidates"
   return 0
}

_jenv_default()
{
  candidates="${JENV_CANDIDATES[@]}"
  _jenv_comp "$candidates"
  return 0
}

_jenv_current()
{
   candidates="${JENV_CANDIDATES[@]}"
   _jenv_comp "$candidates"
}

_jenv_install()
{
   candidates="${JENV_CANDIDATES[@]}"
   _jenv_comp "$candidates"
   return 0
}

_jenv_cd()
{
   candidates="${JENV_CANDIDATES[@]}"
   _jenv_comp "$candidates"
   return 0
}


_jenv_uninstall()
{
   candidates="${JENV_CANDIDATES[@]}"
   _jenv_comp "$candidates"
   return 0
}

_jenv()
{
    typeset prev
    prev=${COMP_WORDS[COMP_CWORD-1]}

    case "${prev}" in
    use)       _jenv_use ;;
    list)      _jenv_list ;;
    install)   _jenv_install ;;
    default)   _jenv_default ;;
    current)   _jenv_current ;;
    cd)        _jenv_cd ;;
    uninstall) _jenv_uninstall ;;
    *)        _jenv_commands ;;
    esac

    # completion for candidate version
    if [[ "$COMP_CWORD" == "3" ]]; then
        candidate="${prev}"
        if [[ -f "${JENV_DIR}/db/${candidate}.txt" ]]; then
           candidate_versions=($(cat "${JENV_DIR}/db/${candidate}.txt"))
            INSTALLED_VERSIONS=()
            # add local unversioned in repository
            for version in $(ls -1 "${JENV_DIR}/candidates/${CANDIDATE}" 2> /dev/null); do
                if [ ${version} != 'current' ]; then
                      INSTALLED_VERSIONS+=("${version}")
                     if ! __jenvtool_array_contains CANDIDATE_VERSIONS[@] "${version}"; then
                       CANDIDATE_VERSIONS+=("${version}")
                     fi
                fi
            done
           versions="${candidate_versions[@]}"
           _jenv_comp "${versions}"
           unset versions
           unset candidate_versions
        fi
        unset candidate
    fi

     return 0
} &&

complete -F _jenv jenv