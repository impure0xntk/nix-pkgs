#!/usr/bin/env bash

# sjk bash completion dynamically from sjk --help

_sjk_complete() {
    local current_word="${COMP_WORDS[COMP_CWORD]}"
    local previous_word="${COMP_WORDS[COMP_CWORD - 1]}"
    local commands
    local options

    if [[ ${COMP_CWORD} -eq 1 ]]; then
        commands=$(sjk --help 2>/dev/null | grep -E "^    \w+" | awk '{print $1}')
        COMPREPLY=( $(compgen -W "${commands}" -- "$current_word") )
        return
    fi

    if [[ ${COMP_CWORD} -ge 2 ]]; then
        local command="${COMP_WORDS[1]}"
        options=$(sjk "${command}" --help 2>/dev/null | grep -E -e "^  (\*| ) -+.+" -e "^        -+" | tr -d '*|,')

        COMPREPLY=( $(compgen -W "${options}" -- "$current_word") )
        return
    fi

    COMPREPLY=()
}

complete -F _sjk_complete sjk

