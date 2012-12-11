function tlog() {
  if test "$1" = ""; then
    tail -f log/development.log
  else
    tail -f "log/$1.log"
  fi
}

function schema() {
  if test "$1" = ""; then
    grep 'create_table' db/schema.rb | cut -d \" -f2
  else
    sed -n "/create_table \"$1/,/^ *end *$/p" db/schema.rb
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
  mkdir -p `dirname "$1"` && touch $1 && subl $1
}

function lc() {
  if [ -d $1 ]; then
    ls -anh $1
  else
    if [ -f $1 ]; then
      cat $1
    fi
  fi
}

function track_git_branch() {
  if test "`current_branch`" = ""; then
    echo 'Not in git repo.';
  else
    echo "running: git branch --set-upstream `current_branch` origin/`current_branch`";
    git branch --set-upstream `current_branch` origin/`current_branch`;
  fi
}

function install_sublime_theme() {
  cp $1 "$HOME/Library/Application Support/Sublime Text 2/Packages/Color Scheme - Default/"
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

function rvm_unicode_symbol() {
  sym=`$HOME/.rvm/bin/rvm-prompt u`

  if [[ -n $sym ]]; then
    echo "${sym} ";
  else
    echo "";
  fi
}
