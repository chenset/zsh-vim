#!/usr/bin/env bash
#
# 一键配置 zsh + prezto + vimrc + fzf
# 特性: 幂等(可重复执行)、失败即停、错误可读、支持 Linux / macOS
#
# 用法: run.sh [--dry-run] [-h|--help]

set -Eeuo pipefail

# ---------- 参数解析 ----------
DRY_RUN=0

usage() {
  cat <<'EOF'
用法: run.sh [选项]

选项:
  --dry-run    只打印将要执行的操作，不真正修改系统
  -h, --help   显示本帮助
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    -h|--help) usage; exit 0 ;;
    *) printf '未知参数: %s\n\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

# ---------- 基础工具 ----------
log()  { printf '\033[1;32m[+] %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m[!] %s\033[0m\n' "$*" >&2; }
die()  { printf '\033[1;31m[x] %s\033[0m\n' "$*" >&2; exit 1; }

# 执行命令；dry-run 模式下只打印
run() {
  if [ "$DRY_RUN" = 1 ]; then
    printf '\033[1;36m[dry-run] %s\033[0m\n' "$*"
  else
    "$@"
  fi
}

# 出错时打印行号，便于定位
trap 'die "脚本第 $LINENO 行执行失败 (exit=$?)"' ERR

# 非交互环境避免 apt/dpkg 弹窗
export DEBIAN_FRONTEND=noninteractive

# 是否为 root；非 root 时优先使用 sudo（dry-run 下不强制要求 sudo）
if [ "$DRY_RUN" = 1 ]; then
  SUDO="${SUDO:-sudo}"
elif [ "$(id -u)" -eq 0 ]; then
  SUDO=""
elif command -v sudo >/dev/null 2>&1; then
  SUDO="sudo"
else
  die "需要 root 权限，且未安装 sudo"
fi

need() { command -v "$1" >/dev/null 2>&1; }

# 幂等追加：仅当文件内不存在 marker 时才写入 content
append_block() {
  local file="$1" marker="$2" content="$3"
  if [ "$DRY_RUN" = 1 ]; then
    printf '\033[1;36m[dry-run] 追加到 %s (若缺少 marker: %s)\033[0m\n' "$file" "$marker"
    return 0
  fi
  touch "$file"
  if ! grep -qF "$marker" "$file" 2>/dev/null; then
    printf '\n%s\n' "$content" >> "$file"
  fi
}

# ---------- 系统包 ----------
install_linux_pkgs() {
  if [ -f /etc/redhat-release ]; then
    log "检测到 RHEL/CentOS，使用 yum"
    run $SUDO yum clean all
    run $SUDO yum install -y zsh git vim lrzsz curl
  elif [ -f /etc/debian_version ] || [ -f /etc/lsb-release ]; then
    log "检测到 Debian/Ubuntu，使用 apt"
    run $SUDO apt-get update
    run $SUDO apt-get install -y zsh git vim lrzsz libncursesw5-dev \
      autotools-dev autoconf build-essential curl
  else
    warn "未识别的 Linux 发行版，跳过系统包安装"
  fi
}

install_macos_pkgs() {
  need brew || die "未找到 Homebrew，请先安装: https://brew.sh"
  log "使用 Homebrew 安装"
  run brew update
  run brew install zsh git vim fzf
}

# ---------- fzf ----------
install_fzf() {
  if [ ! -d "$HOME/.fzf/.git" ]; then
    log "克隆 fzf"
    run git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
  else
    log "fzf 已存在，跳过克隆"
  fi
  run "$HOME/.fzf/install" --all
}

