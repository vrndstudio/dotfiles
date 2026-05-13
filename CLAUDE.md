

# Dropkit with Claude Code & default installs: secure droplet dev environment

## Use case
Disposable DigitalOcean droplets as sandboxed environments for Claude Code. Each droplet is Tailscale-only, used for one project (or untrusted-repo review), then destroyed or hibernated. This repo installs user configs and preferred tools to bootstrap a fresh droplet and get started. 

Primary user: solo web developer on client projects.

## Threat model
In scope:
- Prompt injection in repo content (READMEs, issues, comments) → malicious shell commands
- Credential exfiltration (GitHub tokens, SSH keys, API keys) via the agent
- Dependency poisoning via npm postinstall in untrusted projects
- Inbound network exposure

Out of scope: outbound network restriction (Tailscale-only inbound is the perimeter); container escapes (not using containers).

Reference incidents: RoguePilot (Orca, Feb 2026), Comment-and-Control (Aonan Guan + JHU, Apr 2026), CVE-2025-59536.

## Goals
1. Fresh isolated VM per project — compromised session can't damage host or user
2. Tailnet-only inbound
3. Cheap create/destroy/hibernate; iteration in minutes
4. Pre-configured dev tooling + Claude Code
5. Project context (CLAUDE.md, .claude/) lives in the repo, travels with `git clone`

## Stack

| Layer           | Tool                                                          | Role                                                               |
| --------------- | ------------------------------------------------------------- | ------------------------------------------------------------------ |
| VM provisioning | [trailofbits/dropkit](https://github.com/trailofbits/dropkit) | DigitalOcean droplet lifecycle CLI                                 |
| Network         | Tailscale                                                     | Tailnet-only inbound; public locked down                           |
| First boot      | dropkit's `cloud-init.yaml` (unmodified)                      | User w/ NOPASSWD sudo, SSH, Tailscale, UFW, zsh, Docker            |
| Dev env         | `install.sh` from user's `dropkit-starter-cc` repo                                 | Node + Claude Code, ripgrep/fzf/jq/tmux, oh-my-zsh, dotfiles merge |
| Editor          | VS Code Remote-SSH                                            | Edit droplet filesystem locally                                    |
| Project config  | Repo `CLAUDE.md` + `.claude/settings.json`                    | Via a template or existing repo via `git clone`                                           |

## Credentials
- **DigitalOcean API token**: 90-day, custom scopes (23 from dropkit README), not Full Access.
- **SSH key**: existing GitHub ed25519, registered with DigitalOcean during `dropkit init`. Lets the laptop SSH *into* droplets; grants droplets **no** GitHub access.
- **Private-repo clones** (occasional, manual) — inline fine-grained PAT, never on disk:
  ```bash
  read -s GH_TOKEN                  # paste, Enter — nothing echoed, nothing in history
  git clone https://x-access-token:$GH_TOKEN@github.com/you/repo.git
  cd repo && git remote set-url origin https://github.com/you/repo.git
  unset GH_TOKEN
  ```
  PAT scoped per-repo, 1-day expiry.

## Sandboxing layers
- Tailscale ACL: only user's tailnet reaches the droplet
- UFW (cloud-init): inbound default-deny, SSH only
- No laptop credentials on droplet at boot — closes the agent-abuse path for credential exfil
- Repo `.claude/settings.json` deny block (`Bash(curl:*)`, `WebFetch`, `Read(**/.env*)`)
- User `~/.claude/settings.json` personal hardening overlay

## Next Steps

### Done

`install.sh` script:
- [x] gate gsd install behind `INSTALL_GSD=1` flag
- [x] add `bubblewrap` & `socat` to allow claude sandbox
- [x] copy dotfiles `./.claude/commands/*` to `~/.claude/commands/`
- [x] copy `./statusline.sh` to `~/.claude/`
- [x] copy `.gitconfig` directly (identity set by `set-git-identity.sh`)
- [x] install `.mcp.json` to `~/.claude/.mcp.json`

### Open
- [ ] add step to delete cloned `dotfiles` repo once done? 
- [ ] improve `README.md`
- [ ] `.mcp.json` has `EXA_API_KEY` placeholder — wire to env var or prompt in `set-git-identity.sh`
- [ ] add `shellcheck` / `shfmt` to install or as a prek hook (CLAUDE.md mandates them)
