# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/Users/${USER}/.oh-my-zsh"

ZSH_DISABLE_COMPFIX=true

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell"
SPACESHIP_EXEC_TIME_SHOW=false

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=()

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.


# Aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias vim="nvim"


##### ASDF #####
. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash

###### RUST #####
export PATH="$PATH:/Users/${USER}/.cargo/bin"

##### POSTGRES #####
export PATH="$PATH:/Applications/Postgres.app/Contents/Versions/latest/bin"

##### FZF #####
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

##### GIT ALIASES #####

alias gco='git checkout'

# Commit
alias gs='git status'
alias ga='git add'
alias gap='git add -p'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gu='git reset HEAD'

# Diff
alias gd='git diff'
alias gdc='git diff --cached'

# Branch
alias gb='git branch'
alias gbd='git branch -D'

# Rebase
alias gr='git rebase'
alias gri='git rebase -i'
alias gra='git rebase --abort'
alias grc='git rebase --continue'

# Stash
alias gstash='git stash'
alias gstashl='git stash list'
alias gstashp='git stash pop'

# Remote Repo
alias gpush='git push origin'
alias gpull='git pull origin'
alias gf='git fetch'

# Log
alias glog='git log --decorate --graph'
alias glogs='git log --decorate --graph --stat'
alias gsub='git subtree push --prefix'

grh () {
  git reset HEAD~$1 $2
}

##### NAVIGATION SHORTCUTS #####
alias projects="cd ~/Projects"
alias learn="cd ~/Projects/learn"
alias personal="cd ~/Projects/personal"
alias oss="cd ~/Projects/open-source"
alias ..='cd ..'

##### BASH ALIASES #####
alias la='ls -aCF'
alias ll='ls -laCF'
alias ls='ls -CF'
alias mkdir="mkdir -pv"


##### FUNCTIONS #####
mkcd () { # Make Change Directory
  mkdir -p $1
  cd $1
}

if test -f "$HOME/work_stuff.sh"; then
. $HOME/work_stuff.sh
fi

if test -f "$HOME/devspace.sh"; then
. $HOME/devspace.sh
fi
