# Git discipline

## Never without asking
- `git push --force` / `--force-with-lease` to any branch.
- Pushing directly to `main` / `master`. Open a PR/MR instead (unless the repo's CLAUDE.md says it's trunk-based).
- `git reset --hard`, `git checkout -- <file>`, `git clean -fd`, or anything else that discards
  local changes. Show `git status` / `git diff` of what would be lost first.
- `--amend` on a commit that's already pushed. Make a new commit.
- Committing when changes span more than a couple of files without showing the diff first.

## Default to safe
- `git status` before anything destructive; check for uncommitted work before `git pull`.
- Stage files explicitly (`git add <path>`), not `git add -A` — avoids committing secrets or `.env`.
- Never commit credentials. If one is already committed, stop and tell me; rotating beats rewriting history.

## Commits
- Conventional style preferred (`feat:`, `fix:`, `docs:`, `chore:`), first line ≤ 72 chars, imperative mood.
- No AI attribution footers unless I opt in.

## The vault
- If `~/brain` is a git repo: commit with `chore(brain): <what changed>` at the end of a session that
  wrote to it. Push only to a **private** remote. Never make the vault repo public.

## When something has gone wrong
Stop and tell me immediately. Don't try to fix a destructive mistake silently.
