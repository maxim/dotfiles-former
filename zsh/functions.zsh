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