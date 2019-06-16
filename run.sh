if [[ "$OSTYPE" == "linux-gnu" ]]; then
    if [ -f /etc/redhat-release ]; then
       sudo yum clean all && sudo  yum install zsh git vim -y
    fi

    if [ -f /etc/lsb-release ]; then
       sudo apt update && sudo apt install zsh git vim -y
    fi
    
elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew update && brew install zsh git vim
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

curl https://raw.githubusercontent.com/amix/vimrc/master/vimrcs/basic.vim >> ~/.vimrc
curl https://raw.githubusercontent.com/chenset/vimrc/master/.vimrc >> ~/.vimrc

zsh

