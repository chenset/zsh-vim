if [[ "$OSTYPE" == "linux-gnu" ]]; then
    if [ -f /etc/redhat-release ]; then
        yum install zsh git 
    fi

    if [ -f /etc/lsb-release ]; then
        apt install zsh git -y
    fi
    
elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install zsh git
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

git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
echo 'source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"' > ~/.zshrc
echo 'alias vi=vim' >> ~/.zshrc
chsh -s /bin/zsh
curl https://raw.githubusercontent.com/amix/vimrc/master/vimrcs/basic.vim >> ~/.vimrc
curl https://raw.githubusercontent.com/chenset/vimrc/master/.vimrc >> ~/.vimrc
zsh
