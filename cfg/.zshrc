function nix_shell_prompt () {
  if [[ -z "${IN_NIX_SHELL}" ]]; then
    REPLY=""
  else
    REPLY="${IN_NIX_SHELL}> "
  fi
}

grml_theme_add_token in-nix-shell -f nix_shell_prompt '%F{cyan}' '%f'

zstyle ':prompt:grml:left:setup' items rc change-root user at host in-nix-shell path vcs newline percent

export HEX_CDN='https://hexpm.upyun.com'
export HEX_MIRROR="$HEX_CDN"

export RUSTUP_UPDATE_ROOT=https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup
export RUSTUP_DIST_SERVER=https://mirrors.tuna.tsinghua.edu.cn/rustup
export PATH="$PATH:$HOME/.cargo/bin"

export FLUTTER_STORAGE_BASE_URL='https://mirrors.tuna.tsinghua.edu.cn/flutter'
export PUB_HOSTED_URL='https://mirrors.tuna.tsinghua.edu.cn/dart-pub'
export PATH="$PATH":"$HOME/.pub-cache/bin"
export CHROME_EXECUTABLE=chromium
