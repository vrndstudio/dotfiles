# TypeScript Project Preferences

Project-level CLAUDE.md for TypeScript/Node/React projects. Copy this to your project root as `CLAUDE.md` — it complements (and where listed, overrides) the global `~/.claude/CLAUDE.md`.

## Stack
- Package manager: **pnpm** (not npm or yarn)
- Module system: ES modules (`"type": "module"` in package.json), import/export
- TypeScript: strict mode, **never use `any`** — use `unknown` + narrowing
- Type declarations: prefer `type` over `interface`
- Exports: prefer named exports; destructure imports when possible
- Async: async/await only, no callbacks

## React (when applicable)
- Functional components with hooks — no class components
- Tailwind for styling
- Semantic HTML in markup

## Tooling
- Format: Prettier (overrides global ToB recommendation of oxfmt)
- Lint: ESLint (overrides global ToB recommendation of oxlint)
- Indentation: 2 spaces
- Type check: `tsc --noEmit`

## Git
- Branch naming: `feature/description`
- Prefer rebase over merge
- Conventional commits (overrides global ToB "imperative mood" guidance)

## Workflow
Before writing any code:
1. State how you'll verify (test, bash command, browser check)
2. Write the test or verification step first

After code changes:
1. Typecheck
2. Run **only the relevant test**, not the full suite (overrides global ToB "full test suite" guidance)
3. Iterate until verification passes

PR descriptions: short — summary + what to test.
