
ZSH=$HOME/.oh-my-zsh

ZSH_THEME="agnoster"

# Example aliases
alias zshconfig="vim ~/.zshrc"
alias ohmyzsh="vim ~/.oh-my-zsh"

plugins=(git chruby docker)

source $ZSH/oh-my-zsh.sh

# Stop helping me.
unsetopt correct_all

# Customize to your needs...
source ~/.aliases

eval "$(direnv hook zsh)"
