#!/usr/bin/env fish

# sjk fish completion dynamically from sjk --help

function __sjk_command_completion
    set commands (sjk --help 2>/dev/null | grep -E "^    \w+" | awk '{print $1}')
    for cmd in $commands
        printf "%s\n" $cmd
    end
end

function __sjk_option_completion
    set command $argv[1]
    set options (sjk $command --help 2>/dev/null | grep -E -e "^  (\*| ) -+.+" -e "^        -+" | tr -d '*|,')
    for opt in $options
        printf "%s\n" $opt
    end
end

# Main completion function
function _sjk_complete
    set current_word (commandline -ct)

    set previous_word (commandline -cp)


    if test (count $argv) -eq 1
        __sjk_command_completion
    else if test (count $argv) -ge 2
        __sjk_option_completion $argv[1]
    end

end

complete -c sjk -a '(__sjk_command_completion)' -n '__fish_seen_subcommand_from (commandline -cp)'
complete -c sjk -n 'not __fish_seen_subcommand_from (commandline -cp)' -a '(__sjk_option_completion $argv[1])'

