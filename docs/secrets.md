# Secrets & environment variables

## TL;DR

- No built-in secrets vault. By design.
- The droplet is the boundary: disposable, Tailscale-only, destroyed when done.
- Keep secrets on the droplet only as long as needed. Never commit them.

## Why no "secrets tab" like Codespaces

- Codespaces injects secrets as env vars at container start.
- Anything in the container can read them, including a tricked Claude session.
- The UI feels safer than it is.
- Trail of Bits' own setup uses the same approach as ours: manual paste + deny-list + disposable VM.

## Four categories

### 1. One-shot, very sensitive

Examples: GitHub token for a single clone, deploy key for one push.

Rule: paste into a shell variable, use once, unset. Never write to disk.

```shell
read -s GH_TOKEN          # paste, Enter — nothing shown
git clone https://x-access-token:$GH_TOKEN@github.com/you/repo.git
unset GH_TOKEN
```

- No disk write.
- No shell history.
- Gone when terminal closes.

### 2. Per-project, iterate often

Examples: local DB connection string, non-production API key.

Pattern: `.env` file in the project folder, loaded by the app framework.

Required:

- `.gitignore` includes `.env` and `.env.*`.
- `chmod 600 .env`.
- Claude already refuses to read `.env*` via `.claude/settings.json`. Verify if you edit that file.

### 3. Droplet-wide

Examples: Exa API key, MCP server keys, anything a long-running tool needs at startup.

Pattern: `~/.zshrc.local` holds the values, never committed.

- File: `export EXA_API_KEY=abc123` lines.
- Permissions: `chmod 600 ~/.zshrc.local`.
- `~/.zshrc` sources `~/.zshrc.local` if it exists.
- `.mcp.json` references `${EXA_API_KEY}` — env lookup, no key in git.
- `.claude/settings.json` denies reads of `~/.zshrc.local`.

### 4. Never on the droplet

Examples: DigitalOcean account token, production DB credentials, live payment keys.

Rule: stays on the laptop or production host. If a droplet leak would hurt, the secret doesn't belong there.

## Gaps today (ranked by impact)

1. **Outbound traffic unrestricted.** Firewall blocks inbound, not outbound. A compromised session can exfiltrate anywhere. Fix: allowlist outbound to GitHub, npm, Anthropic API, Tailscale.
2. **Deny-list is short.** Trail of Bits covers SSH keys, cloud creds, registry tokens, gh CLI config, git credentials. Copy their list into `.claude/settings.json`.
3. **`~/.zshrc.local` not wired up.** Install script doesn't create it, `.zshrc` doesn't source it, `.mcp.json` still has literal placeholder for Exa key.
4. **No Exa-key prompt at setup.** Extend `set-git-identity.sh` to optionally collect and write it.

## Skipped on purpose

- **Vault, SOPS, age, Doppler.** Setup cost > benefit for solo dev + disposable VMs. Trail of Bits skipped them too.
- **1Password CLI.** Real auth gate (Touch ID / master password) before retrieval. Stronger than a flat file but adds per-droplet setup. Revisit if manual paste becomes painful.

## When to revisit

- Secrets where leakage has real cost (prod data, customer creds) → move them off the droplet entirely.
- Adding collaborators → shared vault (1Password team, etc.).
- Pasting the same secrets every new droplet → wire into install script, or adopt 1Password CLI.

## References

<!-- cspell:ignore dropkit -->

- Trail of Bits claude-code-config — source of the deny-list pattern: https://github.com/trailofbits/claude-code-config
- Trail of Bits dropkit — droplet lifecycle tool: https://github.com/trailofbits/dropkit
- `README.md` — Category 1 paste pattern.
- `CLAUDE.md` "Next Steps" — tracks the gaps above.

Cuts:

- TL;DR up top — 3 bullets, full answer
- Headers + bullets, no narrative paragraphs
- Code block stays
- cSpell comment for "dropkit"
- ~40% shorter than v1
