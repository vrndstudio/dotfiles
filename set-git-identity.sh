#!/usr/bin/env bash
# set-git-identity.sh
# Sets git user.name and user.email for the current user on this droplet.
# Run once per droplet, after install.sh, before your first commit.

set -euo pipefail

echo "Set git identity for this droplet."
echo "Find your GitHub noreply email at: https://github.com/settings/emails"
echo

read -rp "GitHub username: " GH_USER
read -rp "GitHub email (noreply or verified): " GH_EMAIL

if [[ -z "$GH_USER" || -z "$GH_EMAIL" ]]; then
  echo "Both fields required. Aborting." >&2
  exit 1
fi

# Basic sanity check on the email
if [[ ! "$GH_EMAIL" =~ ^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$ ]]; then
  echo "That doesn't look like an email. Aborting." >&2
  exit 1
fi

git config --global user.name "$GH_USER"
git config --global user.email "$GH_EMAIL"

echo
echo "Set:"
echo "  user.name  = $(git config --global user.name)"
echo "  user.email = $(git config --global user.email)"
echo
echo "If you already committed with the wrong identity, run in the repo:"
echo "  git commit --amend --reset-author --no-edit"