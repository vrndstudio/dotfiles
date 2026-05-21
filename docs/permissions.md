# Reducing Permission Prompts

How to cut "unsandboxed Bash" prompts in Claude Code without resorting to `--dangerously-skip-permissions`.

## Why prompts happen

The sandbox (configured in `.claude/settings.json` → `sandbox.enabled: true`) blocks:

- Network access (any host)
- Writes outside the current working directory
- Privileged ops

When Claude proposes a command that needs any of those, the harness escalates to an **unsandboxed** prompt. The "don't ask again" option only appears when the command matches a pattern in `permissions.allow` — free-form strings (varying ports, flags, pipes) won't match, so no shortcut is offered.

Example trigger:

```
sleep 25 && curl -s http://localhost:3002 | head -5
```

`curl` = network = sandbox denial → unsandboxed prompt. No allowlist match → no "don't ask again."

## Fix order

### 1. Pre-approve patterns in `.claude/settings.json`

Add canonical command shapes to `permissions.allow`. Patterns are glob-ish — wildcards expand within a single command token.

```jsonc
{
  "permissions": {
    "allow": [
      // Existing entries above…

      // Localhost dev servers
      "Bash(curl http://localhost:*)",
      "Bash(curl -s http://localhost:*)",
      "Bash(curl -sS http://localhost:*)",
      "Bash(curl -i http://localhost:*)",
      "Bash(curl http://127.0.0.1:*)",
      "Bash(curl -s http://127.0.0.1:*)",

      // Common dev-loop tools
      "Bash(sleep *)",
      "Bash(echo *)",
      "Bash(pnpm test*)",
      "Bash(pnpm build*)",
      "Bash(pnpm dlx *)",
      "Bash(node *)",
      "Bash(bun *)"
    ]
  }
}
```

Caveat: a `deny` entry overrides `allow`. The current `.claude/settings.json` does **not** deny `curl`, but if you add one, scope it (e.g. `Bash(curl http*://*)` minus the localhost allows above will not work — denies always win, so prefer narrow denies).

### 2. Use the `fewer-permission-prompts` skill

Scans your session transcripts, finds read-only Bash/MCP calls you've approved repeatedly, generates a prioritized allowlist patch to `.claude/settings.json`. Run after a few real sessions to catch real-world variants.

```
/fewer-permission-prompts
```

### 3. Loosen sandbox for localhost (if available)

Some versions support per-host network allowlisting in the `sandbox` block. Check your installed Claude Code version's settings schema. If supported, allow `localhost`/`127.0.0.1` so dev-server probes never trigger an unsandboxed prompt.

### 4. Standardize command shapes in `CLAUDE.md`

Fewer string variants = better allowlist hit rate. Add a note like:

> Always use `curl -sS http://localhost:PORT/path` for local probes (no `-v`, no `--silent`, no aliases).

## What NOT to do

- **`--dangerously-skip-permissions`** — defeats the threat model. The droplet's whole point is sandboxed dev for untrusted repos.
- **Blanket `Bash(*)` in `allow`** — same problem, less honest.
- **Adding `deny` for `curl:*` globally** — current settings don't do this, don't start. Curl to localhost is benign; curl to external hosts is what Tailscale-only + sandbox already constrain.

## Web access: route everything through Exa MCP

Single sanctioned egress channel = one auditable path, no domain-allowlist sprawl.

**Allow:**

```jsonc
"allow": [
  "mcp__exa__web_search_exa",
  "mcp__exa__web_fetch_exa"
]
```

**Deny built-in web tools:**

```jsonc
"deny": [
  "WebFetch",
  "WebSearch"
]
```

**Curl exceptions (path-scoped, no subdomain spoofing):**

```jsonc
"allow": [
  "Bash(curl -s https://raw.githubusercontent.com/*)",
  "Bash(curl -sS https://raw.githubusercontent.com/*)"
],
"ask": [
  "Bash(curl *github.com*)",
  "Bash(curl *raw.githubusercontent.com*)"
]
```

### Why

- `WebFetch(domain:github.com)` — github.com hosts attacker-controlled content (issues, PRs, gists). Matches the **Comment-and-Control** vector in the threat model.
- Bare `*` glob on `raw.githubusercontent.com*` matches `raw.githubusercontent.com.attacker.com`. Always use trailing `/*`.
- Exa MCP centralizes web access → one logging point for credential-exfil monitoring.

### Setup

1. Exa MCP defined in `.mcp.json` (already at user level via `install.sh` → `~/.claude/.mcp.json`).
2. Set `EXA_API_KEY` env var (currently a placeholder — see `CLAUDE.md` open list).
3. Remove Exa from `disabledMcpjsonServers` in `.claude/settings.local.json` once key is wired.

### Bash curl bypass

Denying `WebFetch` doesn't stop `Bash(curl ...)`. Other-domain curl falls through to the unsandboxed prompt — friction enough for the threat model. Don't add a blanket `Bash(curl:*)` deny; it'd block localhost probes too.

## References

- Project settings: `.claude/settings.json`
- Local overrides: `.claude/settings.local.json` (gitignored)
- Sandbox section: `.claude/settings.json` → `sandbox`
- Threat model: `CLAUDE.md` → "Threat model"
- Exa MCP config: `.mcp.json`
