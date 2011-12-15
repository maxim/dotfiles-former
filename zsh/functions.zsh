function tlog() {
  if test "$1" = ""; then
    tail -f log/development.log
  else
    tail -f "log/$1.log"
  fi
}

function remote_console() {
  /usr/bin/env ssh $1 "( cd $2 && ruby script/console production )"
}

function rvm_unicode_symbol() {
  sym=`$HOME/.rvm/bin/rvm-prompt u`

  if [[ -n $sym ]]; then
    echo "${sym} ";
  else
    echo "";
  fi
}

function onetest() {
  if [ -d spec ]; then
    ruby -Ispec $1 --color --example $2
  else
    ruby -Itest $1 --name $2
  fi
}

function tm() {
  mkdir -p `dirname "$1"` && touch $1 && mate $1
}

function track_git_branch() {
  if test "`current_branch`" = ""; then
    echo 'Not in git repo.';
  else
    echo "running: git branch --set-upstream `current_branch` origin/`current_branch`";
    git branch --set-upstream `current_branch` origin/`current_branch`;
  fi
}

function open_airbrake_error() {
  if [ ! -f .airbrake-url ]; then
    echo "There is no .airbrake-url file in the current directory..."
    return 0;
  else
    airbrake_url=$(cat .airbrake-url);
    echo "Opening ticket #$1";
    `open $airbrake_url/errors/$1`;
  fi
}

alias abo='open_airbrake_error'