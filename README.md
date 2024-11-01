#### Install

```
curl https://raw.githubusercontent.com/chenset/zsh-vim/master/run.sh | bash
# or
bash <(curl -L -s https://raw.githubusercontent.com/chenset/zsh-vim/master/run.sh)
```

#### Uninstall

```

rm -rf ./z*

```

#### 安装过程中,部分下载失败后的修复

```
# https://github.com/sorin-ionescu/prezto

cd $ZPREZTODIR
git pull
git submodule sync --recursive
git submodule update --init --recursive
```
