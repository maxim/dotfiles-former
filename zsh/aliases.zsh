# git
alias gl='git log --oneline --decorate'
compdef _git gl=git-log

alias glr='git pull --rebase'
compdef _git glr=git-pull

alias gs='git status -sb'
compdef _git gs=git-status

alias gd='git diff'
compdef _git gd=git-diff

# rails 2
alias sc='script/console'
alias ss='script/server'
alias sg='script/generate'
alias sd='script/destroy'

# rails 3
alias sr='script/rails'

# rails custom
alias sn='script/news --oneline'

# takeup
alias tst='takeup status'
alias tru='takeup restart unicorn'
alias tra='takeup restart unicorn && takeup restart resque'
alias trr='takeup restart resque'

# todo
alias todo='todo -d ~/.todo'
alias t=todo

# ps
alias pgrep='ps ax | grep -v grep | grep $1'

# bundler
alias gemfile_outdated="grep -Po 'gem\s+(\S+)' Gemfile | cut -d\"'\" -f 2 | cut -d'\"' -f2 | xargs bundle outdated"

# sublime
alias sp='subl "${PWD##*/}.sublime-project"'
