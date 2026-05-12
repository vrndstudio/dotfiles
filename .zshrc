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

# ─── Environment ──────────────────────────────────────────
export EDITOR="code --wait"
export LANG="en_GB.UTF-8"
