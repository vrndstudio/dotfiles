#!/usr/bin/env bash
# droplet dev environment setup

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR"

if [ ! -f "$DOTFILES_DIR/.zshrc" ] && [ ! -f "$DOTFILES_DIR/.gitconfig" ]; then
  cat >&2 <<EOF
ERROR: $DOTFILES_DIR doesn't look like the dotfiles repo
       (no .zshrc or .gitconfig found alongside this script).
Clone the repo first, then run this script from inside it:
  git clone https://github.com/<user>/dotfiles.git
  cd dotfiles
  bash bootstrap.sh
EOF
  exit 1
fi

echo "==> Using dotfiles at $DOTFILES_DIR"

echo "==> Updating apt"
sudo apt-get update -qq

echo "==> Installing system packages"
# git, curl, zsh, ca-certificates already provided by dropkit's cloud-init.
sudo apt-get install -y -qq \
  nodejs \
  npm \
  ripgrep \
  fzf \
  jq \
  tmux

echo "==> Configuring npm for user-global installs"
mkdir -p "$HOME/.local"
npm config set prefix "$HOME/.local"
export PATH="$HOME/.local/bin:$PATH"

echo "==> Installing Claude Code"
npm install -g @anthropic-ai/claude-code

echo "==> Enabling corepack (pnpm/yarn on demand)"
sudo corepack enable

echo "==> Installing oh-my-zsh (unattended, keeping our own .zshrc)"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

echo "==> Installing zsh plugins"
for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
  dest="$ZSH_CUSTOM/plugins/$plugin"
  if [ ! -d "$dest" ]; then
    git clone --depth=1 "https://github.com/zsh-users/$plugin" "$dest"
  else
    git -C "$dest" pull --ff-only --quiet || true
  fi
done

# Marker-block append strategy for files cloud-init already populates
# (.gitconfig owns [user]; .zshrc has minimal cloud-init defaults). We
# bracket our additions with these markers so re-runs replace only our
# block and leave cloud-init's preamble alone.
MARK_BEGIN="# >>> dotfiles bootstrap >>>"
MARK_END=" # <<< dotfiles bootstrap <<<"

merge_append() {
  local src="$1" dst="$2"
  [ -f "$src" ] || return 0
  touch "$dst"
  if grep -qF "$MARK_BEGIN" "$dst"; then
    sed -i "/^${MARK_BEGIN}\$/,/^${MARK_END}\$/d" "$dst"
  fi
  {
    echo ""
    echo "$MARK_BEGIN"
    cat "$src"
    echo "$MARK_END"
  } >> "$dst"
}

copy_dotfile() {
  local src="$1" dst="$2"
  [ -f "$src" ] || return 0
  install -m 0644 "$src" "$dst"
}

echo "==> Merging .gitconfig (preserving cloud-init's [user])"
merge_append "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"

echo "==> Merging .zshrc (preserving cloud-init's defaults)"
merge_append "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

echo "==> Copying .aliases"
copy_dotfile "$DOTFILES_DIR/.aliases" "$HOME/.aliases"

echo "==> Copying user-level Claude Code config"
mkdir -p "$HOME/.claude"
copy_dotfile "$DOTFILES_DIR/.claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
copy_dotfile "$DOTFILES_DIR/.claude/settings.json" "$HOME/.claude/settings.json"

echo "==> Installing get-shit-done (Claude global skill)"
npx -y get-shit-done-cc@latest --claude --global

echo "==> Setting zsh as login shell"
zsh_path="$(command -v zsh)"
current_shell="$(getent passwd "$USER" | cut -d: -f7)"
if [ "$current_shell" != "$zsh_path" ]; then
  sudo chsh -s "$zsh_path" "$USER"
fi

echo "==> Done."
echo
echo "Verify:"
echo "  claude --version"
echo "  node --version"
echo "  rg --version"
echo "  echo \$SHELL                # expect /usr/bin/zsh after next login"
echo "  grep -A1 'dotfiles' ~/.gitconfig | head -20"
echo
echo "Open a new shell (zsh) or run: exec zsh -l"
echo
echo "For private-repo clones from this droplet, paste a short-lived fine-grained PAT:"
echo "  read -s GH_TOKEN          # paste, Enter — nothing echoed, nothing in history"
echo "  git clone "https://x-access-token:$GH_TOKEN@github.com/<you>/<repo>.git"

echo "  cd <repo> && git remote set-url origin https://github.com/<you>/<repo>.git"
echo "  unset GH_TOKEN"

