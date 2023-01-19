function nix_shell_prompt () {
  if [[ -z "${IN_NIX_SHELL}" ]]; then
    REPLY=""
  else
    REPLY="${IN_NIX_SHELL}> "
  fi
}

grml_theme_add_token in-nix-shell -f nix_shell_prompt '%F{cyan}' '%f'

zstyle ':prompt:grml:left:setup' items rc change-root user at host in-nix-shell path vcs newline percent
