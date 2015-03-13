set -e 

cd ${0%/*}
cd .. && source dotfiles.conf

color='\033[0;34m'
NC='\033[0m' # No Color

if [ ! -n "$ZSH" ]; then
  ZSH="${zsh_dst}"
fi

dedupepath(){
    if [ -n "$PATH" ]
    then
        old_PATH=$PATH:
        PATH=
        while [ -n "$old_PATH" ]
        do
            x=${old_PATH%%:*}
            case $PATH: in
                (*:"$x":*)  ;;
                (*) PATH=$PATH:$x  ;;
            esac
            old_PATH=${old_PATH#*:}
        done
        PATH=${PATH#:}
        unset old_PATH x
    fi
}

makeZshrc(){
    echo "${color}Making ${zshrc} file...${NC}"
    [ -e "${zshrc}" ] &&  mv "${zshrc}" ~/.zshrc.orig
    touch "${zshrc}"
    echo "## OS specific settings ############################" >> ${zshrc}
    # TODO: add profiles, rsync, ant, atom, autoenv, vim-interaction, virtualenv, command-not-found, dirhistory, & all the git plugins ???
    if [[ "$OSTYPE" =~ ^(linux)+ ]]; then
        # TODO: detect linux flavor with cat /etc/issue ? in order to load debian plugin
        echo plugins=\(git git-extras brew sudo tmux colored-man extract zsh_reload copyfile copydir common-aliases safe-paste fasd ssh-agent debian\) >> ${zshrc} 
        echo "export HOMEBREW_CASK_OPTS'--appdir=~/Applications --caskroom=$(brew --prefix)/Caskroom'" >> ${zshrc}
        #echo export TERM="xterm-256color" >> ${zshrc}
        module purge
    elif [[ "$OSTYPE" =~ ^(darwin)+ ]]; then
        echo plugins=\(git git-extras brew sudo tmux tmuxinator colored-man vundle web-search extract zsh_reload copyfile copydir common-aliases ant fasd aws osx brew-cask xcode osx-aliases\) >> ${zshrc} 
        echo "export HOMEBREW_CASK_OPTS='--appdir=/Applications --caskroom=$(brew --prefix)/Caskroom'" >> ${zshrc}
        #echo source $(which zsh coreutils)/libexec/gnubin >> 
        # TODO: make this automatic
        echo "export ECLIPSE_HOME=$(brew --prefix)/Caskroom/eclipse-java/4.4.1/eclipse" >> ${zshrc}
    fi

dedupepath;

cat <<EOF >> "${zshrc}"

## ZSH settings ####################################
export ZSH=$ZSH 
ZSH_THEME="wm"

#CASE_SENSITIVE="true"

#DISABLE_AUTO_UPDATE="true"
DISABLE_UPDATE_PROMPT=true
UPDATE_ZSH_DAYS=3

#DISABLE_LS_COLORS="true"

#DISABLE_AUTO_TITLE="true"

ENABLE_CORRECTION="true"

#COMPLETION_WAITING_DOTS="true"

DISABLE_UNTRACKED_FILES_DIRTY="true"

# formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
#HIST_STAMPS="mm/dd/yyyy"

#ZSH_CUSTOM=/path/to/new-custom-folder

source $ZSH/oh-my-zsh.sh

## EXPORTS ############################################
export PATH="$(brew --prefix)/bin:$PATH"
export MANPATH="$(brew --prefix)/share/man:$MANPATH"
export INFOPATH="$(brew --prefix)/share/info:$INFOPATH"

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Preferred editor for local and remote sessions
# if [[ -n \$SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='vim'
# fi

# Make vim the default editor.
export EDITOR='vim';

# Omit duplicates and commands that begin with a space from history.
export HISTCONTROL='ignoreboth';

# Prefer US English and use UTF-8.
export LANG='en_US.UTF-8';
export LC_ALL='en_US.UTF-8';

#export TERM="xterm-255color"

# Highlight section titles in manual pages.
export LESS_TERMCAP_md="${yellow}";

# Don’t clear the screen after quitting a manual page.
export MANPAGER='less -X';

# Always enable colored \`grep\` output.
export GREP_OPTIONS='--color=auto';

# Display correct tmux window titles
#export DISABLE_AUTO_TITLE=true

# Always start tmux session at login
#if tmux has-session
#then
    #tmux attach-session 
#else 
    #tmux
#fi
#TODO: idk why i need to do this to make colors appear in dirs...
#src 
EOF
}

linkZsh() {
    echo "${color}Linking custom zsh overrides...${NC}"
    rm -rf $ZSH/custom
    mkdir -p $ZSH/custom 
    ln -sv "${zsh_src}"/* $ZSH/custom
    #ln -sfv "${dotfiles}"/.zshrc ~
}

if [ -d "$ZSH" ]; then
  echo "\033[0;33mYou already have Oh My Zsh installed.${NC} You'll need to remove $ZSH if you want to install"
  makeZshrc
  linkZsh
  exit
fi

#TODO: check for zsh and install it using the appropriate method for current OS...
# brew install zsh

echo "${color}Cloning Oh My Zsh...${NC}"
hash git >/dev/null 2>&1 && git clone git://github.com/robbyrussell/oh-my-zsh.git $ZSH || {
  echo "git not installed"
  exit
}

if sudo -v
then
    echo "$(which zsh)" | sudo tee --append /etc/shells
    chsh "$(echo "$USER")" -s "$(which zsh)"
else
    rm -ri ~/.bash*
    touch ~/.bash_login
    #TODO: detect if using modules...
    module purge
    echo "[ -f  $(which zsh) ] && exec $(which zsh) -l" >> ~/.bash_login
    echo "PATH=$(brew --prefix)/bin:$PATH" >> ~/.bash_login
fi

makeZshrc
linkZsh

#TODO: check if brew is installed first
brew install fasd

env zsh 
. ~/.zshrc 

exit 0;
