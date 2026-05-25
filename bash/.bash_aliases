# General directory navigation aliases
alias home='cd ~'
alias root='cd /'

alias ..='cd ..'
alias ...='cd ..; cd ..'
alias ....='cd ..; cd ..; cd ..'

alias l='ls -la'

# Press c to clear the terminal screen.
alias c='clear'

# Press h to view the bash history.
alias h='history'

# GPG
alias gpg-sign='gpg --sign ~/common/gpg/dummy.txt'
alias gpg-kill='gpgconf --kill gpg-agent'