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

# takeup
alias tst='takeup status'
alias tru='takeup restart unicorn'

# sublime
alias stm="subl --project /Users/max/dev/madmimi/madmimi.sublime-project"
alias stp="subl --project /Users/max/dev/printio/printio/printio.sublime-project"

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

# ps
alias pgrep='ps ax | grep -v grep | grep $1'

# emacs
alias emacs="/usr/local/Cellar/emacs/HEAD/Emacs.app/Contents/MacOS/Emacs"

# bundler
alias binstubs="bundle install --binstubs=./.bundler_stubs"
