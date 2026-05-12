# ─── Environment ──────────────────────────────────────────
export LANG="en_GB.UTF-8"
export LC_ALL="en_GB.UTF-8"
export EDITOR="nvim"

alias vim="nvim"

# ─── Oh My Zsh ────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="agnoster"

plugins=(
  git
  node
  npm
  z
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# ─── Aliases (kept in a separate file for tidiness) ───────
[ -f "$HOME/.aliases" ] && source "$HOME/.aliases"

# fzf integration (after the other env vars):
[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh
[ -f /usr/share/doc/fzf/examples/completion.zsh ]   && source /usr/share/doc/fzf/examples/completion.zsh