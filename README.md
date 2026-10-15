#### Install

```
curl -fsSL https://raw.githubusercontent.com/chenset/zsh-vim/master/run.sh | bash
# or
bash <(curl -fsSL https://raw.githubusercontent.com/chenset/zsh-vim/master/run.sh)
```

预览改动（dry-run，不修改系统）：

```
curl -fsSL https://raw.githubusercontent.com/chenset/zsh-vim/master/run.sh | bash -s -- --dry-run
# or
bash <(curl -fsSL https://raw.githubusercontent.com/chenset/zsh-vim/master/run.sh) --dry-run
```

脚本特性：幂等（可重复执行）、失败即停、支持 Linux（RHEL/CentOS、Debian/Ubuntu）与 macOS。

#### 选项

```
bash run.sh --dry-run   # 只打印将要执行的操作，不修改系统
bash run.sh --help      # 查看帮助
```

`--dry-run` 适合在真正安装前预览改动，或在 CI/容器中做检查。

#### Uninstall

```
rm -rf ~/.z*
```

#### 安装过程中,部分下载失败后的修复

```
# https://github.com/sorin-ionescu/prezto

cd $ZPREZTODIR
git pull
git submodule sync --recursive
git submodule update --init --recursive
```