# ---------- prezto ----------
install_prezto() {
  local zdotdir="${ZDOTDIR:-$HOME}"
  if [ ! -d "$zdotdir/.zprezto/.git" ]; then
    log "克隆 prezto"
    run git clone --depth 1 --recursive \
      https://github.com/sorin-ionescu/prezto.git "$zdotdir/.zprezto"
  else
    log "prezto 已存在，跳过克隆"
  fi

  # 建立 runcom 符号链接（ln -sf 保证幂等）
  run zsh -c '
    setopt EXTENDED_GLOB
    zdotdir="${ZDOTDIR:-$HOME}"
    for rcfile in "$zdotdir"/.zprezto/runcoms/^README.md(.N); do
      ln -sf "$rcfile" "$zdotdir/.${rcfile:t}"
    done
  '

  # 切换默认 shell，失败不要中断整个脚本
  local zsh_path
  zsh_path="$(command -v zsh || true)"
  if [ -n "$zsh_path" ] && [ "${SHELL:-}" != "$zsh_path" ]; then
    run chsh -s "$zsh_path" || warn "chsh 失败，请手动执行: chsh -s $zsh_path"
  fi
}

# ---------- rc 文件 ----------
setup_bashrc() {
  append_block "$HOME/.bashrc" 'fzf --bash' \
'# fzf 基础集成(Ctrl+R 变模糊搜索,Ctrl+T 文件搜索)
eval "$(fzf --bash)" # fzf >= 0.48
export FZF_CTRL_R_OPTS="--height 50% --reverse --preview '\''echo {}'\'' --preview-window down:3:wrap"'
}

setup_zshrc() {
  append_block "$HOME/.zshrc" '# [dotfiles] aliases' \
'alias rm="rm -f"
alias vi=vim
export EDITOR=/usr/bin/vim
export VISUAL=/usr/bin/vim'

  if [[ "$OSTYPE" == linux-gnu ]]; then
    append_block "$HOME/.zshrc" 'fzf --zsh' \
'eval "$(fzf --zsh)" # fzf >= 0.48
export FZF_CTRL_R_OPTS="--height 50% --reverse --preview '\''echo {}'\'' --preview-window down:3:wrap"'
  fi

  append_block "$HOME/.zshrc" '# [dotfiles] key bindings' \
'# key bindings
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
export GOPROXY="https://goproxy.io,direct"
# export GOPROXY="https://goproxy.cn,https://mirrors.aliyun.com/goproxy/,https://goproxy.io,direct"
# alias for cnpm
alias cnpm="npm --registry=https://registry.npm.taobao.org \
--cache=$HOME/.npm/.cache/cnpm \
--disturl=https://npm.taobao.org/dist \
--userconfig=$HOME/.cnpmrc"'
}

setup_vimrc() {
  # 用显式 marker 去重，避免重复执行时内容翻倍
  if grep -qF '# [dotfiles] vimrc' "$HOME/.vimrc" 2>/dev/null; then
    return 0
  fi
  if [ "$DRY_RUN" = 1 ]; then
    printf '\033[1;36m[dry-run] 下载 vimrc 并追加到 %s/.vimrc\033[0m\n' "$HOME"
    return 0
  fi
  touch "$HOME/.vimrc"
  printf '\n# [dotfiles] vimrc\n' >> "$HOME/.vimrc"
  curl -fsSL --retry 3 https://raw.githubusercontent.com/amix/vimrc/master/vimrcs/basic.vim \
    >> "$HOME/.vimrc" || warn "下载 amix/vimrc 失败"
  curl -fsSL --retry 3 https://raw.githubusercontent.com/chenset/vimrc/master/.vimrc \
    >> "$HOME/.vimrc" || warn "下载 chenset/vimrc 失败"
}

# ---------- 主流程 ----------
main() {
  [ "$DRY_RUN" = 1 ] && log "dry-run 模式：仅打印操作，不做任何修改"

  case "${OSTYPE:-}" in
    linux-gnu)
      install_linux_pkgs
      install_fzf
      setup_bashrc
      ;;
    darwin*)
      install_macos_pkgs
      ;;
    cygwin|msys|win32|freebsd*)
      die "暂不支持该平台: ${OSTYPE:-未知}"
      ;;
    *)
      die "无法识别的系统: ${OSTYPE:-未知}"
      ;;
  esac

  install_prezto
  setup_zshrc
  setup_vimrc

  log "安装完成"
  # 仅在交互终端下进入 zsh，避免自动化环境挂起
  if [ "$DRY_RUN" = 0 ] && [ -t 0 ]; then
    exec zsh
  fi
}

main "$@"
