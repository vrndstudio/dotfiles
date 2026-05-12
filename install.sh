#!/bin/bash

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# ─── zsh plugins (not bundled by default) ─────────────────
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# ─── Dotfiles symlinks ────────────────────────────────────
for file in .gitconfig .zshrc .aliases; do
  if [ -f "$DOTFILES_DIR/$file" ]; then
    ln -sf "$DOTFILES_DIR/$file" "$HOME/$file"
  fi
done

# ─── Claude Code global config ───────────────────────────
mkdir -p ~/.claude

if [ -f "$DOTFILES_DIR/.claude/CLAUDE.md" ]; then
  cp "$DOTFILES_DIR/.claude/CLAUDE.md" ~/.claude/CLAUDE.md
fi

if [ -f "$DOTFILES_DIR/.claude/settings.json" ]; then
  cp "$DOTFILES_DIR/.claude/settings.json" ~/.claude/settings.json
fi

# ─── GSD ──────────────────────────────────────────────────
npx get-shit-done-cc@latest --claude --global

echo "✓ dotfiles installed"
