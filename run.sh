if [[ "$OSTYPE" == "linux-gnu" ]]; then
    if [ -f /etc/redhat-release ]; then
       sudo yum clean all && sudo  yum install zsh git vim lrzsz -y
       if [ $? -ne 0 ];then
          echo 'Install failed!'
          exit 1;
       fi
    fi

    if [ -f /etc/lsb-release ]; then
       apt update && apt install zsh git vim lrzsz libncursesw5-dev autotools-dev autoconf build-essential -y
       if [ $? -ne 0 ];then
         echo 'Install failed!'
         exit 2;
       fi
    fi
    
    if [ -f /etc/debian_version ]; then
       apt update && apt install zsh git vim lrzsz libncursesw5-dev autotools-dev autoconf build-essential -y
       if [ $? -ne 0 ];then
         echo 'Install failed!'
         exit 3;
       fi
    fi
    
elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew update && brew install zsh git vim
        if [ $? -ne 0 ];then
          echo 'Install failed!'
          exit 4;
        fi
elif [[ "$OSTYPE" == "cygwin" ]]; then
        # POSIX compatibility layer and Linux environment emulation for Windows
        exit 1
elif [[ "$OSTYPE" == "msys" ]]; then
        # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
        exit 1
elif [[ "$OSTYPE" == "win32" ]]; then
        # I'm not sure this can happen.
        exit 1
elif [[ "$OSTYPE" == "freebsd"* ]]; then
        # ...
        exit 1
else
        # Unknown.
        exit 1
fi

git clone --depth 1 --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
#echo 'source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"' > ~/.zshrc

 zsh -c '
 setopt EXTENDED_GLOB
 for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
       ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
 done
 chsh -s /bin/zsh
 '

echo 'alias rm="rm -f"' >> ~/.zshrc
echo 'alias vi=vim' >> ~/.zshrc
echo 'export EDITOR=/usr/bin/vim' >> ~/.zshrc
echo 'export VISUAL=/usr/bin/vim' >> ~/.zshrc

echo '
# key bindings
bindkey "\e[1~" beginning-of-line
bindkey "\e[4~" end-of-line
bindkey "\e[5~" beginning-of-history
bindkey "\e[6~" end-of-history
 
# for rxvt
bindkey "\e[8~" end-of-line
bindkey "\e[7~" beginning-of-line
# for non RH/Debian xterm, cannot hurt for RH/DEbian xterm
bindkey "\eOH" beginning-of-line
bindkey "\eOF" end-of-line
# for freebsd console
bindkey "\e[H" beginning-of-line
bindkey "\e[F" end-of-line
# completion in the middle of a line
bindkey "^i" expand-or-complete-prefix
 
bindkey -s "^[Op" "0"
bindkey -s "^[On" "."
bindkey -s "^[OM" "^M"
bindkey -s "^[Oq" "1"
bindkey -s "^[Or" "2"
bindkey -s "^[Os" "3"
bindkey -s "^[Ot" "4"
bindkey -s "^[Ou" "5"
bindkey -s "^[Ov" "6"
bindkey -s "^[Ow" "7"
bindkey -s "^[Ox" "8"
bindkey -s "^[Oy" "9"
bindkey -s "^[Ol" "+"
bindkey -s "^[Om" "-"
bindkey -s "^[Oj" "*"
bindkey -s "^[Oo" "/"

# Set the GOPROXY environment variable
# export GOPROXY="https://goproxy.io,direct"
export GOPROXY="https://mirrors.aliyun.com/goproxy/"

#alias for cnpm
alias cnpm="npm --registry=https://registry.npm.taobao.org \
--cache=$HOME/.npm/.cache/cnpm \
--disturl=https://npm.taobao.org/dist \
--userconfig=$HOME/.cnpmrc"

' >> ~/.zshrc

curl https://raw.githubusercontent.com/amix/vimrc/master/vimrcs/basic.vim >> ~/.vimrc
curl https://raw.githubusercontent.com/chenset/vimrc/master/.vimrc >> ~/.vimrc

zsh

