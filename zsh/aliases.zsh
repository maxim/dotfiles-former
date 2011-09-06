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

# takeup
alias tst='takeup status'

# textmate
alias et='mate . &'
alias ett='mate app config lib db public spec test features Rakefile Capfile Gemfile CHANGELOG package.json &'
alias etp='mate app config lib db public spec test features vendor Rakefile Capfile Gemfile CHANGELOG package.json &'
alias etts='mate app config lib db public script spec test features vendor Rakefile Capfile Gemfile CHANGELOG package.json &'

# todo
alias todo='todo -d ~/.todo'
alias t=todo

# cucumber
alias cuke='cucumber'