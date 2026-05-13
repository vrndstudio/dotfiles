# Code style
- Use pnpm, not npm
- Use TypeScript strict mode
- Prefer type over interface
- Use ES modules (import/export), not CommonJS
- Prefer named exports
- Destructure imports when possible
- Use functional components with hooks, no class components
- Use Tailwind for styling
- Use semantic HTML in markup
- Use 2-space indentation
- Format with Prettier, lint with ESLint
- Use async/await, never callbacks

## Repository Etiquette
- Branch naming: feature/description
- Prefer rebase over merge
- Commit messages: conventional commits

# Workflow
Before writing any code:
1. State how you will verify this change works (test, bash command, browser check, etc.)
2. Write the test or verification step first

At implementation:
1. Implement the code
2. Typecheck after code changes
3. Run verification and iterate until it passes
4. Run only the relevant test, not the full suite

After verification:
1. Keep PR descriptions short — summary + what to test

# Communication
- Be concise and direct — skip unnecessary preamble
- When unsure about intent, ask before assuming

# Mistakes to avoid
- Always run tests before committing
- Don't use deprecated APIs (list them)

# Don'ts
- Don't modify .claude/ directory directly
- Don't modify node_modules directly
- Don't add dependencies without asking first
- Don't refactor files that aren't related to the current task
- Don't store secrets in code (use environment variables)
- Don't add 'any' types in TypeScript
