export DOTFILES="<%= config['dotfiles_path'] %>"
export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/X11/bin:/Users/max/Executables

plugins=(brew cap gem git github lighthouse osx vagrant)

export EDITOR='<%= config['editor'] %>'

. $DOTFILES/zsh/bootstrap

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"